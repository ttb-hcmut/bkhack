open Js.Promise

let ( >>= ) = (x, f) => x |> then_(f)

let ( >!= ) = (x, f) => x |> catch(f)

let return  = resolve

let ( let* ) = ( >>= )
