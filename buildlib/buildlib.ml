module P =
  struct
  include Eio.Path
  end

module Output = struct
  let src x =
    "./_build/default/src/output/src/" ^ x ^ ".js"
end

module Path = struct
  open Eio

  let physlink ~sw process_mgr ~link_to file =
    Fiber.fork ~sw @@ fun () ->
    Process.run
      process_mgr
      ["ln"; Path.native_exn link_to; Path.native_exn file]

  let mkdir ~sw ?(perm = 0o700) dirname filename f =
    Fiber.fork ~sw @@ fun () ->
    let newpath = Path.(dirname / filename) in
    Path.mkdir ~perm newpath;
    Switch.run @@ fun sw ->
    f sw newpath

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

(** TODO(kinten) grep from AST! *)
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
