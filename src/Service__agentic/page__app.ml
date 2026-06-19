open Core
(* open Bonsai.Let_syntax *)
open Bonsai_web

let component =
  Bonsai.Computation.return @@
  Vdom.Node.div
    [ Vdom.Node.text "hello exact! how are you?" ]

let () =
  Async_js.init ();
  Bonsai_web.Start.start component
