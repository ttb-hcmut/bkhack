open Melange__containers.Fun

let to_string = x => switch (x) {
	| `Article => "article"
	| `Discussion => "discussion"
	| `Pullrequest => "pullrequest"
	| `Log => "log"
}

module ArticleHeader = {
	[@react.component]
	let make = (~tags, ~pullrequests) => {
		<>
			<div className="counter">{React.int(330)}</div>
			<h1>{React.string("Seven Implementations of Incremental")}</h1>
			<ul className="tags">{tags |> Array.map(x => <li key=x><span className="tag">{React.string(x)}</span></li>) |> React.array}</ul>
			<div className="author">
				<div className="created-from"></div>
			</div>
			<div className="activities">
				<span className="pullrequests">{React.int(pullrequests)}</span>
			</div>
			<div className="actions">
				<button>{React.string("watch")}</button>
				<button>{React.string("read")}</button>
				<button>{React.string("subscribe")}</button>
			</div>
		</>
	}
}

module ArticleBody = {
	[@react.component]
	let make = () => {
		<>
			<nav className="toc">
				<ol>
				</ol>
			</nav>
			<main className="markdown">
			</main>
		</>
	}
}

module Re = {
	include Js.Re
	let exec = (pattern, str) => exec(~str, pattern)
}

let get_item_id = {
	let pattern = Re.fromString("id=(.+)");
	Re.exec(pattern)
	%> Option.get
	%> Re.captures
	%> (x => Array.get(x, 1))
	%> Js.Nullable.toOption
	%> Option.get
}

module App = {
	[@react.component]
	let make = () => {
		let (currentTab, setCurrentTab) = React.useState(() => `Article);
		let tags = [| "Algorithm", "Rust" |];
		let pullrequests = [| "", "" |];
		let id = React.useMemo1(() => to_string(currentTab), [|currentTab|]);
		let url = ReasonReactRouter.useUrl();
		React.useEffect0(() => {
			let id = get_item_id(url.search);
			Js.Console.log(id);
			None
		});
		<>
			<header>
				<Header />
			</header>
			<div className=Printf.sprintf("innerbody %s", id)>
				<nav>
					<button onClick={_ => setCurrentTab(_ => `Article)} className={currentTab == `Article ? "selected" : ""}>
						<label>{React.string("article")}</label>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Discussion)} className={currentTab == `Discussion ? "selected" : ""}>
						<label>{React.string("discussion")}</label>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Pullrequest)} className={currentTab == `Pullrequest ? "selected" : ""}>
						<label>{React.string("pull-request")}</label>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Log)} className={currentTab == `Log ? "selected" : ""}>
						<label>{React.string("git-log")}</label>
					</button>
				</nav>
				{ switch (currentTab) {
				| `Article =>
					<>
						<header><ArticleHeader tags pullrequests=Array.length(pullrequests) /></header>
						<div className="innerbody"><ArticleBody /></div>
					</>
				| `Discussion =>
					<>
						<header></header>
						<main></main>
					</>
				| `Pullrequest =>
					<>
						<header></header>
						<main></main>
					</>
				| `Log =>
					<>
						<header></header>
						<main></main>
					</>
				}}
			</div>
		</>
	}
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

let element = ReactDOM0.querySelector("#root");
let root = ReactDOM.Client.createRoot(element);
ReactDOM.Client.render(root, <App />);
