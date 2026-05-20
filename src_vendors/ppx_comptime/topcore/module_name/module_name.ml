(* TODO(kinten) reuse B0's mangling *)

let escape_lash =
  let pattern =
    let open Re in
    str "/" |> compile in
  Re.replace pattern
    ~all:true ~f:begin fun _ ->
      "%%"
    end

let dot_to_underscore =
  let pattern =
    let open Re in
    char '.'
    |> compile in
  Re.replace ~all:true
    ~f:(fun _ -> "__")
    pattern

let dash_nstuff_to_underscore =
  let pattern =
    let open Re in
    char '-'
    |> compile in
  Re.replace ~all:true
    ~f:(fun _ -> "_")
    pattern

module type SYS = module type of Sys

let tilde_substitute (module Sys : SYS) =
  let re =
    let open Re in
    char '~'
    |> compile
  and by = Sys.getenv "HOME"
  in
  function str ->
  Re.replace_string ~all:true re ~by str

let percent_substitute =
  let re =
    let open Re in
    str "%/.."
    |> compile
  in
  fun file str ->
  let by = Filename.dirname file in
  Re.replace_string ~all:true re ~by str

let fixlib ~target barename = match barename with
  | "lib" ->
    let barename =
      target
      |> Filename.dirname
      |> Filename.basename
      (* |> Filename.remove_extension *)
      |> dash_nstuff_to_underscore
      |> dot_to_underscore
    in
    ( match (String.sub barename 0 3) with
    | "lib" -> String.sub barename 3 (String.length barename - 3)
    | _     -> barename
    )
  | _ as barename -> barename

let mangle target =
  target
  |> Filename.basename
  |> Filename.remove_extension
  |> dash_nstuff_to_underscore
  |> dot_to_underscore
  |> fixlib ~target
  |> String.capitalize_ascii
