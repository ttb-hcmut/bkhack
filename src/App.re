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

module App = {
  let style =
    ReactDOM.Style.make(
			~fontSize="1.5em",
			~display="flex",
			~gap="0.5em",
			()
		);

	let string = x => React.string(T.__(x));

  [@react.component]
  let make = () => {
		let (threadData, setThreadData) = React.useState(_ => None);
		React.useEffect0(() => {
			open Fetch;
			open Fetch_syntax;
			fetch("http://0.0.0.0:5000/api/test-item")
			>>= Response.json
			>>= Decode.Response.thread_data
			>>= (x => setThreadData(_ => Some(x)) |> return)
			|> ignore;
			None
		});
    <>
			<header>
				<a className="logo" href="/">{string("BK Hack")}</a>
				<nav className="vertsep">
					<a href="/">{string("ban tin")}</a>
					<a href="/projects">{string("ban du an nguon mo")}</a>
				</nav>
				<button>{string("dang nhap")}</button>
			</header>
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

module ReactDOM0 = {
	let querySelector = x =>
		switch (ReactDOM.querySelector(x)) {
		| Some(x) => x
		| None =>
			Js.Console.error("khong tim thay element #root");
			failwith("lol")
		}
}

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App />);
}
