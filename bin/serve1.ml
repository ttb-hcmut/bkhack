open Eio
module Pnpm = Buildlib.Pnpm
module P = Path
module B = Buildlib

(** preview the [morphism]s at [dist_dir] *)
let pv_morphism~sw~procm dist_dir =
  B.run_liveserver~sw~procm dist_dir

let main__ ~dist_dir () =
  Eio_main.run @@ fun env ->
  let procm, cwd =
    Stdenv.process_mgr env, Stdenv.cwd env in
  let dist_dir = dist_dir cwd in
  Switch.run @@ fun sw ->
  pv_morphism~sw~procm dist_dir;

open Cmdliner
open Term.Syntax

let main__ () =
  Cmd.v (Cmd.info "bkhack.serve1" ~doc:"") @@
  let+ dist_dir = Arg.(required & opt (some string) None &
    info ["output"; "o"] ~docv:" Output directory, containing deployable web bundle artifact. ")
    |> Term.map Path.(fun it cwd -> cwd / it)
  in main__ ~dist_dir ()

(** autorun except in toplevel / interactive mode *)
let () =
  if !Sys.interactive then () else
  exit @@ Cmd.eval @@ main__ ()
