// let shell = "feed | { split 10 | filter ;} | filter";
// Js.Console.log("parsing '" ++ shell ++ "'");
// Js.Console.log(Shell.test_parse(shell));

module Nav =
{
	let eval = {
		let url = ref("")
		let url_args = ref([])
		let rec aux = fun
			| Shell__lang.Cons_cmd(`unfetched(["feed"]), next) => { url := "/"; aux(next) }
			| Shell__lang.Cons_cmd(`unfetched(["split", num]), next) => { url_args := url_args^ @ [("limit", num)]; aux(next) }
			| Shell__lang.Cons_cmd(`unfetched(_), _) => failwith("unknown command")
			| Shell__lang.Cons_subprogram(a, b) => { aux(a); aux(b) }
			| Shell__lang.Nil => ();
		s => { aux(s); (url^, url_args^) }
	}
}

let onSubmit = e => {
	React.Event.Synthetic.preventDefault(e);
	let u = React.Event.Form.target(e)##siteNavigator##value -> Shell__parse.test_parse;
	let (url, url_args) = Nav.eval(u);
	let open Js__dom;
	Window.Location.href_set(url ++ {
		List.length(url_args) == 0 ? "" : "?" ++ {
			url_args |> List.map(((a,b)) => a++"="++b) |> String.concat("&")}
	});
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
