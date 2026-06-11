open Eio
module Pnpm = Buildlib.Pnpm
module P = Path
module B = Buildlib

exception Missing_mapping_entry_for of string

let attrib_name = Re.(
  alt [str "page"; str "Bkhack.page"])

(** a [morphism] for JavaScript bundles *)
let morphism_jspages~sw~procm~clock~cwd ~optimization ?watch src_dir ?log_dir dist_dir =
  Fiber.fork ~sw @@ fun () ->
  let jspages =
    List.filter_map (B.is_page' src_dir)
    @@ Path.read_dir src_dir in
  let output_dirs =
    jspages |> Fiber.List.map @@ fun x' ->
    let `fpath refile', `fname refile, _ = x' in
    let jsfile  = B.Output.src' @@ Filename.chop_extension refile in
    let jsfile' = P.(cwd / jsfile) in
    let out_dir =
      try B.file_grep_attrib attrib_name refile'
      with Not_found -> raise @@ Missing_mapping_entry_for refile in
    out_dir^"/index", jsfile' in
  B.compile_jsfile'~procm~clock~cwd ?watch ~optimization dist_dir ?log_dir output_dirs

(** a [morphism] for lucide icons *)
let morphism_lucide~sw~procm lucide_dir dist_dir =
  let icons_dir = P.(lucide_dir / "icons") in
  B.Path.copy_dir~sw~procm icons_dir P.(dist_dir / "icons")
  [@@warning "-32"]

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
let main__ ~watch ~dist_dir ~src_dir ~public_dir ~generative_dir ~log_dir ~lucide_dir ~verbose ~optimization () =
  Eio_main.run @@ fun env ->
  let procm, clock, cwd, fs =
    Stdenv.process_mgr env, Stdenv.clock env, Stdenv.cwd env, Stdenv.fs env in
  let public_dir, generative_dir, dist_dir, log_dir, src_dir, lucide_dir =
    public_dir cwd, generative_dir fs, dist_dir cwd, (if not verbose then Some (log_dir cwd) else None), src_dir cwd, lucide_dir fs in
  Switch.run @@ fun sw ->
  morphism_jspages~sw~procm~clock~cwd ~optimization ~watch src_dir ?log_dir dist_dir;
  morphism_static~sw~procm public_dir dist_dir ();
  morphism_generative~sw~procm generative_dir dist_dir;
  morphism_lucide~sw~procm lucide_dir dist_dir

open Cmdliner
open Term.Syntax

let main__ () =
  Cmd.v (Cmd.info "webpackgen" ~doc:"") @@
  let log_dir cwd = P.(cwd / "log") in
  let+ dist_dir = Arg.(required & opt (some string) None &
    info ["output"; "o"] ~doc:" Output directory, containing deployable web bundle artifact. ")
    |> Term.map Path.(fun it cwd -> cwd / it)
  and+ src_dir = Arg.(required & opt (some string) None &
    info ["src_dir"] ~doc:" Source directory. ")
    |> Term.map Path.(fun it cwd -> cwd / it)
  and+ public_dir = Arg.(required & opt (some string) None &
    info ["public_dir"] ~doc:" Static asset directory. ")
    |> Term.map Path.(fun it cwd -> cwd / it)
  and+ generative_dir = Arg.(required & opt (some string) None &
    info ["generative_dir"] ~doc:" Generative asset directory. ")
    |> Term.map Path.(fun it fs -> fs / it)
  and+ lucide_dir = Arg.(required & opt (some string) None &
    info ["lucide_dir"] ~doc:" (DEPRECATED) Lucide icon directory. ")
    |> Term.map Path.(fun it fs -> fs / it)
  and+ verbose = Arg.(required & opt (some bool) None &
    info ["verbose"] ~docv:"VERBOSE")
  and+ optimization = Arg.(required & opt (some @@ enum ["dev", `Development; "prod", `Production]) None &
    info ["optimization"; "O"] ~docv:"OPTIMIZATION")
  in main__ ~watch:false ~dist_dir ~src_dir ~public_dir ~generative_dir ~log_dir ~lucide_dir ~verbose ~optimization ()

(** autorun except in toplevel / interactive mode *)
let () =
  if !Sys.interactive then () else
  exit @@ Cmd.eval @@ main__ ()
