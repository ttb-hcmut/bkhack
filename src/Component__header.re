// let shell = "feed | { split 10 | filter ;} | filter";
// Js.Console.log("parsing '" ++ shell ++ "'");
// Js.Console.log(Shell.test_parse(shell));

open React

let onSubmit = (current_url, e) => {
	Event.Synthetic.preventDefault(e);
	let rawstr = Event.Form.target(e)##siteNavigator##value;
	let u = rawstr->Shell__parse.test_parse;
	let (url, url_args) = Navigation.eval(current_url, u);
	Rlwrap.do_(rawstr) @@ () => {
		Dom.Storage.setItem("bkhack.cmd-greeting-shown", "y", Dom.Storage.sessionStorage);
		let open Js__dom;
		Window.Location.href_set(url ++ {
			List.length(url_args) == 0 ? "" : "?" ++ {
				url_args |> List.map(((a,b)) => a++"="++b) |> String.concat("&")}
		});
	}
};

let onKeyDown = (setHistoryIndex, onKey, e) => {
	let key = Event.Keyboard.key(e);
	let mk_char = s => try (String.get(s, 0)->Option.some) { | Invalid_argument(_) => None }
	onKey();
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
	let placeholder = useMemo0(() =>
		Dom.Storage.getItem("bkhack.cmd-greeting-shown", Dom.Storage.sessionStorage)
		|> [@warning "-8"] fun | None => Some("Start typing to dismiss or don't show this again.") | Some("y") => None
	);
	useEffect0(
		React__effect.async @@ () =>
		Fetch__syntax.({
			let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
			bar##focus();
			return()
		})
	);
	useEffect1(() => {
		Rlwrap.on_scroll(historyIndex) @@ u => {
			setBarContent(Option.value(~default="", u)); None
		}
	}, [|historyIndex|]);
	let errorBox = useMemo1(() => {
		Option.is_some(navigatorStyle) ?
			<dialog open_=true>
				<div>{"error"->React.string}</div>
			</dialog>
		: <> </>
	}, [|navigatorStyle|])
	let onKey = () => {
		setNavigatorStyle(_ => None);
		()
	};
	let url = ReasonReactRouter.useUrl();
	<>
	<a className="logo" href="/" />
	<form onSubmit={e => assert_ @@ _ => onSubmit(url, e)}>
		<input placeholder=?placeholder onKeyDown={onKeyDown(setHistoryIndex, onKey)} ref={ReactDOM.Ref.domRef(bar)} id="siteNavigator" className={Option.value(~default="", navigatorStyle)} />
		{errorBox}
	</form>
	<a className="place projects" href="/projects"></a>
	<a className="place wiki" href="/wiki"></a>
	<a className="place notifications"></a>
	<a className="place settings" href="/settings"></a>
	<a className="place auth" href="/auth"></a>
	</>
}
