let onKeyDown : React.Event.Keyboard.t => unit

[@alert experimental("view-level transitions should not load new page")]
module Make : (_ : { [@react.component] let make : unit => React.element }) => { [@react.component] let make : unit => React.element }

[@alert experimental("view-level transitions should not load new page")]
module Make2 : (_ : { let querySelector : unit => Dom.element; }, _ : { [@react.component] let make : unit => React.element }) => { [@react.component] let make : unit => React.element }
