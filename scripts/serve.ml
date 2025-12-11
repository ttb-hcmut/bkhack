open Eio

let dist cwd = Path.(cwd / "dist__serve")
let dist__indexhtml cwd = Path.(dist cwd / "index.html")
let dist__resetcss cwd = Path.(dist cwd / "reset.css")
let dist__debugcss cwd = Path.(dist cwd / "debug.css")
let dist__assets cwd = Path.(dist cwd / "assets")
let dist__assets__logosvg cwd = Path.(dist__assets cwd / "logo.svg")
let dist__assets__icon__pullrequestvioletsvg cwd = Path.(dist__assets cwd / "icon.pullrequest.violet.svg")
let dist__assets__icon__commentlightbluesvg cwd = Path.(dist__assets cwd / "icon.comment.light-blue.svg")
let dist__item cwd = Path.(dist cwd / "item")
let dist__item__indexhtml cwd = Path.(dist__item cwd / "index.html")

let public cwd = Path.(cwd / "public")
let public__indexhtml cwd = Path.(public cwd / "index.html")
let public__resetcss cwd = Path.(public cwd / "reset.css")
let public__debugcss cwd = Path.(public cwd / "debug.css")
let public__assets cwd = Path.(public cwd / "assets")
let public__assets__logosvg cwd = Path.(public__assets cwd / "logo.svg")
let public__assets__icon__pullrequestvioletsvg cwd = Path.(public__assets cwd / "icon.pullrequest.violet.svg")
let public__assets__icon__commentlightbluesvg cwd = Path.(public__assets cwd / "icon.comment.light-blue.svg")
let public__item cwd = Path.(public cwd / "item")
let public__item__indexhtml cwd = Path.(public__item cwd / "index.html")

let log cwd = Path.(cwd / "log")

let () =
  Eio_main.run @@ fun env ->
  let cwd = Stdenv.cwd env
  and process_mgr = Stdenv.process_mgr env
  and physlink = Buildlib.Path.physlink (Stdenv.process_mgr env) in
  Switch.run @@ fun sw ->
  let log =
  ( Fiber.fork_promise ~sw @@ fun () ->
    let id = Buildlib.idgen (Stdenv.clock env) in
    let newpath = Path.(log cwd / id) in
    Path.mkdirs ~perm:0o700 newpath; newpath
  ) in
  Path.rmtree ~missing_ok:true (dist cwd);
  Path.mkdir ~perm:0o700 (dist cwd);
  ( Fiber.fork ~sw @@ fun () ->
    Buildlib.Pnpm.Process.run process_mgr
      [ "live-server"
      ; "--cors"
      ; "--no-browser"
      ; "dist__serve"; "8080"
      ]
  );
  ( Fiber.fork ~sw @@ fun () ->
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      let log = Promise.await_exn log in
      Path.with_open_out Path.(log / "index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
      Buildlib.Pnpm.Process.run process_mgr ~stdout
        [ "webpack"; "watch"
        ; "--config"; "build_aux/webpack_preprocessor.js"
        ; "--mode"; "development"
        ; "--entry"; Buildlib.Output.src "App"
        ; "--output-path"; Path.native_exn @@ dist cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__indexhtml cwd)
        (dist__indexhtml cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__resetcss cwd)
        (dist__resetcss cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__debugcss cwd)
        (dist__debugcss cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__assets cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__assets__logosvg cwd)
        (dist__assets__logosvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__assets__icon__pullrequestvioletsvg cwd)
        (dist__assets__icon__pullrequestvioletsvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__assets__icon__commentlightbluesvg cwd)
        (dist__assets__icon__commentlightbluesvg cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__item cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      let log = Promise.await_exn log in
      Path.with_open_out Path.(log / "item__index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
      Buildlib.Pnpm.Process.run process_mgr ~stdout
        [ "webpack"; "watch"
        ; "--config"; "build_aux/webpack_preprocessor.js"
        ; "--mode"; "development"
        ; "--entry"; Buildlib.Output.src "Item"
        ; "--output-path"; Path.native_exn @@ dist__item cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      physlink ~link_to:(public__item__indexhtml cwd)
        (dist__item__indexhtml cwd) );
  )

