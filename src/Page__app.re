[@page "/"]
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

let string = React.string;

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
			<Component__header />
		</>
	}
};

module About = {
	[@react.component]
	let make = () => {
		<>
			<Component__header />
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
			<Component__header />
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
		<Component__header />
		<div className="mainpad project_frontpage">
			<header>
				<img className="logo" />
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
			<Component__header />
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

module Wifi = {
	[@react.component]
	let make = () => {
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 11a9 9 0 0 1 9 9"></path><path d="M4 4a16 16 0 0 1 16 16"></path><circle cx="5" cy="19" r="1"></circle></svg>
	}
}

module HintPanel = {

	let command = "feed --sort=hot --filter";

	[@react.component]
	let make = () => {
		<>
			// <img className="logo" src="/assets/icon__wifi.svg" />
			<div className="logo">
				<Wifi />
			</div>
			<h1>
				{string("home feed")}
			</h1>
			<div className="sub">
				<span className="command">{string(command)}</span>
			</div>
		</>
	}
}

module Filter = {
	[@react.component]
	let make = () => {
		<form className="dashboard-filter">
			<input />
			<select>
				<option>{string("hot")}</option>
				<option>{string("new")}</option>
				<option>{string("top-voted")}</option>
				<option>{string("most-discussed")}</option>
				<option>{string("recent-activity")}</option>
			</select>
			<select>
				<option>{React.int(10)}</option>
				<option>{React.int(25)}</option>
				<option>{React.int(50)}</option>
				<option>{React.int(100)}</option>
			</select>
		</form>
	}
}

module Dashboard = {

	// sidebar stuff
	module DashboardSideBar = {

		module SideBarNotes = {

			[@react.component]
			let make = () => {
				// placeholder
				let placeholder = [
					"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar.",
					"Fibonacci heap practical considerations",
					"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar."
				];
				let (noteList,setNoteList) = React.useState(()=>[]);
  				let (expanded, setExpanded) = React.useState(() => false);

				React.useEffect0(() => {
					// fetch notes here
					setNoteList(_ => placeholder);

					None;
				});
				
					// Some implementation to add a new note
				let createNewNote =  _ => ();


				// return element
				<div id="sidebar-notes">
					<header> {string("My Notes")} </header>
					{
						if (List.length(noteList)>2)
						{	
							<button onClick={ _ => setExpanded( _ => !expanded ) }>
							<span className="vert">{string( expanded ? ">":"<")}</span> 
							{ string( expanded ? "Shrink" : "Expand" ) }
							</button>
						}
						else
						{ <> </>}
					}
					{
						if (List.length(noteList) <=0 )
						{
							<div>{string("You have no notes yet!")}</div>
						}
						else
						{
							<ul>
							{
								noteList
								|> List.take(expanded?10:2)
								|> List.mapi((index,item) => <li key=string_of_int(index) className={expanded?"":"truncated"}> {string(item)} </li>)
								|> Array.of_list
								|> React.array
							}
							</ul>
						}
					}
					<div>
						<button onClick={createNewNote}>{string("+ Add note")}</button>
					</div>
				</div>
			}
		};
		
		module SideBarFilters = {

			[@react.component]
			let make = () => {
				// placeholder filter list
				let placeholder = [
					(0,"Unseen"),
					(1,"Subscribed"),
					(2,"Modified"),
					(3,"Verified")
				];
				let (filterList,setFilterList) = React.useState(()=>[])
				let (activeFilters, setActiveFilters) = React.useState(()=>[]);
				
				React.useEffect0(() => {
					// fetch notes here
					setFilterList(_ => placeholder);

					None;
				});

				let isActive = (id) => List.mem(id,activeFilters);

				let toggleActive = (id:int) => {
					if (List.mem(id,activeFilters))
					{
						setActiveFilters(_=>List.filter(x => x != id, activeFilters));
					}
					else
					{
						setActiveFilters(_=>[id,...activeFilters]);
					}
					// send filter data to refresh the feed here (usecontext?)
				};

				// return element
				<div id="sidebar-filters">
					<header> {string("Quick Filters")} </header>
					{
								filterList
								|> List.map(((id,name)) =>
									<div onClick={_=>toggleActive(id)} key=string_of_int(id)>
										<input id=string_of_int(id) type_="checkbox" 
											checked={isActive(id)}
											onChange={_=>toggleActive(id)}/>
										<label htmlFor=string_of_int(id)>
										{string(name)}
										</label>
									</div>)
								|> Array.of_list
								|> React.array
					}
				</div>
			}
		};
		
		module SideBarTags = {

			[@react.component]
			let make = () => {
				// placeholder hot tags list
				let placeholder = [
					(0,"AI"),
					(1,"IOT"),
					(2,"Quantum"),
					(3,"Security")
				];
				let (tagList,setTagList) = React.useState(()=>[])
				let (activeTag, setActiveTag) = React.useState(()=>None);
				
				React.useEffect0(() => {
					// fetch tags here
					setTagList(_ => placeholder);

					None;
				});

				let selectTag = (id:int) =>
				{
					setActiveTag(_=>Some(id));

					// send tag data to refresh the feed here (usecontext?)
				};

				// return element
				<div id="sidebar-tags">
					<header> {string("Popular Tags")} </header>
					{
								tagList
								|> List.map(((id,name)) =>
									<button onClick={_=>selectTag(id)} className={activeTag==Some(id)?"active":""} key=string_of_int(id)>
										{string(name)}
									</button>)
								|> Array.of_list
								|> React.array
					}
				</div>
			}
		};
		
		module SideBarActivities = {

			[@react.component]
			let make = () => {
				let (activities,setActivities) = React.useState(()=>[]);
				
				// placeholder timestamp generators (you'd just fetch the timestamp string when fetching)
				let timeAgo = (ms: int): string => {
					let now =
						Js.Date.make()
						|> Js.Date.getTime
						|> int_of_float;

					let diffMs = now - ms;

					let seconds = diffMs / 1000;
					let minutes = seconds / 60;
					let hours = minutes / 60;
					let days = hours / 24;

					if (seconds < 10) {
						"just now"
					} else if (seconds < 60) {
						string_of_int(seconds) ++ "s ago"
					} else if (minutes < 60) {
						string_of_int(minutes) ++ "m ago"
					} else if (hours < 24) {
						string_of_int(hours) ++ "h ago"
					} else {
						string_of_int(days) ++ "d ago"
					};
				};
				// placeholder hot tags list
				let placeholder = [ //(activity_id,activity_type, author, content, timestamp)
					(0, "commented","@dr.kim","This is a great resource on getting started with llms",timeAgo(69420)),
					(1, "opened issue","@prof.wilson","Link nolonger points to the paper",timeAgo(69420)),
					(2, "merged PR","@tran.phu","Breakthrough in quantum computing",timeAgo(69420)),
				];

				React.useEffect0(() => {
					// fetch activities here
					setActivities(_ => placeholder);

					None;
				});

				// return element
				<div id="sidebar-activities">
					<header> {string("Recent Activities")} </header>
					<ul>
					{
								activities
								|> List.map(((activity_id,activity_type, author, content, timestamp)) =>
									<li key=string_of_int(activity_id)>
										<a href={"/notification/"++string_of_int(activity_id)}>
										<div className="activity">
											<span className="agent">{string(author++" ")}</span>
											<span className="verb">{string(activity_type++" ")}</span>
											<span className="content">{string(content++" ")}</span>
										</div>
										<div className="time">
											{string(timestamp)}
										</div>
										</a>
									</li>)
								|> Array.of_list
								|> React.array
					}
					</ul>
				</div>
			}
		};

		[@react.component]
		let make = () => {
			<>
				<SideBarNotes/>
				<SideBarFilters/>
				<SideBarTags/>
				<SideBarActivities/>
				<div>{string("my stats")}</div>
				<div>{string("admin panel")}</div>
			</>
		}
	}

	module Card = {
		[@react.component]
		let make = (~rank, ~title) => {
			<>
				<div className="counter">
					<span>{React.int(rank)}</span>
				</div>
				<header>
					<a href="item/?id=lol">{string(title)}</a>
				</header>
				<footer>
					<div className="has-left-indicator tagline">
						<span className="tag" title="Algorithm, Optimization">{string("AgAa")}</span>
					</div>
					<div className="status">
						<span>{string("verified")}</span>
					</div>
					<div className="activities">
						<span className="comments">
							{React.int(12)}
						</span>
						<span className="pullrequests">
							{React.int(12)}
						</span>
					</div>
					<div className="last-activity">
						<span className="verb">{string("commented")}</span>
						<span className="agent">{string("@kinten108101")}</span>
						<span className="theme"></span>
						<span className="time">{string("2h ago")}</span>
					</div>
					<div className="created-from">
						<span>{string("created ")}</span><span>{string("2d ago")}</span>
					</div>
					<div className="ref">
						<span>{string("2000")}</span>
					</div>
				</footer>
			</>
		}
	}

	[@react.component]
	let make = () => {
		let testitems =
		[
			(198, "Reconciling Abstractions with High Performance"
			)
		,
			(342, "Algebra-driven Design"
			)
		,
			(034, "Reverse-engineer a PDF"
			)
		,
			(012, "Haskell School of Music"
			)
		,
			(123, "Compilers: Principles, Techniques, and Tools"
			)
		,
			(139, "Tsoding: I wrote an Emacs plugin"
			)
		,
			(752, "Why OCaml"
			)
		,
			(711, "Seven Implementations of Incremental"
			)
		,
			(812, "Attention is not all you need"
			)
		,
			(820, "Neural Network in Assembly"
			)
		];

		let (showSideBar, setShowSideBar) = React.useState(()=> true);

		<>
			<header>
				<Component__header />
			</header>
			<nav>
				<header>
					<HintPanel />
				</header>
				<Filter />
			</nav>
			<main><ol>
			{ testitems
				|> List.map(((rank, title)) => {
					<li
						key=title
					>
						<Card
							rank
							title
						/>
					</li>
				})
				|> Array.of_list |> React.array
			}
			</ol></main>
			<footer role="navigation">
				<button>{string("prev")}</button>
				<button>{string("next")}</button>
			</footer>
			<button className="sidebar-show" onClick={_ => setShowSideBar(_ => !showSideBar)}>{string(showSideBar ? "> Hide Sidebar" : "< Show Sidebar")}</button>
			<aside className={showSideBar ? "active" : ""}>
				<DashboardSideBar/>
			</aside>
		</>
	}
};

module ItemPage {
	[@react.component]
	let make = (~item_id) => {
		ignore(item_id);
		<>
		</>
	}
}

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
		let url = ReasonReactRouter.useUrl();
		Js.Console.log(url);
		switch (url.path) {
		| [] =>
			<Dashboard />
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
