open Eio
module Pnpm = Buildlib.Pnpm
module P =
  struct
  include Path
  end
module B = Buildlib

exception Missing_mapping_entry_for of string

let public_dir cwd = P.(cwd / "public")
and generative_dir cwd = P.(cwd / "generative")
and dist_dir cwd = P.(cwd / "dist")
and src_dir cwd = P.(cwd / "src")
and log_dir cwd = P.(cwd / "log")

let attrib_name = Re.(
  alt [str "page"; str "Bkhack.page"])

(** a [morphism] for JavaScript bundles *)
let morphism_jspages~sw~procm~clock~cwd src_dir dist_dir log_dir =
  let jspages =
    List.filter_map (B.is_page' src_dir)
    @@ Path.read_dir src_dir in
  Fiber.fork ~sw @@ fun () ->
  jspages |> Fiber.List.iter @@ fun x' ->
  let `fpath refile', `fname refile, _ = x' in
  let jsfile = B.Output.src @@ Filename.chop_extension refile in
  let jsfile' = P.(cwd / jsfile) in
  let out_dir =
    try P.(dist_dir / B.file_grep_attrib attrib_name refile')
    with Not_found -> raise @@ Missing_mapping_entry_for refile in
  B.output__sync~clock jsfile';
  B.compile_jsfile~procm~clock out_dir log_dir jsfile'

(** a [morphism] for linking static-content files from public dir
    (and other sources) to dist dir *)
let morphism_static ~sw public_dir dist_dir () =
  let rec iter f ~ondir (rootdir: string list) =
    let items = Path.read_dir P.(public_dir / String.concat "/" rootdir) in
    ondir @@ String.concat "/" rootdir;
    items |> Fiber.List.iter @@ fun it ->
    let it' = rootdir @ [it] in
    if Path.is_directory P.(public_dir / String.concat "/" it')
    then iter f ~ondir it' else f it' in
  let iter_ondir dirpath_at_public =
    let dirpath_at_dist = P.(dist_dir / dirpath_at_public) in
    Path.mkdirs ~exists_ok:true ~perm:0o700 dirpath_at_dist in
  Fiber.fork ~sw @@ fun () ->
  Switch.run @@ fun sw ->
  [] |> iter ~ondir:iter_ondir @@ fun fpath_at_public ->
  let path_it = String.concat "/" fpath_at_public in
  B.Path.symlink~sw 
    P.(dist_dir / path_it)
    ~link_to:P.(public_dir / path_it)

let morphism_generative~sw generative_dir dist_dir =
  let at_dir dir k = Path.mkdirs ~exists_ok:true ~perm:0o700 dir; k () in
  let create_index name candidates =
    let content = candidates |> List.map (Printf.sprintf {|@import "/%s";|}) |> String.concat "\n" in
    Path.save ~create:(`Exclusive 0o700) P.(dist_dir / name) content in
  at_dir generative_dir @@ fun () ->
  let candidates = Path.read_dir generative_dir |> List.filter(fun x -> Filename.extension x = ".css") in
  at_dir dist_dir @@ fun () ->
  create_index "generative.css" candidates;
  candidates |> Fiber.List.iter @@ fun path_it ->
    B.Path.symlink~sw
      P.(dist_dir / path_it)
      ~link_to:P.(generative_dir / path_it)

let () =
  Eio_main.run @@ fun env ->
  let procm, clock, cwd =
    Stdenv.process_mgr env, Stdenv.clock env, Stdenv.cwd env in
  let public_dir, generative_dir, dist_dir, log_dir, src_dir =
    public_dir cwd, generative_dir cwd, dist_dir cwd, log_dir cwd, src_dir cwd in
  let cleantree () =
    let missing_ok = true in
    Path.rmtree ~missing_ok dist_dir in
  Switch.run @@ fun sw ->
  cleantree ();
  morphism_jspages~sw~procm~clock~cwd src_dir dist_dir log_dir;
  morphism_static~sw public_dir dist_dir ();
  morphism_generative~sw generative_dir dist_dir
