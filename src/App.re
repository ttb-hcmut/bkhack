module Post = {
	type t =
		{ author: string
		, message: string
		}
};

module Thread_data = {
	type t =
		{ title: string
		, posts: list(Post.t)
		, rank : int
		, author: string
		}
};

module Decode = {
	open Melange_json;

	let post = json => {
		open Post;
		Of_json.
		{ author: json |> field("author", string)
		, message: json |> field("message", string)
		};
	};

	let thread_data = json => {
		open Thread_data;
		Of_json.
		{ title : json |> field("title", string)
		, posts : json |> field("posts", list(post))
		, rank  : json |> field("rank", int)
		, author: json |> field("author", string)
		}
	};

	module Response = {
		open Js;

		let post = json =>
			post(json) |> Promise.resolve

		let thread_data = json =>
			thread_data(json) |> Promise.resolve
	};
};

let string = x => React.string(T.__(x));

module Header = {
	[@react.component]
	let make = () => {
		<header>
			<a className="logo" href="/">{string("BK Hack")}</a>
			<nav className="vertsep">
				<a href="/">{string("ban tin")}</a>
				<a href="/projects">{string("ban du an nguon mo")}</a>
				<a href="/about">{string("ve chung toi")}</a>
			</nav>
			<button onClick={_ => ReasonReactRouter.replace("/login")}>{string("dang nhap")}</button>
		</header>
	}
};

module Teaser = {
	[@react.component]
	let make = () => {
		<div className="teaser">
			<header className="blink">{string("@")}</header>
			<p><span className="bk">{string("BK")}</span><span className="hack">{string("Hack")}</span>{string(" is under construction")}</p>
		</div>
	}
}

module Login = {
	[@react.component]
	let make = () => {
		<div>
			<form>
				<div>
					<label htmlFor="username">{string("username")}</label>
					<input name="username" id="username" />
				</div>
				<div>
					<label htmlFor="password">{string("password")}</label>
					<input name="password" id="password" />
				</div>
				<button>{string("Login")}</button>
			</form>
		</div>
	}
}

module Home = {
	[@react.component]
	let make = () => {
		<>
			<Header />
		</>
	}
};

module About = {
	[@react.component]
	let make = () => {
		<>
			<Header />
			<hgroup>
				<h1>{string("About us")}</h1>
				<p>{string("by Le Nguyen Gia Bao")}</p>
			</hgroup>
			<p>{string("
During my third year at HCMUT, I (Le
Nguyen Gia BAO aka. Kinten Le) got the utmost
pleasure to work with Ho Gia TUONG and
Vu Hoang TUNG. I've got the pleasure to
work with these two kind friends.
During this time, I and Tung talked
about our haboring interest of building
a kind of group (or school club, community, ...) where we work on free
softwares and teach each other
programming, something that was lacking
in HCMUT at the time. So the three
friends started formulating a plan: a
website platform to teach other and to
advertise our free softwares.")}
			</p>
			<p>
			<b>{string("TTB HCMUT")}</b>
			{string("
is an indie developer group
focusing on the intersection of embedded systems, emulation
systems, functional programming, and
artificial intelligence. Our headquarter is at HCMUT (?).
")}
			</p>
			<p>{string("
The entry point is ")}
			<b>{string("BKHack")}</b>
			{string(", the social
news website focusing on computer
science and programming (and also, the
capstone project of Bao and Tuong).
")}
			</p>
			<p>{string("
Then there are our software projects.
All of our projects are listed at the
Projects page of BKHack. ")}
			<b>{string("Microcluster")}</b>
			{string(" is a Python interpreter
that parallelizes your Python codebase
and distributes work across multiple
small microcontroller-based computers;
and it is written in OCaml. #lorem(60)
")}
			</p>
			<p>{string("
Every year, BKHack and projects are
presented at computer science
conferences, featured in journals and
Programming Pearls in Viet Nam, Japan, and
around the world. We also take part in
various contests. All of these is our
activity and also our funding model so
that we can continue developing and
running our products!
")}
			</p>
			<p>{string("
Of course, it's important that our
software is free, contributions and
suggestions are welcomed!
")}
			</p>
		</>
	}
};

module Promotion_list = {
	module Item = {
		[@react.component]
		let make = (~name, ~description) => {
			let name_a =
				switch (name) {
				| `Page (x) => x
				| `PageWithId (x, _) => x
				};
			let link =
				switch (name) {
				| `Page (x) => "~" ++ x
				| `PageWithId (_, x) => "~" ++ x
				};
			let url = ReasonReactRouter.useUrl();
			let next = s => (url.path |> String.concat("/")) ++ "/" ++ s;
			<div className="promotion-item">
				<header className="logo"></header>
				<header className="title">{string(name_a)}</header>
				<p className="description">{string(description)}</p>
				<a href=(next(link))>{string("Read more >>")}</a>
			</div>
		}
	}

	[@react.component]
	let make = () => {
		<>
			<Header />
			<div className="mainpad promotion_list">
				<h1>{string("Projects")}</h1>
				<p>{string("Know a bit of programming? Contribute to ttb-hcmut projects on GitHub! For more details e.g how to PR or report issues, visit our wiki.")}</p>
				<ul>{
					[ ((`PageWithId ("Microcluster", "microcluster")), "lol")
					, ((`PageWithId ("bachkhoa.typ", "bachkhoa-typ")), "A report template for Bach Khoa HCMUT students. Not affiliated with the HCMUT university.")
					]
					|> List.map(x => {
						let (x, description) = x;
						let key =
							switch (x) {
							| `Page (x) => x
							| `PageWithId (x, _) => x
							};
						<li key><Item name=x description=description /></li>
					})
					|> Array.of_list
					|> React.array
				}</ul>
			</div>
		</>
	}
};

module Project_frontpage__bachkhoatyp = {
	[@react.component]
	let make = (~paths) => {
		switch (paths) {
		| ["examples"] => <div>{string("lol")}</div>
		| [_, ..._] => failwith("dsf")
		| [] => {
		let url = ReasonReactRouter.useUrl();
		let next = s => "/" ++ (url.path |> String.concat("/")) ++ "/" ++ s;
		<>
		<Header />
		<div className="mainpad project_frontpage">
			<header>
				<img />
				<div>{string("bachkhoa.typ")}</div>
				<div>{string("A suite of Typst document templates for HCMUT")}</div>
			</header>
			<nav className="sub">
				<a href="https://github.com/ttb-hcmut/.github/tree/main/bachkhoa.typ">{string("Source code")}</a>
				<a href=(next("examples"))>{string("Examples")}</a>
				<a href=(next("manual"))>{string("Manual")}</a>
				<a href=(next("doc"))>{string("Documentation")}</a>
				<a href=(next("reference"))>{string("API Reference")}</a>
			</nav>
			<aside className="sidebar">
				<section className="mirror">
					<h2>{string("Mirrors")}</h2>
					<u>
						<li><a href="https://typst.app/universe/package/bachkhoa.typ">{string("Typst Universe")}</a></li>
					</u>
				</section>
				<section className="releases">
					<h2>{string("Releases")}</h2>
					<u>
						<li><a>{string("bachkhoa.typ-v0.1.0.tar.xz")}</a></li>
					</u>
				</section>
			</aside>
			<div className="content">
				<p>{string("A template for writing reports and thesises in Bach Khoa University of Technology of Ho Chi Minh City (HCMUT). We are not affiliated with HCMUT.")}</p>
			</div>
		</div>
		</>
		}}
	}
};

module Thread = {
  [@react.component]
  let make = (~item_id) => {
		let (threadData, setThreadData) = React.useState(_ => None);
		React.useEffect0(() => {
			print_endline(item_id);
			open Fetch;
			open Fetch_syntax;
			fetchWithInit(
				Env.backend ++ "/api/test-item",
				RequestInit.make(
					~headers=HeadersInit.make({
						// "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
						"Accept": "text/html,application/xhtml+xml;q=0.9,*/*;q=0.8",
					}), ()
				)
			)
			>>= (x => {
				let status = Response.status(x);
				let content_type =
					Response.headers(x)
					|> Headers.get("Content-Type")
					|> Option.get;
				switch (status, content_type) {
				| (503, "text/html; charset=utf-8") => {
					open Thread_data;
					setThreadData(_ => Some({
						title: "spinning up",
						rank: 0,
						author: "nobody",
						posts: []
					}));
					return(())
				}
				| (_, _) =>
					return(x)
					>>= Response.json
					>>= Decode.Response.thread_data
					>>= (x => setThreadData(_ => Some(x)) |> return)
				}
			})
			|> ignore;
			None
		});
    <>
			<Header />
			{ switch (threadData) {
			| None => React.null
			| Some(threadData) =>
				<main>
					<header>
						<hgroup>
							<h1>{string(threadData.title)}</h1>
							<a>{string("(")}<span>{string("https://github.com/lol")}</span>{string(")")}</a>
						</hgroup>
						<nav className="vertsep">
							<span className="spacesep">
								<span>{string({ threadData.rank |> Int.to_string } ++ " diem")}</span>
								<span>{string("t.g.")}</span>
								<span>{string(threadData.author)}</span>
								<span>{string("th.gi.")}</span>
								<span>{string("10 thang truoc")}</span>
							</span>
							<a>{string("phan tich")}</a>
							<span>{string({ open Thread_data; List.length(threadData.posts) |> Int.to_string } ++ " binh luan")}</span>
						</nav>
					</header>
					<ul>
					{ open Post;
						threadData.posts
						|> List.map(x =>
							<li key=x.message>
								<article>
									<header> {string(x.author)} </header>
									<p> {string(x.message)} </p>
								</article>
							</li>
						)
						|> Array.of_list
						|> React.array }
					</ul>
				</main>
			} }
			<footer>
				{string("phat trien boi nhom ttb-hcmut")}
			</footer>
    </>;
	};
};

module UnknownPage = {
	[@react.component]
	let make = () => {
		<div>
			<h1>{string("This page does not exist")}</h1>
		</div>
	}
};

module App = {
	[@react.component]
	let make = () => {
		let get_item_id = {
			let regexp = Js.Re.fromString("id=(.+)");
			str => Js.Re.exec(~str, regexp)
		};
		let url = ReasonReactRouter.useUrl();
		Js.Console.log(url);
		switch (url.path) {
		| [] => <Teaser />
		| ["about"] => <About />
		| ["projects"] => <Promotion_list />
		| ["projects", "~bachkhoa-typ", ...paths] => <Project_frontpage__bachkhoatyp paths />
		| ["~debug", "item"] =>
			switch (get_item_id(url.search)) {
			| None => failwith("fuck")
			| Some(item_id) =>
				let item_id =
					Js.Re.captures(item_id)
					-> Array.get(1)
					|> Js.Nullable.toOption
					|> Option.get;
				<Thread item_id />
			}
		| _ => <UnknownPage />
		}
	}
};

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
