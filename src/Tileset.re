open React
open Decorator

let save_into_exn = (mode, storage) => {
	Dom.Storage.setItem("bkhack.tileset", mode, storage);
}

let sync_from_exn = (root, storage) => {
	let x = Dom.Storage.getItem("bkhack.tileset", storage);
	switch (x) {
		| None | Some("gui") => {
			let root = root->ReactDOM.domElementToObj;
			root##"dataset"##"tileset" #= "gui" }
		| _ => {
			let root = root->ReactDOM.domElementToObj;
			root##"dataset"##"tileset" #= "" }
	};
}

module Make (C : Component) {
	[@react.component]
	let make = () => {
		useEffect0(() => {
			let root = ReactDOM.querySelector("#root")->Option.get;
			root->sync_from_exn(Dom.Storage.localStorage);
			None
		});
		<C />
	}
}
