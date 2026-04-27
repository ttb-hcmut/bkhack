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
	let make = (~tags, ~info) => {
		let (_id, title, creator_name, _) = info;
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
			<h1>{React.string(title)}</h1>
			<ul className="tags">{tags |> Array.map(x => <li key=x><span className="tag">{React.string(x)}</span></li>) |> React.array}</ul>
			<div className="author">
				<span>{React.string(creator_name)}</span>
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

let make_html_obj : string => Js.t({ .. __html : string }) = [%mel.raw "function (s) { return { __html : s }; }"]

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
				<div dangerouslySetInnerHTML={make_html_obj @@ article_body} />
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
	let make = (~pullrequests, ~prsExpand, ~expand_this) => {
		<ul>
			{pullrequests |> Array.map(x => {
				let ((id, _post_id, _contributor_id, title, _desc), contributor_name) = x;
				let is_expanded = List.assoc_opt(id, prsExpand) |> Option.value(~default=false);
				<li key=string_of_int(id) className=("pull-request-row " ++ (is_expanded ? "expanded" : " "))>
					<button onClick={_ => expand_this(id)}></button>
					<span className="id">{React.int(id)}</span>
					<span className="title">{React.string(title)}</span>
					<span className="contributor">{React.string(contributor_name)}</span>
					<div className="expanded-content">
						<span className="id">{React.int(id)}</span>
						<span className="title">{React.string(title)}</span>
						<span className="contributor">{React.string(contributor_name)}</span>
					</div>
				</li>
			}) |> React.array}
		</ul>
	}
}

module At_repo_0'(S : {
	include Experimental.S;
	let tgt_post_id : int }) =
{
	open S
	let rec q' = () =>
		foreach(prs') @@ o =>
		where(Pull_request.post(o) =% int(tgt_post_id)) @@ () =>
		yield(o)
	and prs' = () => table @@ ("pullrequests", prs())
	let q = observe(q')
}

module At_repo_0(S : {
	include Experimental.S;
	let tgt_post_id : int }) =
{
	include At_repo_0'(S)
	module Json = Js.Json

	type t = array((int, int, int, string, string));

	let  row = [@warning "-8"] fun | [|id, post_id, contributor, title, description|] =>
		( Float.to_int(Json.decodeNumberExn(id)), Float.to_int(Json.decodeNumberExn(post_id)), Float.to_int(Json.decodeNumberExn(contributor)), Json.decodeStringExn(title), Json.decodeStringExn(description) );

	let json = {
		let per_row = row % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

module At_repo_1'(S : {
	include Experimental.S;
	let tgt_user_id : int }) =
{
	open S
	let rec q' = () =>
		foreach(users') @@ o =>
		where(User.id(o) =% int(tgt_user_id)) @@ () =>
		yield @@ o
	and users' = () => table @@ ("users", users())
	let q = observe(q')
}

module At_repo_1(S : {
	include Experimental.S;
	let tgt_user_id : int }) =
{
	include At_repo_1'(S)
	module Json = Js.Json

	type t = array((int, string))

	let row  = [@warning "-8"] fun | [|user_id, name|] =>
		( Float.to_int(Json.decodeNumberExn(user_id)), Json.decodeStringExn(name) );

	let json = {
		let per_row = row % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

module At_repo_2'(S : {
	include Experimental.S;
	let tgt_post_id : int }) =
{
	open S
	let rec q' = () =>
		foreach(posts') @@ o =>
		where(Post.id(o) =% int(tgt_post_id)) @@ () =>
		yield(o)
	and posts' = () => table @@ ("posts", posts())
	let q = observe(q')
}

module At_repo_2(S : {
	include Experimental.S;
	let tgt_post_id : int }) =
{
	include At_repo_2'(S)
	module Json = Js.Json

	type t = array((int, string, int, string));

	let  row = [@warning "-8"] fun | [|id, title, creator, text|] =>
		( Float.to_int(Json.decodeNumberExn(id)), Json.decodeStringExn(title), Float.to_int(Json.decodeNumberExn(creator)), Json.decodeStringExn(text) );

	let json = {
		let per_row = row % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

module App = {
	[@react.component]
	let make = () => {
		let (prsExpand, setPrsExpand) = React.useState(() => []);
		let (currentTab, setCurrentTab) = React.useState(() => `Article);
		let (pullrequests, setPrs) = React.useState(() => [||]);
		let (postInfo, setPostInfo) = React.useState(() => None);
		let tags = [| "Algorithm", "Rust" |];
    let post = "1"
		// Js.Console.log(a);
		let renderer = React.useMemo0(() => Melange__cmarkit.Cmarkit_html.renderer(~safe=false, ()));
		let art = React.useMemo2(() => {
			open Melange__cmarkit; open Cmarkit;
			postInfo |> Option.map @@ ((_, _, _, text) as postInfo) =>
			try ({
				let skel = text |> Doc.of_string(~strict=false);
				let block = Doc.block(skel) 
				let rec s = { fun
					| Block.Block_Heading((t, _)) => {
						[@warning "-8"] let (level, Inline.Text((textcontent, _))) = Block.Heading.((level(t), inline(t)));
						[(Int.to_string(level), textcontent, textcontent)] }
					| Block.Blocks((xs, _)) => xs |> List.map(s) |> List.flatten
					| _ => []
				};
				let headings = s(block) |> Array.of_list;
				(postInfo, headings, Melange__cmarkit.Cmarkit_renderer.doc_to_string(renderer, skel))
			}) {
				| Invalid_argument(msg) => { Js.Console.error("rendering error: '" ++ msg ++ "'"); failwith("something bad happened") }
				| Js.Exn.Error(x) => { Js.Console.error("js error: '" ++ Option.value(~default="", Js.Exn.message(x)) ++ "'"); failwith("sdf") }
			}
		}, (renderer, postInfo));
		let id = React.useMemo1(() => to_string(currentTab), [|currentTab|]);
		let url = ReasonReactRouter.useUrl();
		let (sidebarState, setSidebarState) = React.useState( _ => "state0");
		let module X = Experimental;
		let join = ((_, _, contributor_id, _, _) as it) => Fetch.Syntax.({
			let* user_info = X.Fetch.all(module At_repo_1(
				{ include X.GenSQL; let tgt_user_id = contributor_id }))(module Env);
			let (_, name) = user_info[0];
			return @@ (it, name)
		});
		React.useEffect0(Effect.async @@ () => Fetch.Syntax.({
			let id = Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"));
			let* prs = X.Fetch.all(module At_repo_0(
				{ include X.GenSQL; let tgt_post_id = int_of_string(id) }))(module Env);
			let* dict = Js.Promise.all @@ Array.map(join) @@ prs;
			return @@ ignore @@ setPrs(_ => dict);
		}));
		React.useEffect0(Effect.async @@ () => Fetch.Syntax.({
			let post_id = Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"));
			let* posts = X.Fetch.all(module At_repo_2(
				{ include X.GenSQL; let tgt_post_id = int_of_string(post_id) }))(module Env);
			let (_, post_title, creator_id, post_text) = posts[0];
			let* users = X.Fetch.all(module At_repo_1(
				{ include X.GenSQL; let tgt_user_id = creator_id }))(module Env);
			let (_, creator_name) = users[0];
			return @@ ignore @@ setPostInfo(_ => Some((post_id, post_title, creator_name, post_text)))
		}));
		let on_prs_update_expand = React.useMemo1(((), id) => {
			switch (List.assoc(id, prsExpand)) {
			| v => {
				let newv = !v;
				let newdict = List.cons((id, newv), List.remove_assoc(id, prsExpand));
				setPrsExpand(_ => newdict)
			}
			| exception Not_found => {
				let newdict = List.cons((id, true), prsExpand);
				setPrsExpand(_ => newdict)
			}
			}; ()
		}, [|prsExpand|]);
		let show = (x, f) => switch (x) { | Some(info) => f(info) | None => { <> </> } };
		show(art) @@ ((postInfo, headings, article_body)) =>
		<>
			<header>
				<Component__header />
			</header>	
			<nav className=sidebarState>
				<ItemNav currentTab setCurrentTab prCount=Array.length(pullrequests)/>
			</nav>
			<main className={sidebarState ++ " " ++ id}>
				<>
					<header className=Printf.sprintf("only %s", to_string(`Article))><ArticleHeader tags info=postInfo /></header>
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
					<main className=Printf.sprintf("only %s", to_string(`Pullrequest))><PullrequestsBody pullrequests prsExpand expand_this=on_prs_update_expand /></main>
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
