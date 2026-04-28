module Window = {
	type location;
	[@mel.scope "window"] external location : location = "location";
	[@mel.set] external set__href : location => string => unit = "href";
}

// let shell = "feed | { split 10 | filter ;} | filter";
// Js.Console.log("parsing '" ++ shell ++ "'");
// Js.Console.log(Shell.test_parse(shell));

module Nav() = {
	let url = ref("")
	let url_args = ref([])

	let rec eval = fun
		| Shell__lang.Cons_cmd(`unfetched(["feed"]), next) => { url := "/"; eval(next) }
		| Shell__lang.Cons_cmd(`unfetched(["split", num]), next) => { url_args := url_args^ @ [("limit", num)]; eval(next) }
		| Shell__lang.Cons_cmd(`unfetched(_), _) => failwith("unknown command")
		| Shell__lang.Cons_subprogram(a, b) => { eval(a); eval(b) }
		| Shell__lang.Nil => ()

}

let onSubmit = e => {
	React.Event.Synthetic.preventDefault(e);
	let u = React.Event.Form.target(e)##siteNavigator##value -> Shell__parse.test_parse;
	let open Nav(); eval(u);
	Window.set__href(Window.location, url^ ++ (if (List.length(url_args^) == 0) { "" } else {
		"?" ++ ((url_args^) |> List.map(((a,b)) => a++"="++b) |> String.concat("&"))
	}));
	Js.Console.log(u)
};

[@react.component]
let make = () => {
	<>
		<a className="logo" href="/" />
		<form onSubmit> <input id="siteNavigator" /> </form>
		<a className="place projects" href="/projects"></a>
		<a className="place wiki" href="/wiki"></a>
	</>
}
