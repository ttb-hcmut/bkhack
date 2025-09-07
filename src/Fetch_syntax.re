open Js.Promise

let ( >>= ) = (x, f) => x |> then_(f)

and ( >!= ) = (x, f) => x |> catch(f)

and return  = resolve
