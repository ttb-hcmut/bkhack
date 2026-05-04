// let shell = "feed | { split 10 | filter ;} | filter";
// Js.Console.log("parsing '" ++ shell ++ "'");
// Js.Console.log(Shell.test_parse(shell));

module Nav =
{
	open Shell__lang

	let eval = {
		let url = ref("")
		let url_args = ref([])
		let rec aux = fun
			| Cons_cmd(`unfetched(["feed"]), next) => { url := "/"; aux(next) }
			| Cons_cmd(`unfetched(["split", num]), next) when url^ == "/" => { url_args := Util.List.replace_assoc'("limit", num, url_args^); aux(next) }
			| Cons_cmd(`unfetched(["cat", id]), next) => {
				url := "/item/";
				url_args := Util.List.replace_assoc'("id", id, url_args^);
				aux(next) }
			| Cons_cmd(`unfetched(["discuss", id]), next) => {
				url := "/item/";
				url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "discussions");
				aux(next) }
			| Cons_cmd(`unfetched(["pr", "list", id]), next) => {
				url := "/item/";
				url_args := url_args^ |> Util.List.replace_assoc'("id", id) |> Util.List.replace_assoc'("view", "pullrequests");
				aux(next) }
			| Cons_cmd(`unfetched(_), _) => failwith("unknown command")
			| Cons_subprogram(a, b) => { aux(a); aux(b) }
			| Nil => ();
		s => { aux(s); (url^, url_args^) }
	}
}

open React

module Rlwrap =
{
	let do_ = (memo, task) => {
		let acc = Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]);
		Dom.Storage.setItem("bkhack.cmd-history", String.concat(",", acc @ [memo]), Dom.Storage.localStorage);
		task()
	}

	let index_init = () => Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]) |> List.length

	let on_scroll = (historyIndex, k) => {
		let a = x => List.nth_opt(x, historyIndex);
		let u =
			Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[])
			|> a;
		k(u)
	}
}

let onSubmit = e => {
	Event.Synthetic.preventDefault(e);
	let rawstr = Event.Form.target(e)##siteNavigator##value;
	let u = rawstr->Shell__parse.test_parse;
	let (url, url_args) = Nav.eval(u);
	Rlwrap.do_(rawstr) @@ () => {
		let open Js__dom;
		Window.Location.href_set(url ++ {
			List.length(url_args) == 0 ? "" : "?" ++ {
				url_args |> List.map(((a,b)) => a++"="++b) |> String.concat("&")}
		});
	}
};

let onKeyDown = (setHistoryIndex, e) => {
	let key = Event.Keyboard.key(e);
	let mk_char = s => try (String.get(s, 0)->Option.some) { | Invalid_argument(_) => None }
	switch ((key, mk_char(key))) {
	| ("ArrowUp", _) => setHistoryIndex(it => it - 1)
	| ("ArrowDown", _) => setHistoryIndex(it => it + 1)
	| _ => ()
	}
};

[@react.component]
let make = () => {
	let bar = useRef(Js.Nullable.null);
	let (historyIndex, setHistoryIndex) = useState(Rlwrap.index_init);
	let setHistoryIndex = useCallback1(k => {
		setHistoryIndex(prev => {
			let newval = k(prev);
			let newval = newval->Int.min(Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]) |> List.length);
			let newval = newval->Int.max(0)
			newval
		})
	}, [|setHistoryIndex|])
	let (navigatorStyle, setNavigatorStyle) = useState(() => None);
	let setBarContent = (str: string) => {
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		bar##value #= str
	};
	let assert_ = useCallback1(k => {
		setNavigatorStyle(prev => {
			try ({
				let () = k(prev);
				None
			}) {
				| _ => Some("error")
			}
		})
	}, [|setNavigatorStyle|]);
	useEffect0(
		React__effect.async @@ () =>
		Fetch__syntax.({
			let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
			bar##focus();
			return()
		})
	);
	useEffect1(() => {
		Rlwrap.on_scroll(historyIndex) @@ u =>
		setBarContent(Option.value(~default="", u)); None
	}, [|historyIndex|]);
	<>
	<a className="logo" href="/" />
	<form onSubmit={e => assert_ @@ _ => onSubmit(e)}> <input onKeyDown={onKeyDown(setHistoryIndex)} ref={ReactDOM.Ref.domRef(bar)} id="siteNavigator" className={Option.value(~default="", navigatorStyle)} /> </form>
	<a className="place projects" href="/projects"></a>
	<a className="place wiki" href="/wiki"></a>
	<a className="place auth" href="/auth"></a>
	</>
}
