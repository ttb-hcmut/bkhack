open Shell__lang

exception Unknown_command([ `unfetched(list(string)) ])

exception Invalid_syntax_of_command(string)

exception Empty

module Completion{
	let samples_set_tilesets = [ "gui", "''" ]

	and samples_set_languages = [ "vi-VN", "en-US" ]

	and samples_set_highlight = [ "none", "colorful" ]

	and samples_set = [ "--language", "--highlight", "--tileset" ]

	and samples_split = [ "-c" ]

	and samples = [ "feed", "discuss", "set", "split" ]

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
			| ["split", _] =>
				samples_split |> List.filter_map(last->doit) |> funnel_opt
			| ["split"] =>
				samples_split |> List.filter_map(""->doit) |> funnel_opt
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

/** The navigation state machine */
let eval = (~on_help, current_url) => {
	let url = ref("")
	let url_args = ref([])
	let rec aux = fun
    | Cons_cmd(`unfetched(["help"]), Nil) => on_help()
		| Cons_cmd(`unfetched(["feed"]), next) => { url := "/"; aux(next) }
		| Cons_cmd(`unfetched(["feed", ..._]), _) => raise(Invalid_syntax_of_command("feed"))
		| Cons_cmd(`unfetched(["split", "-c", num]), next) when url^ == "/" => { url_args := Util.List.replace_assoc'("limit", num, url_args^); aux(next) }
		| Cons_cmd(`unfetched(["cat", ("$id" | "$ID")]), next) => {
			url := "/item/";
			let id = Util.parseQueryParams(current_url.ReasonReactRouter.search)->Js.Dict.get("id")->Option.get;
			url_args := Util.List.replace_assoc'("id", id, url_args^);
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "article");
			aux(next) }
		| Cons_cmd(`unfetched(["cat", id]), next) when try ({ id->int_of_string->ignore; true }) { | _ => false } => {
			url := "/item/";
			url_args := Util.List.replace_assoc'("id", id, url_args^);
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "article");
			aux(next) }
		| Cons_cmd(`unfetched(["cat", ..._]), _) => raise(Invalid_syntax_of_command("cat"))
		| Cons_cmd(`unfetched(["discuss", ("$id" | "$ID")]), next) => {
			url := "/item/";
			let id = Util.parseQueryParams(current_url.ReasonReactRouter.search)->Js.Dict.get("id")->Option.get;
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "discussions");
			aux(next) }
		| Cons_cmd(`unfetched(["discuss", id]), next) => {
			url := "/item/";
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "discussions");
			aux(next) }
		| Cons_cmd(`unfetched(["pr", "list", id]), next) => {
			let id = id == "$id" || id == "$ID" ? Util.parseQueryParams(current_url.ReasonReactRouter.search)->Js.Dict.get("id")->Option.get : id;
			url := "/item/";
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "pullrequests");
			aux(next) }
		| Cons_cmd(`unfetched(["vi", ("$id" | "$ID")]), next) => {
			url := "/item/";
			let id = Util.parseQueryParams(current_url.ReasonReactRouter.search)->Js.Dict.get("id")->Option.get;
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "edit");
			aux(next)	}
		| Cons_cmd(`unfetched(["vi", id]), next) => {
			url := "/item/";
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "edit");
			aux(next)	}
		| Cons_cmd(`unfetched(["set", "--tileset", mode]), next) => {
			mode->Tileset.save_into_exn(Dom.Storage.localStorage);
			let root = ReactDOM.querySelector("#root")->Option.get;
			root->Tileset.sync_from_exn(Dom.Storage.localStorage);
			aux(next) }
		| Cons_cmd(`unfetched(["set", "--highlight", mode]), next) => {
			mode->Command.Highlight.save_into(Dom.Storage.localStorage);
			let root = ReactDOM.querySelector("#root")->Option.get;
			root->Command.Highlight.sync_from_exn(Dom.Storage.localStorage);
			aux(next) }
		| Cons_cmd(`unfetched(["set", "--language", lang_id]), next) => {
			Dom.Storage.setItem("bkhack.language", lang_id, Dom.Storage.localStorage);
			let language = Dom.Storage.getItem("bkhack.language", Dom.Storage.localStorage);
			language |> Option.iter(language => {
				let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
				root##"lang" #= language
			});
			aux(next) }
		| Cons_cmd(`unfetched(["set"]), next) => {
			url := "/settings/";
			aux(next)	}
		| Cons_cmd(cmd, _) => raise(Unknown_command(cmd))
		| Cons_subprogram(a, b) => { aux(a); aux(b) }
		| Nil => ();
	s => {
		switch (s) {
		| Nil => raise(Empty)
		| s => aux(s) };
		(url^, url_args^) }
}
