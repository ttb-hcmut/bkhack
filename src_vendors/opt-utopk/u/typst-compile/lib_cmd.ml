[@@@module "%/../lib_io.ml" [@prefixed? "lib_"]]
open Cmdliner
open Eio

let () =
  Eio_main.run @@ fun env ->
  exit @@ Cmd.eval @@
  Cmd.make (Cmd.info "typst compile") @@
  let open Term.Syntax in
  let+ file = Arg.(required & pos 0 (some path) None & info []) |> Term.map(fun x cwd -> Path.(cwd / x))
  and+ root = Arg.(value & opt (some path) None & info ["root"]) |> Term.map(Option.map(fun x fs -> Path.(fs / x)))
  and+ package_path = Arg.(value & opt (some path) None & info ["package-path"]) |> Term.map(Option.map(fun x fs -> Path.(fs / x))) in
  let cwd, fs, procm = Stdenv.(cwd env, fs env, process_mgr env) in
  Io.with_processed_file ~cwd file @@ fun file ->
  Process.run procm begin
    ["typst"; "compile"]
    @ Option.value ~default:[] (root |> Option.map(fun root -> ["--root"; Path.native_exn @@ root fs]))
    @ Option.value ~default:[] (package_path |> Option.map(fun it -> ["--package-path"; Path.native_exn @@ it fs]))
    @ [Path.native_exn file]
  end
