let onKeyDown : React.Event.Keyboard.t => unit

module Make : (_ : { [@react.component] let make : unit => React.element }) => { [@react.component] let make : unit => React.element }
