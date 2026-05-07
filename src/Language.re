open React

module type Component = {
	[@react.component] let make : unit => React.element
}

module Make (C : Component) {
	[@react.component]
	let make = () => {
		useEffect0(() => {
			let language = Dom.Storage.getItem("bkhack.language", Dom.Storage.localStorage);
			language |> Option.iter(language => {
				let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
				root##"lang" #= language
			});
			None
		});
		<C />
	}
}
