open Eio

let dist cwd = Path.(cwd / "dist")
let dist__indexhtml cwd = Path.(dist cwd / "index.html")
let dist__assets cwd = Path.(dist cwd / "assets")
let dist__assets__logosvg cwd = Path.(dist__assets cwd / "logo.svg")
let dist__assets__icon__pullrequestvioletsvg cwd = Path.(dist__assets cwd / "icon.pullrequest.violet.svg")
let dist__assets__icon__pullrequestgreensvg cwd = Path.(dist__assets cwd / "icon.pullrequest.green.svg")
let dist__assets__icon__commentlightbluesvg cwd = Path.(dist__assets cwd / "icon.comment.light-blue.svg")
let dist__assets__icon__documentcyansvg cwd = Path.(dist__assets cwd / "icon.document.cyan.svg")
let dist__assets__icon__timebackvioletsvg cwd = Path.(dist__assets cwd / "icon.timeback.violet.svg")
let dist__item cwd = Path.(dist cwd / "item")
let dist__item__indexhtml cwd = Path.(dist__item cwd / "index.html")
let dist__styles cwd = Path.(dist cwd / "styles")
let dist__styles__resetcss cwd = Path.(dist__styles cwd / "reset.css")
let dist__styles__debugcss cwd = Path.(dist__styles cwd / "debug.css")
let dist__styles__variablescss cwd = Path.(dist__styles cwd / "variables.css")
let dist__styles__components cwd = Path.(dist__styles cwd / "components")
let dist__styles__components__commandcss cwd = Path.(dist__styles__components cwd / "command.css")
let dist__styles__components__headerbarcss cwd = Path.(dist__styles__components cwd / "headerbar.css")
let dist__styles__components__grepbarcss cwd = Path.(dist__styles__components cwd / "grepbar.css")

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
        ; "--entry"; Buildlib.Output.src "Page__app"
        ; "--output-path"; Path.native_exn @@ dist cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../public/index.html"
        (dist__indexhtml cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__assets cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/logo.svg"
        (dist__assets__logosvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/icon.pullrequest.violet.svg"
        (dist__assets__icon__pullrequestvioletsvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/icon.pullrequest.green.svg"
        (dist__assets__icon__pullrequestgreensvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/icon.comment.light-blue.svg"
        (dist__assets__icon__commentlightbluesvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/icon.document.cyan.svg"
        (dist__assets__icon__documentcyansvg cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/assets/icon.timeback.violet.svg"
        (dist__assets__icon__timebackvioletsvg cwd) );
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
        ; "--entry"; Buildlib.Output.src "Page__item"
        ; "--output-path"; Path.native_exn @@ dist__item cwd
        ; "--output-filename"; "index.js"]
    );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/item/index.html"
        (dist__item__indexhtml cwd) );
  );
  ( Fiber.fork ~sw @@ fun () ->
    Path.mkdir ~perm:0o700 (dist__styles cwd);
    Switch.run @@ fun sw ->
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/styles/reset.css"
        (dist__styles__resetcss cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/styles/debug.css"
        (dist__styles__debugcss cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.symlink ~link_to:"../../public/styles/variables.css"
        (dist__styles__variablescss cwd) );
    ( Fiber.fork ~sw @@ fun () ->
      Path.mkdir ~perm:0o700 (dist__styles__components cwd);
      Switch.run @@ fun sw ->
      ( Fiber.fork ~sw @@ fun () ->
        Path.symlink ~link_to:"../../../public/styles/components/command.css"
          (dist__styles__components__commandcss cwd) );
      ( Fiber.fork ~sw @@ fun () ->
        Path.symlink ~link_to:"../../../public/styles/components/headerbar.css"
          (dist__styles__components__headerbarcss cwd) );
      ( Fiber.fork ~sw @@ fun () ->
        Path.symlink ~link_to:"../../../public/styles/components/grepbar.css"
          (dist__styles__components__grepbarcss cwd) );
    )
  )
