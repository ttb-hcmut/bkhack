[@page "/new"]
// open Melange__containers.Fun
module Melange__cmarkit = Remark_it
open Auth

module View = {
	type t =
		| Article
		| Discussion
		| Pullrequest
		| Log
		| Edit

	let uu = [
		( Article, "article" ),
		( Discussion, "discussions" ),
		( Pullrequest, "pullrequests" ),
		( Log, "log" ),
		( Edit, "edit")
	]

	let uu' = uu |> List.map(((k, v)) => (v, k))

	let to_string = k => List.assoc(k, uu)

	let of_string = k => List.assoc(k, uu')
}

module ItemNav{
	open View

  [@react.component]
  let make = (~currentTab) => {
		let className = x =>
			View.to_string(x)++" " ++ (currentTab == x ? "selected" : "");
    <>
    <button disabled=true className=className(Article)> <label /> </button>
    <button disabled=true className=className(Discussion)>
      <label>{React.string("discussions")}</label>
      <data className="count">{React.int(0)}</data>
    </button>
    <button disabled=true className=className(Pullrequest)>
      <label>{React.string("pull-requests")}</label>
      <data className="count">{React.int(0)}</data>
    </button>
    <button disabled=true className=className(Log)>
      <label>{React.string("history")}</label>
    </button>
    <button disabled=true className=className(Edit)> <label /> </button>
    </>
  }
}

module React{
	include React
	open Melange__iter
	open Melange__containers.Fun

	let iter = array % Iter.to_array
}

module DiscussionView = {
  [@react.component]
  let make = () => {
    <>
      <header className={"only " ++ View.to_string(Discussion)}>
        <nav>
        </nav>
      </header>
      <main className={"only " ++ View.to_string(Discussion)}>
      </main>
    </>
  }
}

exception Item_not_found

module App{
  open React

	let show = (x, f) => switch (x) { | Some(info) => f(info) | None => { <> </> } };

	[@react.component]
	let make = () => {
		let (sidebarState, setSidebarState) = useState(() => "state0");
    let (_showHelp, setShowHelp) = useState(() => false);
    let on_help = x => setShowHelp(_ => x);
		<>
			<title>{React.string("Creating a new post")}</title>
			<header>
				<Component__header on_help />
			</header>	
			<nav className=sidebarState>
				<ItemNav currentTab={View.Edit} />
			</nav>
			<main className={sidebarState ++ " " ++ View.to_string(Edit)}>
				<>
					<header className=Printf.sprintf("only %s", View.to_string(Article))></header>
					<div className=Printf.sprintf("innerbody only %s", View.to_string(Article))></div>
				</>
        <DiscussionView />
				<>
					<header className=Printf.sprintf("only %s", View.to_string(Pullrequest))>
						<nav>
						</nav>
					</header>
					<main className=Printf.sprintf("only %s", View.to_string(Pullrequest))></main>
					<header className=Printf.sprintf("only %s inspect", View.to_string(Pullrequest))>
					</header>
					<main className=Printf.sprintf("only %s inspect", View.to_string(Pullrequest))>
					</main>
				</>
				<Item_view__editor.App className={View.to_string(Edit)}/>
			</main>
			<Component__sidebar sidebarState setSidebarState />
		</>
	}
};

module Error_page(C : Decorator.Component) {
	open React
	open ReasonReactErrorBoundary

	let fallback = fun
	| Item_not_found =>
		<dialog open_=true>"not_found"->string</dialog>
	| _ =>
		<div>"error"->string</div>
	;

	[@react.component] let make = () =>
		<ReasonReactErrorBoundary fallback={({ error, _ }) => fallback(error)}> <C /> </ReasonReactErrorBoundary>
}

module ReactDOM0 = {
	let querySelector = x =>
		switch (ReactDOM.querySelector(x)) {
		| Some(x) => x
		| None =>
			Js.Console.error("khong tim thay element #root");
			failwith("lol")
		}
}

open Decorator

module App' =
(
	val (module App)
	->React.use(module Language.Make)
	->React.use(module Keyboard.Make)
	->React.use(module Command.Make)
	->React.use(module Error_page)
  ->React.use(module AuthContext.Provider)
)

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App' />)
}
