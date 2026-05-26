open Eio
module Pnpm = Buildlib.Pnpm
module P = Path
module B = Buildlib

exception Missing_mapping_entry_for of string

let public_dir cwd = P.(cwd / "public")
and generative_dir cwd = P.(cwd / "generative")
and dist_dir cwd = P.(cwd / "dist__serve")
and src_dir cwd = P.(cwd / "src")
and log_dir cwd = P.(cwd / "log")

let attrib_name = Re.(
  alt [str "page"; str "Bkhack.page"])

(** preview the [morphism]s at [dist_dir] *)
let pv_morphism~sw~procm dist_dir =
  B.run_liveserver~sw~procm dist_dir

(** a [morphism] for JavaScript bundles *)
let morphism_jspages~sw~procm~clock~cwd ?watch src_dir dist_dir log_dir =
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
  B.compile_jsfile~procm~clock ?watch out_dir log_dir jsfile'

(** a [morphism] for linking static-content files from public dir
    (and other sources) to dist dir *)
let morphism_static~sw~procm public_dir dist_dir () =
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
  [] |> iter ~ondir:iter_ondir @@ fun fpath_at_public ->
  let path_it = String.concat "/" fpath_at_public in
  B.Path.physlink~sw procm 
    P.(dist_dir / path_it)
    ~link_to:P.(public_dir / path_it)

let morphism_generative~sw~procm generative_dir dist_dir =
  let at_dir dir k = Path.mkdirs ~exists_ok:true ~perm:0o700 dir; k () in
  let create_index name candidates =
    let content = candidates |> List.map (Printf.sprintf {|@import "/%s";|}) |> String.concat "\n" in
    Path.save ~create:(`Exclusive 0o700) P.(dist_dir / name) content in
  at_dir generative_dir @@ fun () ->
  let candidates = Path.read_dir generative_dir |> List.filter(fun x -> Filename.extension x = ".css") in
  at_dir dist_dir @@ fun () ->
  create_index "generative.css" candidates;
  candidates |> Fiber.List.iter @@ fun path_it ->
    B.Path.physlink~sw procm
      P.(dist_dir / path_it)
      ~link_to:P.(generative_dir / path_it)

(** [Serve] will run a series of [morphism]s (some are persistent
    while some are not) on the repository to finally arrive at an
    output at [dist_dir].

    TODO(kinten) provides guide

    @raise Missing_mapping_entry_for(pagefile) when a Reason page
    file did not specify a required `[@Bkhack.page s]` attribute.
    Refer to the guide for more details. *)
let main__ ~watch ?(dist_dir = dist_dir) () =
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
  pv_morphism~sw~procm dist_dir;
  morphism_jspages~sw~procm~clock~cwd ~watch src_dir dist_dir log_dir;
  morphism_static~sw~procm public_dir dist_dir ();
  morphism_generative~sw~procm generative_dir dist_dir

open Cmdliner
open Term.Syntax

let main__ () =
  Cmd.v (Cmd.info "bkhack.serve" ~doc:"") @@
  let+ watch = Arg.(required & opt (some bool) None &
    info ["watch"; "w"] ~docv:" Will the JavaScript compiler watch for file changes to hot-reload? ")
  and+ dist_dir = Arg.(required & opt (some string) None &
    info ["output"; "o"] ~docv:" Output directory, containing deployable web bundle artifact. ")
    |> Term.map Path.(fun it cwd -> cwd / it)
  in main__ ~watch ~dist_dir ()

(** autorun except in toplevel / interactive mode *)
let () =
  if !Sys.interactive then () else
  exit @@ Cmd.eval @@ main__ ()
