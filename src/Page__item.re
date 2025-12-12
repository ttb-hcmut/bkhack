open Melange__containers.Fun

let to_string = x => switch (x) {
| `Article => "article"
| `Discussion => "discussion"
| `Pullrequest => "pullrequest"
| `Log => "log"
}

module ArticleHeader = {
	[@react.component]
	let make = (~tags) => {
		<>
			<div className="counter">
				<button className="up">
					{React.string("up")}
				</button>
				<span>{React.int(330)}</span>
				<button className="down">
					{React.string("down")}
				</button>
			</div>
			<h1>{React.string("Seven Implementations of Incremental")}</h1>
			<ul className="tags">{tags |> Array.map(x => <li key=x><span className="tag">{React.string(x)}</span></li>) |> React.array}</ul>
			<div className="author">
				<span>{React.string("nddung")}</span>
				<div className="created-from"></div>
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
	let make = (~headings, ~article_body) => {
		<>
			<nav className="toc">
				<ol>
					{headings |> Array.map(x => {
						let (level, title, id) = x;
						<li key=id>
							<a href=Printf.sprintf("#%s", id)>
								<span>{React.string(level)}</span>
								<span>{React.string(title)}</span>
							</a>
						</li>
					}) |> React.array}
				</ol>
			</nav>
			<main className="markdown">
				{React.string(article_body)}
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
		let headings = [|
			("1", "Overview", "overview"),
			("1.1", "Related works", "related-works"),
		|];
		let article_body = "
In computer science, graph algorithm complexity analysis is the study of the computational resources required to solve problems on graph data structures. This article provides a comprehensive examination of time complexity for fundamental graph algorithms, including breadth-first search (BFS), depth-first search (DFS), Dijkstra's algorithm, and the Floyd-Warshall algorithm.

Understanding these complexities is essential for algorithm selection and optimization in practical applications ranging from network routing to social network analysis.
		";
		let id = React.useMemo1(() => to_string(currentTab), [|currentTab|]);
		let url = ReasonReactRouter.useUrl();
		React.useEffect0(() => {
			let id = get_item_id(url.search);
			Js.Console.log(id);
			None
		});
		<>
			<header>
				<Component__header />
			</header>
			<div className=Printf.sprintf("innerbody %s", id)>
				<nav>
					<button onClick={_ => setCurrentTab(_ => `Article)} className={"article " ++ (currentTab == `Article ? "selected" : "")}>
						<label>{React.string("article")}</label>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Discussion)} className={"discussions " ++ (currentTab == `Discussion ? "selected" : "")}>
						<label>{React.string("discussions")}</label>
						<data className="count">{React.int(24)}</data>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Pullrequest)} className={"pullrequests " ++ (currentTab == `Pullrequest ? "selected" : "")}>
						<label>{React.string("pull-requests")}</label>
						<data className="count">{React.int(Array.length(pullrequests))}</data>
					</button>
					<button onClick={_ => setCurrentTab(_ => `Log)} className={"log " ++ (currentTab == `Log ? "selected" : "")}>
						<label>{React.string("git-log")}</label>
					</button>
				</nav>
				{ switch (currentTab) {
				| `Article =>
					<>
						<header><ArticleHeader tags /></header>
						<div className="innerbody"><ArticleBody headings article_body /></div>
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
