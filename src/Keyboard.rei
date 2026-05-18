open Decorator

let onKeyDown : React.Event.Keyboard.t => unit

module Make : (_ : Component) => Component

module Make2 : (_ : { let querySelector : unit => Dom.element; }, _ : Component) => Component
