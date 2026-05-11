open React

let onKeyDown = e => {
	let key = Event.Keyboard.key(e);
	switch (key) {
	| "`" => {
		let sitenav = ReactDOM.querySelector("#siteNavigator")->Option.get->ReactDOM.domElementToObj;
		Event.Keyboard.stopPropagation(e);
		Event.Keyboard.preventDefault(e);
		sitenav##focus ();
	}
	| "Escape" => {
		let sitenav = ReactDOM.querySelector("#siteNavigator")->Option.get->ReactDOM.domElementToObj;
		Event.Keyboard.stopPropagation(e);
		Event.Keyboard.preventDefault(e);
		sitenav##blur ();
	}
	| _ => ()
	}
};

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
