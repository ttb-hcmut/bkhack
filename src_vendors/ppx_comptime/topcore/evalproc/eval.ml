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

let strip_quotes =
  let u = Re.exec @@ Re.compile @@ Re.(seq [bos; char '"'; group @@ greedy @@ rep @@ any; char '"'; eos]) in
  u %> (fun x -> Re.Group.get x 1)

let parse ~loc (t : ir) =
  let dtype, v = t in
  let open Ppxlib in
  let (module A) = Ast_builder.make loc in
  match dtype with
  | "string" -> A.estring @@ strip_quotes @@ v
  | "int"    -> begin try A.eint (int_of_string v) with Failure _ -> raise (Failure (Printf.sprintf "was trying to convert '%s'" v)) end
  | e -> failwith ("not yet '"^e^"'")

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
  (* (let s = content in Out_channel.with_open_text "err3.log" @@ fun o -> Printf.fprintf o "%s" s); *)
  File.write_exn tempfile content;
  let err = ref "" in
  begin try
  extract2 @@
  (fun s -> err := s; (* Out_channel.with_open_text "err2.log" @@ fun o -> Printf.fprintf o "%s" s; *) s) @@
  extract @@
  (fun s -> err := s; (* Out_channel.with_open_text "err1.log" @@ fun o -> Printf.fprintf o "%s" s; *) s) @@
  run (
    Printf.sprintf "TEST=%s sh -c '%s < %s'"
      (Sys.getenv "TEST") args tempfile
  )
  with Not_found -> raise (Failure (Printf.sprintf "%s" !err))
  end
