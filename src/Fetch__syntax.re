open Js.Promise

let ( >>= ) = (x, f) => x |> then_(f)

let ( >!= ) = (x, f) => x |> catch(f)

let return  = resolve

let ( let* ) = ( >>= )

// let setJWTCookie = (json:Js.Json.t) => {
//   Js__dom.Document.cookie_set(
//     `jwttoken=${json |> Js.Json.stringify |> Js.Global.encodeURIComponent}`
//   )
// }