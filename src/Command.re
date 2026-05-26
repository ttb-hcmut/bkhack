open React

module Completion{

	let samples_set_tilesets = [ "gui", "''" ]

	and samples_set_languages = [ "vi-VN", "en-US" ]

	and samples_set_highlight = [ "none", "colorful" ]

	and samples_set = [ "--language", "--highlight", "--tileset" ]

	and samples = [ "feed", "discuss", "set" ]

	exception Ambiguous_completion(list(string))

	let match_ = Melange__re.({
		let doit = last =>
			Re.exec_opt (
				Re.compile @@ Re.(seq([bos, str(last), group(
					any |> rep1
				), eos]))
			)
			;
		let funnel_opt = xs => {
			switch (xs) {
			| []  => None
			| [x] => Some(x)
			| xs  => raise(Ambiguous_completion(xs |> List.map(g => g->Re.Group.get(0))))
			}
		};
		(last, ~cmd) => {
			Js.Console.log2("try to complete", cmd);
			switch (cmd) {
			| ["set", "--tileset", _] =>
				samples_set_tilesets |> List.filter_map(last->doit) |> funnel_opt
			| ["set", "--tileset"] =>
				samples_set_tilesets |> List.filter_map(""->doit) |> funnel_opt
			| ["set", "--highlight", _] =>
				samples_set_highlight |> List.filter_map(last->doit) |> funnel_opt
			| ["set", "--highlight"] =>
				samples_set_highlight |> List.filter_map(""->doit) |> funnel_opt
			| ["set", "--language", _] =>
				samples_set_languages |> List.filter_map(last->doit) |> funnel_opt
			| ["set", "--language"] =>
				samples_set_languages |> List.filter_map(""->doit) |> funnel_opt
			| ["set", _] =>
				samples_set |> List.filter_map(last->doit) |> funnel_opt
			| ["set"] =>
				samples_set |> List.filter_map(""->doit) |> funnel_opt
			| [_] =>
				samples |> List.filter_map(last->doit) |> funnel_opt
			| [] =>
				samples |> List.filter_map(""->doit) |> funnel_opt
			| _ =>
				None
			}
		}
	})
}

module Highlight{

	let save_into_exn = (mode, storage) => {
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
