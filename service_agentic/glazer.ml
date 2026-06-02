open Eio

let () =
	Eio_main.run @@ fun _env ->
	traceln "hello world!"
