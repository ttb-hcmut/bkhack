open Shell__lang

exception Unknown_command([ `unfetched(list(string)) ])

exception Invalid_syntax_of_command(string)

exception Empty

module Completion{
	let%comptime samples_man_3' = {
		open Containers.Fun;
		let get_in_build_sandbox_opt = {
			let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), str(Filename.dir_sep), str(".sandbox"), str(Filename.dir_sep), alnum |> rep1, str(Filename.dir_sep), group(any |> rep)]));
			let match_ = Re.exec_opt @@ pat;
			let map_compensate = g => "../../../"++Re.Group.get(g, 1)++"/";
			match_ %> Option.map(map_compensate)
		};
		let get_in_build_opt = {
			let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), str(Filename.dir_sep), group(any |> rep)]));
			let match_ = Re.exec_opt @@ pat;
			let map_compensate = g => Re.Group.get(g, 1);
			match_ %> Option.map(map_compensate)
		};
		let output = {
			let cwd = Sys.getcwd();
			get_in_build_sandbox_opt(cwd)
			|> Option.fold(~none=get_in_build_opt(cwd), ~some=Option.some)
			|> Option.map(compensate => compensate++"src/Devbook/_output")
		};
		let entries = output
			|> Option.map(output => output |> Sys.readdir |> Array.map(Filename.remove_extension))
			|> Option.value(~default=[||]);
		Printf.printf("%%BOC%%\"%s\"%%EOC%%", entries |> Array.to_list |> String.concat("/"));
	}

	let samples_man_3 = samples_man_3' |> String.split_on_char('/')

	let samples_set_tilesets = [ "gui", "''" ]

	and samples_set_languages = [ "vi-VN", "en-US" ]

	and samples_set_highlight = [ "none", "colorful" ]

	and samples_set = [ "--language", "--highlight", "--tileset" ]

	and samples_split = [ "-c" ]

	and samples = [ "feed", "discuss", "set", "split", "man" ]

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
			// Js.Console.log2("try to complete", cmd);
			switch (cmd) {
			| ["man", "3", _] =>
				samples_man_3 |> List.filter_map(last->doit) |> funnel_opt
			| ["man", "3"] =>
				samples_man_3 |> List.filter_map(""->doit) |> funnel_opt
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
		| Cons_cmd(`unfetched(["man", "3", cmd]), next) => { url := "/devbook/"++cmd++".pdf"; aux(next) }
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
			mode->Command__highlight.save_into(Dom.Storage.localStorage);
			let root = ReactDOM.querySelector("#root")->Option.get;
			root->Command__highlight.sync_from_exn(Dom.Storage.localStorage);
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
