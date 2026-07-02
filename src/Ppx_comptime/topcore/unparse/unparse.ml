open Ppxlib

let toplevel_phrase x =
  let buffer = Buffer.create 100 in
  let noformatter = Format.formatter_of_buffer buffer in
  Pprintast.top_phrase noformatter x;
  Buffer.contents buffer

module Ast = Ast_helper

let __expression_wrapped =
  let remove_letx =
    let pattern =
      let open Re in
      seq [str "let x =" ; group (any |> rep) ; str ";;"]
      |> compile in
    Re.replace
      ~all:true
      ~f:(fun groups -> Re.Group.get groups 1)
      pattern in
  fun x ->
  let buffer = Buffer.create 100 in
  let noformatter = Format.formatter_of_buffer buffer in
  Pprintast.top_phrase noformatter begin Ptop_def Ast.[
    Str.value Asttypes.Nonrecursive
    [ Vb.mk
      (Pat.var { txt = "x" ; loc = !default_loc })
      x
    ]
  ] end;
  Buffer.contents buffer
  |> remove_letx

let expression = __expression_wrapped

module Debug = Debug
