module Output = struct
  let src x =
    "./_build/default/src/output/src/" ^ x ^ ".js"
end

module Path = struct
  open Eio

  let physlink ~sw process_mgr ~link_to file =
    Fiber.fork ~sw @@ fun () ->
    Process.run
      process_mgr
      ["ln"; Path.native_exn link_to; Path.native_exn file]

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

end

module Pnpm = struct
  module Process = struct
    let run process_mgr ?stdout ?stdin ?stderr cmd =
      Eio.Process.run process_mgr ?stdout ?stdin ?stderr @@ "pnpm" :: "exec" :: cmd
  end
end

let idgen clock =
  Eio.Time.now clock |> Float.to_int |> Int.to_string
