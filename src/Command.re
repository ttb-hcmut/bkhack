open React

module Highlight{

	let save_into = (mode, storage) => {
		Dom.Storage.setItem("bkhack.highlight", mode, storage);
	}

	let sync_from_exn = (root, storage) => {
		let treesitter = Dom.Storage.getItem("bkhack.highlight", storage);
		switch (treesitter) {
			| None | Some("colorful") => {
				let root = root->ReactDOM.domElementToObj;
				root##"dataset"##"highlight" #= "colorful" }
			| _ => {
				let root = root->ReactDOM.domElementToObj;
				root##"dataset"##"highlight" #= "none" }
		};
	}

}

module Make (C : Decorator.Component) {
	[@react.component]
	let make = () => {
		useEffect0(() => {
			let root = ReactDOM.querySelector("#root")->Option.get;
			root->Highlight.sync_from_exn(Dom.Storage.localStorage);
			None
		});
		<C />
	}
}
