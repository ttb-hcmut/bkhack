[@@@module "%/../lib.ml"]
open Eio

let tmpfile_open' ~uuid cwd k =
  let filename = "__u__typst__compile__" ^ Uuidm.(uuid () |> to_string) in
  let e = k (Path.(cwd / filename)) in
  Path.unlink Path.(cwd / filename); e

let with_processed_file ~cwd ~article_at_root file k =
  let uuid = Uuidm.v4_gen (Random.State.make_self_init ()) in
  let file_content = Path.load @@ file cwd in
  let file_content = Lib.process ~article_at_root file_content in
  tmpfile_open' ~uuid cwd @@ fun input ->
  let () = Path.save ~create:(`Exclusive 0o700) input file_content in
  let () = k input in
  ()
