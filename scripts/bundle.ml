open Eio

let ( %> ) f1 f2 = fun s -> f2 (f1 s)

let dist cwd = Path.(cwd / "dist")
let dist__indexhtml cwd = Path.(dist cwd / "index.html")
let dist__resetcss cwd = Path.(dist cwd / "reset.css")
let dist__debugcss cwd = Path.(dist cwd / "debug.css")
let dist__assets cwd = Path.(dist cwd / "assets")
let dist__assets__logosvg cwd = Path.(dist__assets cwd / "logo.svg")
let dist__item cwd = Path.(dist cwd / "item")
let dist__item__indexhtml cwd = Path.(dist__item cwd / "index.html")

let log cwd = Path.(cwd / "log")

let () =
  Eio_main.run @@ fun env ->
  let cwd = Stdenv.cwd env
  and process_mgr = Stdenv.process_mgr env
  in
  Switch.run @@ fun sw ->
  let log =
  ( Fiber.fork_promise ~sw @@ fun () ->
    (* Path.mkdir ~perm:0o700 (log cwd); *)
    let id = Buildlib.idgen (Stdenv.clock env) in
    let newpath = Path.(log cwd / id) in
    Path.mkdirs ~perm:0o700 newpath; newpath
  ) in
  Path.rmtree ~missing_ok:true (dist cwd);
  Path.mkdir ~perm:0o700 (dist cwd);
  ( Fiber.fork ~sw @@ fun () ->
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      let log = Promise.await_exn log in
      Path.with_open_out Path.(log / "index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
      Buildlib.Pnpm.Process.run process_mgr ~stdout
        [ "webpack"
        ; "--config"; "build_aux/webpack_preprocessor.js"
        ; "--mode"; "production"
        ; "--entry"; Buildlib.Output.src "App"
        ; "--output-path"; Path.native_exn @@ dist cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../public/index.html"
        (dist__indexhtml cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../public/reset.css"
        (dist__resetcss cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../public/debug.css"
        (dist__debugcss cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__assets cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/logo.svg"
        (dist__assets__logosvg cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__item cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      let log = Promise.await_exn log in
      Path.with_open_out Path.(log / "item__index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
      Buildlib.Pnpm.Process.run process_mgr ~stdout
        [ "webpack"
        ; "--config"; "build_aux/webpack_preprocessor.js"
        ; "--mode"; "production"
        ; "--entry"; Buildlib.Output.src "Item"
        ; "--output-path"; Path.native_exn @@ dist__item cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/item/index.html"
        (dist__item__indexhtml cwd) );
  )
