open Eio

let log cwd = Path.(cwd / "log")

let mkdir ~sw ?(perm = 0o700) dirname filename f =
  Fiber.fork ~sw @@ fun () ->
  let newpath = Path.(dirname / filename) in
  Path.mkdir ~perm newpath;
  Switch.run @@ fun sw ->
  f sw newpath

exception Directory_doesnt_exist of string

let getdir dirname filename f =
  let newpath = Path.(dirname / filename) in
  if not @@ Path.is_directory newpath then raise @@ Directory_doesnt_exist (Path.native_exn newpath);
  f newpath

let () =
  Eio_main.run @@ fun env ->
  let cwd = Stdenv.cwd env
  and process_mgr = Stdenv.process_mgr env
  and physlink ~sw ~link_to x = Fiber.fork ~sw @@ fun () -> Buildlib.Path.physlink (Stdenv.process_mgr env) ~link_to x in
  Switch.run @@ fun sw ->
  let log =
  ( Fiber.fork_promise ~sw @@ fun () ->
    let id = Buildlib.idgen (Stdenv.clock env) in
    let newpath = Path.(log cwd / id) in
    Path.mkdirs ~perm:0o700 newpath; newpath
  ) in
  Path.rmtree ~missing_ok:true Path.(cwd / "dist__serve");
  ( mkdir ~sw cwd "dist__serve" @@ fun sw dist ->
    ( Fiber.fork ~sw @@ fun () ->
      Buildlib.Pnpm.Process.run process_mgr
        [ "live-server"
        ; "--cors"
        ; "--no-browser"
        ; Path.native_exn dist; "8080"
        ]
    );
    ( Fiber.fork ~sw @@ fun () ->
      let log = Promise.await_exn log in
      Path.with_open_out Path.(log / "index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
      Buildlib.Pnpm.Process.run process_mgr ~stdout
        [ "webpack"; "watch"
        ; "--config"; "build_aux/webpack_preprocessor.js"
        ; "--mode"; "development"
        ; "--entry"; Buildlib.Output.src "Page__app"
        ; "--output-path"; Path.native_exn dist
        ; "--output-filename"; "index.js"]
    );
    getdir (Stdenv.cwd env) "public" @@ fun public ->
    physlink ~sw ~link_to:Path.(public / "index.html") Path.(dist / "index.html");
    ( mkdir ~sw dist "assets" @@ fun sw dist__assets ->
      getdir public "assets" @@ fun public__assets ->
      physlink ~sw ~link_to:Path.(public__assets / "logo.svg") Path.(dist__assets / "logo.svg");
      physlink ~sw ~link_to:Path.(public__assets / "icon.pullrequest.violet.svg") Path.(dist__assets / "icon.pullrequest.violet.svg");
      physlink ~sw ~link_to:Path.(public__assets / "icon.comment.light-blue.svg") Path.(dist__assets / "icon.comment.light-blue.svg");
    );
    ( mkdir ~sw dist "item" @@ fun sw dist__item ->
      getdir public "item" @@ fun public__item ->
      physlink ~sw ~link_to:Path.(public__item / "index.html") Path.(dist__item / "index.html");
      ( Fiber.fork ~sw @@ fun () ->
        let log = Promise.await_exn log in
        Path.with_open_out Path.(log / "item__index.js.stdout") ~create:(`Exclusive 0o700) @@ fun stdout ->
        Buildlib.Pnpm.Process.run process_mgr ~stdout
          [ "webpack"; "watch"
          ; "--config"; "build_aux/webpack_preprocessor.js"
          ; "--mode"; "development"
          ; "--entry"; Buildlib.Output.src "Page__item"
          ; "--output-path"; Path.native_exn dist__item
          ; "--output-filename"; "index.js"]
      );
    );
    ( mkdir ~sw dist "styles" @@ fun sw dist__styles ->
      getdir public "styles" @@ fun public__styles ->
      physlink ~sw ~link_to:Path.(public__styles / "reset.css") Path.(dist__styles / "reset.css");
      physlink ~sw ~link_to:Path.(public__styles / "debug.css") Path.(dist__styles / "debug.css");
      physlink ~sw ~link_to:Path.(public__styles / "variables.css") Path.(dist__styles / "variables.css");
      ( mkdir ~sw dist__styles "components" @@ fun sw dist__styles__components ->
        getdir public__styles "components" @@ fun public__styles__components ->
        physlink ~sw ~link_to:Path.(public__styles__components / "headerbar.css") Path.(dist__styles__components / "headerbar.css");
        physlink ~sw ~link_to:Path.(public__styles__components / "grepbar.css") Path.(dist__styles__components / "grepbar.css");
      )
    )
  )
