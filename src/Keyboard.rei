open Decorator

let onKeyDown : React.Event.Keyboard.t => unit

module Mneumonics {
	open React

	module type Window {
		let add_event_listener: (string, Event.Keyboard.t => unit) => unit
		let remove_event_listener: (string, Event.Keyboard.t => unit) => unit
	}

	let use : (module Window) => (string => option(Event.Keyboard.t => unit)) => unit
}

module Make : (_ : Component) => Component

module Make2 : (_ : { let querySelector : unit => Dom.element; }, _ : Component) => Component
