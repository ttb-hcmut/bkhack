open React

/* NOTE(kinten) [document.activeElement] must be declared exactly HERE and used exactly WITHIN this module. */
[@mel.scope "document"] external active_element : Js.t(_) = "activeElement";

[@alert deprecated("use useRef instead of querySelector")]
let onKeyDown = e => {
	let key = Event.Keyboard.key(e);
	let unfocused = active_element === (Js__dom.Document.query_selector("body") |> Js.Nullable.toOption |> Option.get);
	let xs = Js.Array.from @@ Js__dom.Document.query_selector_all("#root > main > ol > li > header > a");
	let i = Array.find_index(x => x === active_element, xs);
	let in_list = Option.is_some(i);
	switch (key) {
	| "`" => {
		let sitenav = ReactDOM.querySelector("#siteNavigator")->Option.get->ReactDOM.domElementToObj;
		Event.Keyboard.stopPropagation(e);
		Event.Keyboard.preventDefault(e);
		sitenav##focus ();
	}
	| "j" when unfocused || in_list => {
		switch (i) {
			| None => {
				let el = ReactDOM.querySelector("#root > main > ol > li:first-child > header > a")->Option.get->ReactDOM.domElementToObj;
				Event.Keyboard.stopPropagation(e);
				Event.Keyboard.preventDefault(e);
				el##focus ();
			}
			| Some(i) when i === xs->Array.length - 1 => ()
			| Some(i) => {
				let el = ReactDOM.querySelector("#root > main > ol > li:nth-child("++string_of_int(i+2)++") > header > a")->Option.get->ReactDOM.domElementToObj;
				Event.Keyboard.stopPropagation(e);
				Event.Keyboard.preventDefault(e);
				el##focus ();
			}
		}
		
	}
	| "k" when unfocused || in_list => {
		switch (i) {
			| None => ()
			| Some(i) when i === 0 => ()
			| Some(i) => {
				let el = ReactDOM.querySelector("#root > main > ol > li:nth-child("++string_of_int(i)++") > header > a")->Option.get->ReactDOM.domElementToObj;
				Event.Keyboard.stopPropagation(e);
				Event.Keyboard.preventDefault(e);
				el##focus ();
			}
		}
		
	}
	| "Escape" => {
		let sitenav = ReactDOM.querySelector("#siteNavigator")->Option.get->ReactDOM.domElementToObj;
		Event.Keyboard.stopPropagation(e);
		Event.Keyboard.preventDefault(e);
		sitenav##blur ();
		i |> Option.iter(i => {
			let el = ReactDOM.querySelector("#root > main > ol > li:nth-child("++string_of_int(i+1)++") > header > a")->Option.get->ReactDOM.domElementToObj;
			el##blur();
		});
	}
	| _ => ()
	}
};

module Mneumonics {
	open React

	module type Window {
		let add_event_listener: (string, Event.Keyboard.t => unit) => unit
		let remove_event_listener: (string, Event.Keyboard.t => unit) => unit
	}

	let onKeyDown = (state, f, e) => {
		let key = Event.Keyboard.key(e);
		// Js.Console.log2("Mneumonics.onKeyDown", key);
		let justFound = ref(None);
		switch (key) {
		| "Alt" => 
			let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
			Event.Keyboard.preventDefault(e);
			root##"dataset"##"mneumonicsVisibility" #= "visible";
			state.current = true
		| k when state.current == true && switch (f(k)) {
			| Some(f) => justFound := Some(f); true
			| None => false
		} =>
			Event.Keyboard.preventDefault(e);
			let f = (justFound^)->Option.get; f(e)
		| _ => ()
		}
	}

	let onKeyUp = (state, e) => {
		let key = Event.Keyboard.key(e);
		// Js.Console.log2("Mneumonics.onKeyUp", key);
		switch (key) {
		| "Alt" =>
			let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
			Event.Keyboard.preventDefault(e);
			root##"dataset"##"mneumonicsVisibility" #= "";
			state.current = false
		| _ => ()
		}
	};

	let use = (module Window : Window, f : (string => option(Event.Keyboard.t => unit))) => {
		let isAlt = useRef(false);
		[|f|]|>useEffect1(() => {
			let onKeyDown = isAlt->onKeyDown(f) and onKeyUp = isAlt->onKeyUp;
			Window.add_event_listener("keydown", onKeyDown);
			Window.add_event_listener("keyup", onKeyUp);
			Some(() => {
				Window.remove_event_listener("keydown", onKeyDown);
				Window.remove_event_listener("keyup", onKeyUp);
			})
		})
	}
}

module Make (C : {
	[@react.component]
	let make : unit => React.element
}) = {
	[@react.component]
	let make = () => {
		React.useEffect0(() => {
			Js__dom.Window.add_event_listener("keydown", onKeyDown);
			Some(() => {
				Js__dom.Window.remove_event_listener("keydown", onKeyDown);
			})
		});
		<C />
	}
}

module Make2 (U : {
	let querySelector : unit => Dom.element;
}, C : {
	[@react.component]
	let make : unit => React.element
}) = {
	let onKeyDown = e => {
		let key = Event.Keyboard.key(e);
		switch (key) {
		| "~" => {
			let sitenav = U.querySelector()->ReactDOM.domElementToObj;
			Event.Keyboard.stopPropagation(e);
			Event.Keyboard.preventDefault(e);
			sitenav##focus ();
		}
		| "Escape" => {
			let sitenav = U.querySelector()->ReactDOM.domElementToObj;
			Event.Keyboard.stopPropagation(e);
			Event.Keyboard.preventDefault(e);
			sitenav##blur ();
			onKeyDown(e);
		}
		| _ => onKeyDown(e)
		}
	};

	[@react.component]
	let make = () => {
		React.useEffect0(() => {
			Js__dom.Window.add_event_listener("keydown", onKeyDown);
			Some(() => {
				Js__dom.Window.remove_event_listener("keydown", onKeyDown);
			})
		});
		<C />
	}
}
