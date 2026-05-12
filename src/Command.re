open React

module Make (C : Decorator.Component) {
	[@react.component]
	let make = () => {
		useEffect0(() => {
			let treesitter = Dom.Storage.getItem("bkhack.highlight", Dom.Storage.localStorage);
			switch (treesitter) {
				| None | Some("colorful") => {
					let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
					root##"dataset"##"highlight" #= "colorful" }
				| _ => {
					let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
					root##"dataset"##"highlight" #= "none" }
			};
			None
		});
		<C />
	}
}
