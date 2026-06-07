module P =
  struct
  include Eio.Path
  end

module Output = struct
  let src x =
    "./_build/default/src/output/node_modules/bkhack/" ^ x ^ ".js"
end

let fix_base_path =
  let f gr = Re.Group.get gr 1 in
  Re.replace ~all:false ~f Re.(compile @@
    seq [str (Sys.getcwd ()); char '/'; group (any |> rep1)]
  )

module Path = struct
  open Eio

  let physlink ~sw process_mgr ~link_to file =
    Fiber.fork ~sw @@ fun () ->
    Process.run
      process_mgr
      ["ln"; Path.native_exn link_to; Path.native_exn file]

  let symlink ~sw ~link_to file =
    Fiber.fork ~sw @@ fun () ->
    let link_to =
      let x = fix_base_path @@ P.native_exn link_to in
      Sys.getcwd () ^ "/" ^ x in
    Path.symlink ~link_to file

  let mkdir ~sw ?(perm = 0o700) dirname filename f =
    Fiber.fork ~sw @@ fun () ->
    let newpath = Path.(dirname / filename) in
    Path.mkdir ~perm newpath;
    Switch.run @@ fun sw ->
    f sw newpath

  let copy_dir ~sw ~procm from_ to_ =
    Fiber.fork ~sw @@ fun () ->
    Process.run procm
      ["cp"; "-r"; Path.native_exn from_; Path.native_exn to_]

  exception Directory_doesnt_exist of string

  let getdir dirname filename f =
    let newpath = Path.(dirname / filename) in
    if not @@ Path.is_directory newpath then raise @@ Directory_doesnt_exist (Path.native_exn newpath);
    f newpath

end

module Pnpm = struct
  module Process = struct
    let run process_mgr ?stdout ?stdin ?stderr cmd =
      Eio.Process.run process_mgr ?stdout ?stdin ?stderr @@ "pnpm" :: "exec" :: cmd
  end
end

let n = ref 0

let idgen' clock =
  let a = Eio.Time.now clock |> Float.to_int |> Int.to_string
  and b = let x = !n |> Int.to_string in n := !n + 1; x in
  a ^ "-" ^ b

let idgen clock =
  Eio.Time.now clock |> Float.to_int |> Int.to_string

open Eio

let is_page =
  Re.exec_opt Re.(compile @@
    seq [str "Page"; str "__"; group (any |> rep1 |> shortest); str ".re" ])
  %> Option.map Re.(fun gr ->
    `fname (Group.get gr 0),
    `id (Group.get gr 1))

(** [is_page' src_dir filename] @deprecated *)
let is_page' src_dir =
  is_page %> Option.map (
    fun (`fname x, y) -> `fpath P.(src_dir / x), `fname x, y )

let compile_jsfile~procm~clock ?(watch = false) out_dir log_dir entry =
  let mkdirs x =
    let exists_ok = true and perm = 0o700 in
    Path.mkdirs ~exists_ok ~perm x in
  mkdirs out_dir;
  mkdirs log_dir;
  Path.with_open_out P.(log_dir / (idgen' clock ^ ".stdout")) ~create:(`Exclusive 0o700) @@ fun stdout ->
  Pnpm.Process.run procm ~stdout @@
    [ "webpack" ] @
    (if watch then ["watch"] else []) @
    [ "--config"; "build_aux/webpack_preprocessor.js"
    ; "--mode"; "development"
    ; "--entry"; Path.native_exn entry
    ; "--output-path"; Path.native_exn out_dir
    ; "--output-filename"; "index.js"]

let webpack_template v =
  let s = v |> List.map(fun (k, v) -> "\""^k^"\":\""^v^"\"") |> String.concat(",\n") in
  Printf.sprintf {|
const webpack = require("webpack")
const path = require("path")

const backend_address = (() => {
	if (process.env.BKHACK_BACKEND_ADDRESS === undefined || typeof process.env.BKHACK_BACKEND_ADDRESS !== "string") {
		throw new Error("did not specify BKHACK_BACKEND_ADDRESS")
	}
	return process.env.BKHACK_BACKEND_ADDRESS;
})()

const firebase_key = (() => {
	if (process.env.BKHACK_FIREBASE_KEY === undefined || typeof process.env.BKHACK_FIREBASE_KEY !== "string") {
		throw new Error("did not specify BKHACK_FIREBASE_KEY")
	}
	return process.env.BKHACK_FIREBASE_KEY;
})()

module.exports = {
	plugins: [
		new webpack.DefinePlugin({
			"bkhackenv.backend_address": `\"${backend_address}\"`,
			"bkhackenv.firebase_key": `\"${firebase_key}\"`,
		})
	],
  entry: {
    %s
  },
}
|} s

let compile_jsfile'~procm~clock~cwd ?(watch = false) ~optimization out_dir ?log_dir entries =
  let opt_to_str = function `Production -> "production" | `Development -> "development" in
  let mkdirs x =
    let exists_ok = true and perm = 0o700 in
    Path.mkdirs ~exists_ok ~perm x in
  let wrapdir ?log_dir clock k =
    match log_dir with
    | None -> k (Pnpm.Process.run ?stdout:None)
    | Some log_dir ->
      mkdirs log_dir;
      Path.with_open_out P.(log_dir / (idgen' clock ^ ".stdout")) ~create:(`Exclusive 0o700) @@ fun stdout ->
      k (Pnpm.Process.run ~stdout)
    in
  mkdirs out_dir;
  mkdirs Path.(cwd / "_build_webpack");
  wrapdir ?log_dir clock @@ fun run ->
  Path.save ~create:(`Or_truncate 0o700) Path.(cwd / "_build_webpack" / "config.js") @@ webpack_template @@ List.map (fun (x, y) -> (x, Path.native_exn y)) entries;
  run procm @@
    [ "webpack" ] @
    (if watch then ["watch"] else []) @
    [ "--config"; "_build_webpack/config.js"
    ; "--mode"; opt_to_str optimization
    ; "--output-path"; Path.native_exn out_dir
    ]

[@alert naive("TODO(khang+kinten) bao plz grep from AST!")]
let file_grep_attrib attrib_name refile' =
  let wrap_exn f =
    try f() with Failure "hd" [@warning "-52"] ->
    raise Not_found in
  let quoted x = Re.(seq [char '"'; x; char '"']) in
  let matches =
    Re.all Re.(compile @@
      seq [char '['; char '@'; attrib_name; blank |> rep; quoted (group (any |> rep1 |> shortest)); blank |> rep; char ']'])
    @@ Path.load refile' in
  let fst_match = wrap_exn @@ fun () ->
    List.hd matches in
  "." ^ Re.Group.get fst_match 1

let output__sync~clock jsfile' =
  (* NOTE(kinten) the generation of [jsfile] is responsible by another process. it is expected to be "ready to use" when it finally exists as a file *)
  while not @@ Path.is_file jsfile'
  do Time.sleep clock 0.5 done

let run_liveserver~sw~procm dist_dir =
  Fiber.fork ~sw @@ fun () ->
  Pnpm.Process.run procm
    [ "live-server"
    ; "--cors"
    ; "--no-browser"
    ; Path.native_exn dist_dir; "8080"
    ]
