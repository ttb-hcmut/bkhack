// let shell = "feed | { split 10 | filter ;} | filter";
// Js.Console.log("parsing '" ++ shell ++ "'");
// Js.Console.log(Shell.test_parse(shell));

open React
open Auth
let onSubmit = (current_url, ~memo_transition=((_, _, k) => k()), e) => {
	Event.Synthetic.preventDefault(e);
	let rawstr = Event.Form.target(e)##siteNavigator##value;
	let u = rawstr->Shell__parse.parse_string->Result.get_ok;
	let (url, url_args) = Navigation.eval(current_url, u);
	Rlwrap.do_(rawstr) @@ () => {
		Dom.Storage.setItem("bkhack.cmd-greeting-shown", "y", Dom.Storage.sessionStorage);
		let open Js__dom;
		memo_transition(url, url_args) @@ () =>
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
	| ("ArrowUp", _) => {
		Event.Keyboard.preventDefault(e);
		setHistoryIndex(it => it - 1) }
	| ("ArrowDown", _) => {
		Event.Keyboard.preventDefault(e);
		setHistoryIndex(it => it + 1) }
	| _ => ()
	}
};

let wrap_dialog = it => <dialog open_=true>{it}</dialog>;

[@react.component]
let make = (~memo_transition=?) => {
  let auth = AuthContext.use();
  let (showLoginButton,setShowLoginButton) = React.useState(()=>true);
	let (content, setContent) = useState(() => "");
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
	let (navigatorError, setNavigatorError) = useState(() => None);
	let setBarHTMLContent = (bar, str: unit => string) => {
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		bar##value #= (str())
	};
	let assert_ = useCallback1(k => {
		setNavigatorError @@ prev =>
		try ({ let () = k(prev); None }) { | e => Some(e) }
	}, [|setNavigatorError|]);
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
	let fakeBarSync = (bar, k) => {
		let v = k();
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		setContent(_ => bar##value);
		v
	};
	useEffect1(() => {
		Rlwrap.on_scroll(historyIndex) @@ historyContent =>
		bar->fakeBarSync @@ () =>
		bar->setBarHTMLContent @@ () =>
		historyContent->Option.value(~default="");
		None
	}, [|historyIndex|]);
	let (errorClass, errorBox) = useMemo1(() => {
		navigatorError
		|> Option.map(fun
		| Navigation.Unknown_command(`unfetched([cmd_name, ..._])) => {
			let k = "error unknown-command";
			(k, wrap_dialog(<div>{cmd_name->string}</div>))
		}
		| Navigation.Invalid_syntax_of_command(cmd) => {
			let k = "error invalid-syntax-of-command "++cmd;
			(k, wrap_dialog(<div></div>))
		}
		| e => {
			let k = "error";
			(k, wrap_dialog(<div>{e->Js.String.make->string}</div>))
		}
		)
		|> Option.value(~default=("", <> </>))
	}, [|navigatorError|]);
	let onKey = () => {
		setNavigatorError(_ => None);
		()
	};
	let url = ReasonReactRouter.useUrl();
	let innerHTML = (content, placeholder) |> useMemo2(() =>
		content === ""
		? Option.value(~default="", placeholder)->string
		: content->Shell__pastel.parse_string->Result.value(~default=content->string)
	);
  React.useEffect0(()=>{
    setShowLoginButton( _ => !auth.checkAuth());
    None
  });
	<>
	<a className="logo" href="/" />
	<form onSubmit={e => assert_ @@ _ => onSubmit(url, ~memo_transition?, e)}>
		<input autoComplete="off" autoCapitalize="off" spellCheck=false onChange={_ => bar->fakeBarSync @@ () => ()} onKeyDown={onKeyDown(setHistoryIndex, onKey)} ref={ReactDOM.Ref.domRef(bar)} id="siteNavigator" className=errorClass />
		<div className="displayonly highlight">{innerHTML}</div>
		{errorBox}
	</form>
	<a className="place projects" href="/projects"></a>
	<a className="place wiki" href="/wiki"></a>
	<a className="place notifications"></a>
	<a className="place settings" href="/settings"></a>

  { showLoginButton ?
    <button className="place auth" title="Log in" onClick={_ => auth.forceAuth()}/>
    :
    <button className="place" title="Log out" onClick={_ => auth.forceAuth()}>{React.string(Option.value(auth.getUserName(),~default="Guest"))}</button>
}
	</>
}
