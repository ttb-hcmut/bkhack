let to_string = x => switch (x) {
	| `Article => "article"
	| `Discussion => "discussion"
	| `Pullrequest => "pullrequest"
	| `Log => "log"
}

module ArticleHeader = {
	[@react.component]
	let make = () => {
		<>
			<div className="counter"></div>
			<header></header>
			<div className="actions"></div>
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

module App = {
	[@react.component]
	let make = () => {
		let (currentTab, setCurrentTab) = React.useState(() => `Article);
		let id = React.useMemo1(() => to_string(currentTab), [|currentTab|]);
		let url = ReasonReactRouter.useUrl();
		React.useEffect(() => {
			Js.Console.log(url);
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
							<header>{React.string("hi")}</header>
							<div className="innerbody"></div>
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
