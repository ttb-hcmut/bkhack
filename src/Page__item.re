[@page "/item"]
open Melange__containers.Fun
open Bkhack

let to_string = fun
| `Article => "article"
| `Discussion => "discussions"
| `Pullrequest => "pullrequests"
| `Log => "log"
| `Edit => "edit"

module ItemNav = {
  [@react.component]
  let make = (~currentTab,~setCurrentTab,~prCount) => {
    <>
    <button onClick={_ => setCurrentTab(_ => `Article)} className={"article " ++ (currentTab == `Article ? "selected" : "")}>
      <label>{React.string("article")}</label>
    </button>
    <button onClick={_ => setCurrentTab(_ => `Discussion)} className={"discussions " ++ (currentTab == `Discussion ? "selected" : "")}>
      <label>{React.string("discussions")}</label>
      <data className="count">{React.int(24)}</data>
    </button>
    <button onClick={_ => setCurrentTab(_ => `Pullrequest)} className={"pullrequests " ++ (currentTab == `Pullrequest ? "selected" : "")}>
      <label>{React.string("pull-requests")}</label>
      <data className="count">{React.int(prCount)}</data>
    </button>
    <button onClick={_ => setCurrentTab(_ => `Log)} className={"log " ++ (currentTab == `Log ? "selected" : "")}>
      <label>{React.string("history")}</label>
    </button>
    <button onClick={_ => setCurrentTab(_ => `Edit)} className={"edit " ++ (currentTab == `Edit ? "selected" : "")}>
      <label>{React.string("editor")}</label>
    </button>
    </>
  }
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

module DiscussionHint = {
	[@react.component]
	let make = () => {
		<>
			<div className="logo" />
			<h1>{React.string("discussions")}</h1>
			<div className="sub">
				<span className="command">{React.string("discuss --thread=main")}</span>
				<span className="summary">
					<data className="comments" value=Int.to_string(13)>{React.int(13)}</data>
					<data className="karma" value=Int.to_string(364)>{React.int(364)}</data>
				</span>
			</div>
			<button className="action">{React.string("new comment")}</button>
		</>
	}
}

module DiscussionFilter = {
	[@react.component]
	let make = () => {
    <input />
	}
}


module DiscussionBody = {
  let decodeJson = (json) => {
    let open Fetch.Syntax;
    json
    >>= (undecoded => {
    let arrayOfDict = undecoded 
      |> Js.Json.decodeArray
      |> Option.value(~default=[||])
      |> Array.map(x => {
        let newDictNoJson = Js.Dict.empty();
        x
        |> Js.Json.decodeObject
        |> Option.value(~default=Js.Dict.empty())
        |> Js.Dict.entries
        |> Array.iter(((key, value)) =>
          switch (Js.Json.decodeString(value)) {
          | Some(s) => Js.Dict.set(newDictNoJson, key, s)
          | None => ()
          }
        );
        newDictNoJson
      })
      return(arrayOfDict)
    })
  };
  module rec Comments: {
    [@react.component]
		let make: (~cid: string, ~content: string, ~autoExpand: int) => React.element; } =
	{
		[@react.component]
		let make = (~cid, ~content, ~autoExpand) => {
			let (replies,setReplies) = React.useState(() => [||]);
			let (showRep, setShowRep) = React.useState(() => false);
			let (showMore, setShowMore) = React.useState(() => true);
			let limit = 3;
			// opening concept: Js.Promise.()
			let fetchReplies = () => {
				let open Fetch.Syntax;
				Fetch.fetch(Env.backend ++ "/api/comment"
					++ "?limit="  ++ string_of_int(limit)
					++ "&offset=" ++ string_of_int(Array.length(replies))
					++ "&parent=" ++ cid)
				>>= Fetch.Response.json
				|> decodeJson
				>>= (aod => {
					setReplies( x => Array.append(x,aod));
					setShowMore( _ => Array.length(aod) < limit ? false : true);
					Js.Promise.resolve(aod)
				})
				>!= (err => {
						Js.log(err);
						setShowMore( _ => false);
						return([||])
					})
				|> ignore;
			};
			let revealReplies = () => {
				if (Array.length(replies) == 0 && showMore){
					fetchReplies();
				};
				setShowRep(s => !s);
			};
			React.useEffect0(()=>{
				if (autoExpand > 0){
					revealReplies();
				}
				None
			});
			<li key={"comment"++cid} className="comments">
				<div className="content">{React.string(content)}</div>
				<button className="show-replies"
				onClick={ _ => revealReplies() }>
					{React.string((showRep?"Hide":"Show") ++ " replies")}
				</button>
				
				<span className="spacer" hidden={!showRep}/>
				<ol className="replies" hidden={!showRep}>
				{
					replies
					|>Array.map(x => {
						let cid = switch (Js.Dict.get(x,"id")) {
							| Some(v) => v 
							| None => "67"
							}
						let content = switch (Js.Dict.get(x,"content")) {
							| Some(v) => v 
							| None => "no content"
							};
							<Comments key=cid cid content autoExpand={autoExpand == 0 ? 0 : autoExpand-1}/>
						})
					|>React.array
				}
				</ol>
				<button className="more-replies"
				onClick={ _ => fetchReplies() }
				hidden={!showRep || !showMore}>
					{React.string("More replies")}
				</button>
			</li>
		}
	};
	[@react.component]
	let make = (~post) => {
    let (comments,setComments) = React.useState(() => [||]);
    let (showMore, setShowMore) = React.useState(() => true);
    let limit = 3;
    let aExpand = 3;
    // opening concept: Js.Promise.()
    let fetchComments = () => {
      let open Fetch.Syntax;
      Fetch.fetch(Env.backend ++ "/api/comment"
        ++ "?limit="  ++ string_of_int(limit)
        ++ "&offset=" ++ string_of_int(Array.length(comments))
        ++ "&parent=" ++ post)
      >>= Fetch.Response.json
      |> decodeJson
      >>= (aod => {
        setComments( x => Array.append(x,aod));
        setShowMore( _ => Array.length(aod) < limit ? false : true);
        Js.Promise.resolve(aod)
      })
      >!= (err => {
          Js.log(err);
          setShowMore( _ => false);
          return([||])
        })
      |> ignore;
    };
    
    React.useEffect0( () => {
      fetchComments();
      None
    });

    <>
      <ol>
      {
        comments
        |>Array.map(x => {
          let cid = switch (Js.Dict.get(x,"id")) {
            | Some(v) => v 
            | None => "67"
            }
          let content = switch (Js.Dict.get(x,"content")) {
            | Some(v) => v 
            | None => "no content"
            };
            <Comments key=cid cid content autoExpand=aExpand />
          })
        |>React.array
      }
      </ol>
      <button className="more-replies"
      onClick={ _ => fetchComments() }
      hidden={!showMore}>
        {React.string("More replies")}
      </button>
      // {comments |> Array.map(x => {
      //   let (id, level, authorname, content) = x;
      //   <li key=id className=Printf.sprintf("level-%d", level)>
      //     <article>
      //       <header>
      //         <span className="author">{React.string(authorname)}</span>
      //       </header>
      //       <div className="content">
      //         {React.string(content)}
      //       </div>
      //       <div className="counter">
      //         <data>{React.int(41)}</data>
      //       </div>
      //     </article>
      //   </li>
      // }) |> React.array}
    </>
	}
}

module PullrequestsHint = {
	[@react.component]
	let make = () => {
		<>
			<div className="logo" />
			<h1>{React.string("pull requests")}</h1>
			<div className="sub">
				<span className="command">{React.string("pr --list")}</span>
				<span className="summary">
					<data className="pr-open" value=Int.to_string(13)>{React.int(13)}</data>
					<data className="pr-closed" value=Int.to_string(364)>{React.int(364)}</data>
				</span>
			</div>
			<button className="action">{React.string("new pr")}</button>
		</>
	}
}

module PullrequestsFilter = {
	[@react.component]
	let make = () => {
		<input />
	}
}

module PullrequestsBody = {
	[@react.component]
	let make = (~pullrequests) => {
		<ul>
			{pullrequests |> Array.map(x => {
				let (_id, _post_id, title) = x;
				<li>
					<span>{React.string(title)}</span>
				</li>
			}) |> React.array}
		</ul>
	}
}

module At_repo_0(S : {
	include Experimental.S;
	let tgt_post_id : string }) =
{
	open S
	let rec q' = () =>
		foreach(prs') @@ o =>
		where(Pull_request.post_id(o) =@ string(tgt_post_id)) @@ () =>
		yield(o)
	and prs' = () => table @@ ("pullrequests", prs())
	let q = observe(q')
}

module App = {
	[@react.component]
	let make = () => {
		let (currentTab, setCurrentTab) = React.useState(() => `Article);
		let (pullrequests, setPrs) = React.useState(() => [||]);
		let tags = [| "Algorithm", "Rust" |];
		let headings = [|
			("1", "Overview", "overview"),
			("1.1", "Related works", "related-works"),
		|];
    let post = "1"
		let article_body = "
In computer science, graph algorithm complexity analysis is the study of the computational resources required to solve problems on graph data structures. This article provides a comprehensive examination of time complexity for fundamental graph algorithms, including breadth-first search (BFS), depth-first search (DFS), Dijkstra's algorithm, and the Floyd-Warshall algorithm.

Understanding these complexities is essential for algorithm selection and optimization in practical applications ranging from network routing to social network analysis.
		";
		let id = React.useMemo1(() => to_string(currentTab), [|currentTab|]);
		let url = ReasonReactRouter.useUrl();
		let (sidebarState, setSidebarState) = React.useState( _ => "state0");
		let module X = Experimental;
		React.useEffect0(Effect.async @@ () => Fetch.Syntax.({
			let id = Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"));
			let* res = X.Fetch.all(module At_repo_0(
				{ include X.GenSQL; let tgt_post_id = id }))(module Env);
			let  row = fun | ([id, post_id, title, ...[]]) => (Option.get(Js.Json.decodeNumber(id)), Option.get(Js.Json.decodeNumber(post_id)), Option.get(Js.Json.decodeString(title))) | _ => failwith("no");
			let parse = {
				let per_row = row % Array.to_list % Option.get % Js.Json.decodeArray;
				return % Array.map(per_row) % Option.get % Js.Json.decodeArray };
			let* dict = Fetch.Response.json(res) >>= parse;
			setPrs(_ => dict);
			return @@ ()
		}));
		<>
			<header>
				<Component__header />
			</header>	
			<nav className=sidebarState>
				<ItemNav currentTab setCurrentTab prCount=Array.length(pullrequests)/>
			</nav>
			<main className={sidebarState ++ " " ++ id}>
					<>
						<header className=Printf.sprintf("only %s", to_string(`Article))><ArticleHeader tags /></header>
						<div className=Printf.sprintf("innerbody only %s", to_string(`Article))><ArticleBody headings article_body /></div>
					</>
					<>
						<header className=Printf.sprintf("only %s", to_string(`Discussion))>
							<DiscussionHint />
							<nav>
								<DiscussionFilter />
							</nav>
						</header>
						<main className=Printf.sprintf("only %s", to_string(`Discussion))><DiscussionBody post /></main>
					</>
					<>
						<header className=Printf.sprintf("only %s", to_string(`Pullrequest))>
							<PullrequestsHint />
							<nav>
								<PullrequestsFilter />
							</nav>
						</header>
						<main className=Printf.sprintf("only %s", to_string(`Pullrequest))><PullrequestsBody pullrequests /></main>
					</>
			</main>
			<button 
				className={"show-hide-sidebar " ++ sidebarState}
				onClick={_=>{
					if (sidebarState == "state0")
					{
						setSidebarState(_ => "state1");
					}
					else
					{
						setSidebarState(_ => "state0");
					}
				}}
				>
			</button>
			<aside className=sidebarState>
				<Component__sidebar />
			</aside>
			
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
