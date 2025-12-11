module Output = struct
  let src x =
    "./_build/default/src/output/src/" ^ x ^ ".js"
end

module Path = struct
  open Eio

  let physlink process_mgr ~link_to file =
    Process.run
      process_mgr
      ["ln"; Path.native_exn link_to; Path.native_exn file]
end

module Pnpm = struct
  module Process = struct
    let run process_mgr ?stdout ?stdin ?stderr cmd =
      Eio.Process.run process_mgr ?stdout ?stdin ?stderr @@ "pnpm" :: "exec" :: cmd
  end
end

let idgen clock =
  Eio.Time.now clock |> Float.to_int |> Int.to_string
