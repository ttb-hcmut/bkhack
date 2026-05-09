open Shell__lang

/** The navigation state machine */
let eval = current_url => {
	let url = ref("")
	let url_args = ref([])
	let rec aux = fun
		| Cons_cmd(`unfetched(["feed"]), next) => { url := "/"; aux(next) }
		| Cons_cmd(`unfetched(["split", num]), next) when url^ == "/" => { url_args := Util.List.replace_assoc'("limit", num, url_args^); aux(next) }
		| Cons_cmd(`unfetched(["cat", ("$id" | "$ID")]), next) => {
			url := "/item/";
			let id = Util.parseQueryParams(current_url.ReasonReactRouter.search)->Js.Dict.get("id")->Option.get;
			url_args := Util.List.replace_assoc'("id", id, url_args^);
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "article");
			aux(next) }
		| Cons_cmd(`unfetched(["cat", id]), next) => {
			url := "/item/";
			url_args := Util.List.replace_assoc'("id", id, url_args^);
			url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "article");
			aux(next) }
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
		| Cons_cmd(`unfetched(["set", "--language", lang_id]), next) => {
			Dom.Storage.setItem("bkhack.language", lang_id, Dom.Storage.localStorage);
			let language = Dom.Storage.getItem("bkhack.language", Dom.Storage.localStorage);
			language |> Option.iter(language => {
				let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
				root##"lang" #= language
			});
			aux(next) }
		| Cons_cmd(`unfetched(_), _) => failwith("unknown command")
		| Cons_subprogram(a, b) => { aux(a); aux(b) }
		| Nil => ();
	s => { aux(s); (url^, url_args^) }
}
