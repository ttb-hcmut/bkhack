open Eio
module P = Eio.Path
module type Sys = module type of Sys

module Transform =
  struct

  type 'a stg =
    | Init : [> `one ] stg
    | Step_one : [> `one ] stg -> [> `two ] stg
    | Step_two : [> `two ] stg -> [> `three ] stg
    | Step_three : [> `three ] stg -> [> `four ] stg

  let insert_after_el istarget ks = fun st it ->
    let istarget' u = 
      let (_, target_name), target_attribs = u in
      let target_attribs' = target_attribs |> List.map (function (_, k), v -> k, v) in
      istarget (target_name, target_attribs') in
    match (it, st) with
    | `Start_element u as it, (Init as st) when istarget' u -> [it], Some (Step_one st)
    | `End_element as it,     (Step_one _prev as st)        -> [it], Some (Step_two st)
    | `Start_element _ as it, (Step_two _prev as st)        ->
      let items = ks |> Iter.map @@ fun k ->
        let tagname, tagattribs = k in
        let tagattribs' = tagattribs |> List.map (fun (k, v) -> ("", k), v) in
        [`Start_element (("", tagname), tagattribs'); `End_element] in
      (items |> Iter.to_list |> List.flatten) @ [it], Some (Step_three st)
    | it, _ -> [it], Some st

  end

let highlighjs = function "script", ["src", "./lib/highlightjs-copy/highlightjs-copy.min.js"] -> true | _ -> false

let qdout cwd = P.(cwd / "quarkdown-output")

and _lib proj = P.(proj / "lib")

and proj qdout name = P.(qdout / name)

and index proj = P.(proj / "index.html")

and langdir cwd = P.(cwd / "languages")

let insert_libs langs = 
  langs |> Iter.map ( fun langpath -> "script", ["src", P.(native_exn langpath)] )

let load_langs cwd =
  let langdir = langdir cwd in
  Path.read_dir langdir |> Iter.of_list |> Iter.map (fun name -> P.(langdir / name))

let copy_lang_dir~sw~process_mgr cwd proj =
  Fiber.fork ~sw @@ fun () ->
  let from_ = langdir cwd and to_ = proj in
  Process.run process_mgr ["cp"; "-r"; "--force"; P.(native_exn from_); P.(native_exn to_)]

let replace_index~sw proj k =
  Fiber.fork ~sw @@ fun () ->
  let tree' = Markup.parse_html @@ Markup.string @@ Path.load (proj |> index) in
  let newtree = Markup.(tree' |> signals |> transform k Transform.Init |> write_html |> to_string) in
  Path.save ~create:`Never (proj |> index) newtree

let global_read () = ["--allow"; "global-read"]

let init~process_mgr command k =
  match List.nth command 1 with | "compile" ->
    Process.run process_mgr (command @ global_read ()); k ()
  | s -> failwith ("unsupported quarkdown command '"^s^"'")

let main (module Sys : Sys) env =
  let cwd = Stdenv.cwd env and process_mgr = Stdenv.process_mgr env in
  let command () = Sys.argv |> Array.to_list |> List.tl
  and langs = load_langs cwd and projls cwd =
    let qdout' = qdout cwd in
    Path.read_dir qdout' |> List.map (proj qdout') in
  init~process_mgr (command ()) @@ fun () ->
  projls cwd |> Fiber.List.iter @@ fun proj ->
  Switch.run @@ fun sw ->
  copy_lang_dir~sw~process_mgr cwd proj;
  replace_index~sw proj @@ Transform.insert_after_el highlighjs @@ insert_libs langs

let () =
  if !Sys.interactive then () else
  Eio_main.run @@ main (module Sys)
