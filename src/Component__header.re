open Stdlib
open React
open Auth
open Melange__containers.Fun


module HeaderRight = {
  [@react.component]
  let make = () => {
    let auth = AuthContext.use();
    let (showLoginButton, setShowLoginButton) = useState(() => true)
    and (headerRightExpand, setHeaderRightExpand) = useState(() => false);
    useEffect0 @@ () =>
    { setShowLoginButton( _ => !auth.checkAuth());
      None }
    ;
		<div className={"header-right " ++ (headerRightExpand?"expand":"")}>
      <button className={"header-right-hamburger " ++ (headerRightExpand?"expand":"")}
        onClick={_ => setHeaderRightExpand((!))}
      />
      <div className={"nav-list " ++ (headerRightExpand?"expand":"")}>
        <a className="place notifications" title="Notifications"/>
        <span className="separator"/>
        <a className="place projects" href="/projects/" title="Projects"/>
        <span className="separator"/>
        <a className="place notes" href="/notes/" title="Notes"/>
        <span className="separator"/>
        <a className="place wiki" href="/wiki/" title="Wiki & Documentation"/>
        <span className="separator"/>
        <a className="place settings" href="/settings/" title="Settings"/>
        <span className="separator"/>
        <a className="place admin" href="/admin/" title="Admin Dashboard"/>
        <span className="separator"/>
        { showLoginButton ?
          <button className="place auth" title="Log in" onClick={_ => auth.forceAuth()}/>
          :
          <button className="place auth" title="Log out" onClick={_ => auth.forceAuth()}>{React.string(Option.value(auth.getUserName(),~default="Guest"))}</button>
        }
      </div>
		</div>
  }
}

module Greetings {
	let flag = storage => {
		Dom.Storage.setItem("bkhack.cmd-greeting-shown", "y", storage);
	}

	let load_from_opt_exn = storage => {
		Dom.Storage.getItem("bkhack.cmd-greeting-shown", storage)
		|> Option.map(fun | "y" => () | e => raise @@ Invalid_argument("Greetings.load_from_opt_exn received invalid value '"++e++"'"))
	}
}

let onSubmit = (current_url, ~on_help, ~memo_transition=((_, _, k) => k()), e) => {
	Event.Synthetic.preventDefault(e);
	let rawstr = Event.Form.target(e)##siteNavigator##value;
	let u = rawstr->Shell__parse.string->Result.get_ok;
	let (url, url_args) = Navigation.eval(~on_help, current_url, u);
	Rlwrap.do_(rawstr) @@ () => {
		Greetings.flag(Dom.Storage.sessionStorage);
		let open Js__dom;
		memo_transition(url, url_args) @@ () =>
		Window.Location.href_set(url ++ {
			List.length(url_args) == 0 ? "" : "?" ++ {
				url_args |> List.map(((a,b)) => a++"="++b) |> String.concat("&")}
		});
	}
};

let onKeyDown = (setHistoryIndex, completeBarHTMLContent, onKey, e) => {
	let key = Event.Keyboard.key(e);
	onKey();
	switch (key) {
	| "ArrowUp" => {
		Event.Keyboard.preventDefault(e);
		setHistoryIndex(it => it - 1) }
	| "ArrowDown" => {
		Event.Keyboard.preventDefault(e);
		setHistoryIndex(it => it + 1) }
	| "Tab" => {
		Event.Keyboard.preventDefault(e);
		completeBarHTMLContent() }
	| _ => ()
	}
};

let wrap_dialog = it => <dialog open_=true>{it}</dialog>;

let command__extend = (~tree, s) => {
	let get_unfetched = fun | (`unfetched(cmd)) => Some(cmd) | _ => None;
	let last_cmd_opt = Shell__lang.Program.cmd__last_opt(tree)->Option.bind(get_unfetched);
	let last_opt = last_cmd_opt->Option.bind(cmd => {
		List.last_opt(cmd)->Option.bind(Navigation.Completion.match_(~cmd)) });
	last_opt
	|> Option.map(g =>
		Melange__re.({ let fillin = g->Re.Group.get(1); s++fillin }))
	|> Option.value(~default=s)
};

let a = fun
| Navigation.Unknown_command(`unfetched([cmd_name, ..._])) => {
	let k = "error unknown-command";
	(k, wrap_dialog(<div>{cmd_name->string}</div>))
}
| Navigation.Invalid_syntax_of_command(cmd) => {
	let k = "error invalid-syntax-of-command "++cmd;
	(k, wrap_dialog(<div></div>))
}
| Navigation.Completion.Ambiguous_completion(cmds) => {
	let k = "warning ambiguous-completion";
	(k, wrap_dialog(<div>{cmds |> Array.of_list |> Array.map(string) |> array}</div>))
}
| e => {
	let k = "error";
	(k, wrap_dialog(<div>{e->Js.String.make->string}</div>))
}
;

module Input = {
	[@react.component]
	let make = forwardRef((
    ~value=?,
		~autoComplete=?, ~autoCapitalize=?,
		~onInput=?, ~onKeyDown=?, ~spellCheck=?,
		~forceUpdateState=?, ~id=?, ~className=?, ref) =>
	{ 
    let ref = Js.Nullable.toOption(ref) |> Option.map(x => ReactDOM.Ref.domRef(x));
		useEffect1(() => None
			// Option.bind(forceUpdateState, f => {
			// let x = Js.Global.setInterval(~f, 100);
			// Some(() => Js.Global.clearInterval(x)) })
		, [|forceUpdateState|]);
		<input
      ?value
      ?autoComplete 
      ?autoCapitalize 
      ?onInput 
      ?onKeyDown 
      ?spellCheck 
      ?id 
      ?className 
      ?ref />
	})
};

[@react.component]
let make = (~on_help: bool => unit, ~memo_transition=?) => {
  let url = ReasonReactRouter.useUrl();
  let (content, setContent) = useState(() => "") 
  and (historyIndex, setHistoryIndex) = useState(Rlwrap.index_init) 
  and (navigatorError, setNavigatorError) = useState(() => None) 
  and (mostUsefulUsestateEver, setMUUE) = useState(()=> true);
  // ^ signal that yes the user wants to ignore the placeholder
	let bar = useRef(Js.Nullable.null);
	let setHistoryIndex = useCallback1(k => {
		let historyLen = Dom.Storage.localStorage
			|> Dom.Storage.getItem("bkhack.cmd-history")
			|> Option.map(String.split_on_char(','))
			|> Option.value(~default=[])
			|> List.length;
		setHistoryIndex(k %> Int.min(historyLen) %> Int.max(0))
	}, [|setHistoryIndex|])
	let setBarHTMLContent = (bar, str: string => string) => {
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		bar##value #= (str(bar##value))
	};
	let assert_ = useCallback1(k => {
		setNavigatorError @@ prev =>
		try ({ let () = k(prev); None }) { | e => Some(e) }
	}, [|setNavigatorError|]);
	let placeholder = [|mostUsefulUsestateEver|] |> useMemo1(() =>
		switch (Dom.Storage.sessionStorage |> Greetings.load_from_opt_exn) {
		| Some() => None
		| None   => Option.some @@
			<span className="placeholder ">
				<kbd className="type_ help" />
        <span className="show-all-commands"/> 
        <a className="ignore-this"
          onClick={_ => {
          Greetings.flag(Dom.Storage.sessionStorage);
          setMUUE((!))
          }}
        />
			</span>
		}
	);
	let fakeBarSync = (bar, k) => {
		let v = k();
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		setContent(_ => bar##value);
		v
	};
	let inputForceUpdateState = useCallback0(() => bar->fakeBarSync(() => ()));
	let completeBarHTMLContent = useCallback1(() => {
		assert_ @@ _ =>
		bar->fakeBarSync @@ () =>
		bar->setBarHTMLContent @@ s =>
		s->Shell__parse.string->Result.lift(tree => command__extend(~tree, s))->Result.value(~default=s)
	}, [|assert_|]);
	let (errorClass, errorBox) = [|navigatorError|] |> useMemo1 @@ () =>
		navigatorError |> Option.map(a) |> Option.value(~default=("", <> </>));
	let onKey = () => {
		setNavigatorError(_ => None);
		()
	};
	let innerHTML = (content, placeholder) |> useMemo2(() =>
		content === ""
		? (placeholder |> Option.value(~default=null))
		: content->Shell__pastel.string->Result.value(~default=content->string)
	);
	[|historyIndex|] |> useEffect1 @@ () =>
	{ Rlwrap.on_scroll(historyIndex) @@ historyContent =>
		bar->fakeBarSync @@ () =>
		bar->setBarHTMLContent @@ _ =>
		historyContent->Option.value(~default="");
		None };
	useEffect0 @@
	React__effect.async @@ () =>
	Fetch__syntax.({
		let bar = bar.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
		bar##focus();
		return()
	});
  let on_help = [|on_help|]|>useCallback1 @@ () => { on_help(true); };
	<div>
		<div className="header-left">
			<a className="logo" href="/" />
			<form onSubmit={e => assert_ @@ _ => url->onSubmit(~on_help, ~memo_transition?, e)}>
        <div className="input-spacer">
          <Input
            autoComplete="off" autoCapitalize="off" spellCheck=false
            value=content
            onInput={_ => bar->fakeBarSync @@ () => ()} 
            onKeyDown={onKeyDown(setHistoryIndex, completeBarHTMLContent, onKey)}
            forceUpdateState=inputForceUpdateState 
            ref={ReactDOM.Ref.domRef(bar)}
            id="siteNavigator" className=errorClass />
          <div className="displayonly highlight">{innerHTML}</div>
        </div>
				{errorBox}
			</form>
		</div>
    <HeaderRight />
	</div>
}
