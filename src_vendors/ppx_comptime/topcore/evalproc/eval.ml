open Ppx_comptime__topcore__module_name
open Ppx_comptime__topcore__unparse

let sprintf = Printf.sprintf

exception Bad_evaluation of Ppxlib.expression

module File = IO.File
module type SYS = module type of Sys
module type FILE = module type of File

let run cmd =
  let inp = Unix.open_process_in cmd in
  let r = In_channel.input_all inp in
  In_channel.close inp; r

type ir = string * string

let extract =
  Re.replace ~all:true
  ~f:(fun gr -> Re.Group.get gr 1
  ) @@ Re.compile @@
  let open Re in
  seq[
    any |> rep1 |> shortest;
    char '\n'; str "- : "; group (any |> rep1 |> shortest); char '\n';
    any |> rep;
  ]

let extract2 : string -> ir =
  ( Re.exec @@ Re.compile @@
    let open Re in
    seq[
      bos; group (any |> rep1 |> shortest); str " = "; group (any |> rep1 |> shortest); eos
    ]
  )
  %> (fun gr -> (Re.Group.get gr 1, Re.Group.get gr 2))

let is_error =
  Re.execp @@ Re.compile @@ Re.(alt [str "Exception"; str "Error"; str "Invalid"])

let strip_quotes =
  let u = Re.exec @@ Re.compile @@ Re.(seq [bos; char '"'; group @@ greedy @@ rep @@ any; char '"'; eos]) in
  u %> (fun x -> Re.Group.get x 1)

exception Unknown_value_serialization_of_type of string

let parse ~loc (t : ir) =
  let dtype, v = t in
  let open Ppxlib in
  let (module A) = Ast_builder.make loc in
  match dtype with
  | "string" -> A.estring @@ strip_quotes @@ v
  | "float"  -> A.efloat  @@ v
  | "unit"   -> A.pexp_construct { loc; txt = Lident "()" } None
  | "bool"   -> A.ebool   @@ bool_of_string v
  | "int"    -> begin try A.eint (int_of_string v) with Failure _ -> raise (Failure (Printf.sprintf "was trying to convert '%s'" v)) end
  | e -> raise @@ Unknown_value_serialization_of_type e

exception Program_exception of string

let test_strip =
  let ws = Re.(alt [char ' '; char '\n'; char '\t']) in
  let f = fun g -> Re.Group.get g 1 in
  Re.replace ~all:true ~f @@ Re.compile @@ Re.(seq [str "OCaml version 5.2.0
Enter #help;; for help.

#"; ws |> rep; group (any |> rep); ws |> rep |> greedy])

let expression
~process_mgr:(module Sys : SYS) ~fs:(module File : FILE)
?args:(args="utop") ?init:(init=(Ppxlib.Ptop_def []))
?metadata
pdir_arg : ir =
  let prefix = metadata
    |> Option.map (function path, () ->
    sprintf "FILE-%s-LINE-%s-"
      (path |> Module_name.escape_lash)
      Ppxlib.(pdir_arg.pexp_loc.loc_start.pos_lnum |> Int.to_string)
    )
    |> Option.value ~default:""
    in
  File.with_temp ~prefix ~suffix:"" @@ fun tempfile ->
  ignore init;
  let content =
    sprintf {|%s;;|}
      (Unparse.expression pdir_arg)
    in
  File.write_exn tempfile content;
  let res = run (
    Printf.sprintf "TEST=%s sh -c '%s < %s'"
      (Sys.getenv "TEST") args tempfile) in
  if is_error res then raise (Program_exception (res |> test_strip)) else
  let part1 = extract res in
  let part2 = extract2 part1 in
  part2
