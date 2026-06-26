[@page "/"]
open Stdlib
open Melange__containers.Fun
open Auth

let%comptime test__basic = assert({
	Shellgen.observe (Shellgen.({ feed @| nil ;})) == "feed"
})

let%comptime test__complex = assert({
	let open Shellgen;
	observe {
		let sub = sub { feed @| Split_by.count(1) @| nil };
		feed @| sub @| Split_by.count(10) @| nil ;}
	==
		"feed | { feed | split -c 1 ;} | split -c 10"
})

module Wifi {
	[@react.component]
	let make = () =>
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 11a9 9 0 0 1 9 9"></path><path d="M4 4a16 16 0 0 1 16 16"></path><circle cx="5" cy="19" r="1"></circle></svg>
}

module HintPanel {

	let%comptime feed__hint = {
		module At__sh (Syntax : Shell__sym.SymL) {
			let command = Syntax.observe @@ Syntax.(
				feed @| Split_by.count(10) @| nil )
		}

		open At__sh(Shellgen)

		Css_gen.Stylesheet.format1(~className=__name__, {| 
			&.command { --page-command: ? ;}
		|}, command)

	};

	[@react.component]
	let make = () =>
    Auth.AuthContext.use() |> auth =>
		<>
		<div className="logo"> <Wifi /> </div>
		<h1 className="home-feed" />
		<div className="sub">
			<span className={"command "++feed__hint} />
		</div>
		<button className="create-post"
			onClick={_ =>
				auth.checkAuth()?
				Js__dom.Window.Location.href_set(
					"/new/")
				:
				auth.forceAuth()
			} />
		</>
}

module Filter {
	open Melange__iter
	open React

	let methods = xs =>
	{ let children = Iter.map @@ s => <option key=s>{string(s)}</option>;
		<select id="showMethods" name="showMethods">
			{React.array @@ Iter.to_array @@ children @@ Iter.of_list @@ xs }
		</select>
	};

	let options = xs =>
	{ let children = Iter.map @@ n => <option key={string_of_int(n)}>{React.int(n)}</option>;
		<select id="showCount" name="showCount">
			{React.array @@ Iter.to_array @@ children @@ Iter.of_list @@ xs}
		</select>
	};

	[@react.component]
	let make = (~setResult) =>
    <Pagination.App 
      defaultLimit = 3
      countApi={"/api/post/count?"}
      fetchApi={"/api/post/list?"}
      options={[
        Pagination.textinput( ~action = "search"
                            , ~placeholder = "Search..."
                            , ~is_secondary = true
                            , ())
			, Pagination.limit( ~action = "limit"
                        , ~placeholder = "012"
                        , ~options = [15,30,45]
                        , ())
      , Pagination.dropdown(  ~action = "searchby"
                            , ~options = ["title","author"])
      , Pagination.dropdown(  ~action = "sortby"
                            , ~options = ["merge","age"])
      , Pagination.dropdown(  ~action = "orderby"
                            , ~options = ["ascending","descending"])
      ]}
      setResult
    />
}

module Dashboard {
	open React

	module Card {
		[@react.component]
		let make = (
      ~rank
    , ~id
    , ~title
    , ~creator
    , ~verified
    , ~timestamp
    ) => {
      let (disCount,setDisCount) = React.useState(() => 0);
      let (tags,setTags) = React.useState(() => [||]);
      let fetchCommentCount = (~id) => {
        let open Fetch__syntax;
        Fetch.fetch(Env.backend ++ "/api/comment/count"
          ++ "?parent="  ++ id
          ++ "&type=post&recursive=true")
        >>= Fetch.Response.json
        >!= (err => {
            Js.log(err);
            return(Js.Json.number(0.0))
          })
        >>= (json => {
          let x = Js.Json.decodeNumber(json) |> Option.value(~default = 0.0);
          setDisCount(_ => int_of_float(x));
          Js.Promise.resolve(json)
        })
        |> ignore;
      };
      let fetchTags = (~id) => {
        let open Fetch__syntax;
        open Model.Tag;
        Fetch.fetch(Env.backend ++ "/api/tag/post"
          ++ "?postid="  ++ id)
        >>= Fetch.Response.json
        >>= Model.Decode.Response.tags
        >!= (err => {
            Js.log(err);
            Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
          })
        >>= (aod => {
          setTags(
            _ => aod
            |> Array.map((d) => 
              { Model.TagButTheColorIsAString.tag_id    : d.tag_id
              , Model.TagButTheColorIsAString.tag_name  : d.tag_name
              , Model.TagButTheColorIsAString.tag_nick  : d.tag_nick
              , Model.TagButTheColorIsAString.tag_color : d.tag_color |> Util.rgbaIntToHexString
              } 
            )
          )
          Js.Promise.resolve(aod)
        })
        |> ignore;
      };
      React.useEffect0(()=>{
        fetchCommentCount(~id=string_of_int(id))
        fetchTags(~id=string_of_int(id))
        None
      })
      ;
      <li>
        <div className="counter">
          <span>{React.int(rank)}</span>
        </div>
        <header>
          <a href={"item/?id="++string_of_int(id)}>{string(title)}</a>
          <span className="post_id">{id->React.int}</span>
        </header>
        <footer>
          <div className="has-left-indicator tagline">
            <ul>
            { open Model.TagButTheColorIsAString;
              tags 
              |> Array.map(x => 
              <li key={string_of_int(x.tag_id)}>
                <span className="tag" 
                title={x.tag_name}
                style={ReactDOM.Style.make(
                  ~color           = x.tag_color
                , ())}>
                  {React.string(x.tag_nick)}
                </span>
              </li>) |> React.array}
            </ul>
            // <span className="tag" "Algorithm, Optimization">{string("AgAa")}</span>
          </div>
          <div className="status">
            <span>{string(verified?"verified":"unverified")}</span>
          </div>
          <div className="activities">
            <span className="comments">
              {React.int(disCount)}
            </span>
            <span className="pullrequests">
              {React.int(67)}
            </span>
          </div>
          <div className="last-activity">
            // <span className="verb">{string("commented")}</span>
            <span className="agent">{string("@"++creator)}</span>
            // <span className="theme"></span>
            // <span className="time">{string("2h ago")}</span>
          </div>
          <div className="created-from">
            <span>{string("created ")}</span><span>{string(Util.utcToRelative(timestamp))}</span>
          </div>
          <div className="ref">
            <span>{string("2000")}</span>
          </div>
        </footer>
      </li>
		}
	}

	module At_repo_0'(U: {
		let paginate : 't. ((int, int) => 't) => 't
	}, S : Bkhack__experimental.S) = 
	{
		open S
		let rec q' = () =>
			foreach(posts') @@ o =>
			U.paginate(limit) @@ () =>
			yield(o)
		and posts' = () => table @@ ("posts", posts())
		let q = observe(q')
	}

	module At_repo_0(U: {
		let paginate : 't. ((int, int) => 't) => 't
	}, S : Bkhack__experimental.S) = 
	{
		include At_repo_0'(U, S)
		module Json = Js__json

		type t = array((int, string, int, string,int,int,string));

		let  row = [@warning "-8"] fun | [id, title, creator, text, verified, public, timestamp] =>
			( id        |> Json.decodeNumber |> Option.value(~default=67.)  |> Float.to_int
      , title     |> Json.decodeString |> Option.value(~default="someone messed up you shouldn't see this")
      , creator   |> Json.decodeNumber |> Option.value(~default=67.)  |> Float.to_int
      , text      |> Json.decodeString |> Option.value(~default="someone messed up you shouldn't see this")
      , verified  |> Json.decodeNumber |> Option.value(~default=0.)   |> Float.to_int
      , public    |> Json.decodeNumber |> Option.value(~default=0.)   |> Float.to_int
      , timestamp |> Json.decodeString |> Option.value(~default="someone messed up you shouldn't see this")
      )
		let json = {
			let per_row = row % Array.to_list % Json.decodeArrayExn;
			Array.map(per_row) % Json.decodeArrayExn
		}
	};

	let test = counts => task @@ Fetch__syntax.({
		let module X {
			include Bkhack__experimental;
			module Fetch = Firebase__fetch;
			module Gen = GenStructuredQuery };
		let* posts = X.Fetch.all((
			module At_repo_0({ let paginate = limit => limit(counts, 0) }, X.Gen)
		), (module Env));
		Js.Console.log(posts);
		return()
	});

  [@react.component]
  let make = () => {
		// let (counts, setCounts) = React.useState(() => 10);
    let (showHelp, setShowHelp) = useState(() => false);
    let on_help = x => setShowHelp(_ => x);
    React.useEffect1(() => {
      (module ReactDOM)->Component__help_menu.update_visibility(showHelp);
      None
    }, [|showHelp|]);
    Component__help_menu.use_escape(module Js__dom.Window) @@ useCallback0 @@ () => setShowHelp(_ => false);
		let memo_transition = React.useCallback0((url, url_args, k) => {
			Js.Console.log2(url, url_args);
			if (url == "" && url_args == []) { () } else k ()
		});
		// let url = ReasonReactRouter.useUrl();
		// let x_limit = useMemo1(() => {
		// 	let params = url.search->Util.parseQueryParams';
		// 	params |> List.assoc_opt("limit") |> Option.map(int_of_string)
		// }, [|url|]);
		let (items, setItems) = React.useState(() => [||]);
		let (_showHelp, setShowHelp) = React.useState(() => false);
		let (result, setResult) = React.useState(() => Js.Json.null);
		let (sidebarState, setSidebarState) = React.useState( _ => "state0");
    
    let fetchPostList = () => {
      setItems(_ => result |> Model.Decode.postListItems)
    }
    React.useEffect1(()=>{
      if (result != Js.Json.null)
        fetchPostList();
      None
    },[|result|])
    ;
		<>
			<header>
				<Component__header on_help memo_transition />
			</header>
			<nav className=sidebarState>
				<header>
					<HintPanel />
				</header>
        <nav>
				<Filter setResult />
        </nav>
			</nav>
			<main className=sidebarState><ol>
			{ items
				|> Array.map( x => {
          open Model.PostListItem;
					let rank = 9;
                <Card
									key       ={x.post_id->string_of_int}
                  rank
                  id        ={x.post_id}
                  title     ={x.title}
                  creator   ={x.owner_name}
                  verified  ={x.verified}
                  timestamp ={x.created}
                />
				})
				|> React.array
			}
			</ol></main>
			<footer role="navigation" className=sidebarState>
				<button>{string("prev")}</button>
				<button>{string("next")}</button>
			</footer>
			<Component__sidebar sidebarState setSidebarState />
      <Component__help_menu on_click_out={_ => setShowHelp(_ => false)} />
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

module ReactDOM0 = {
	let querySelector = x =>
		switch (ReactDOM.querySelector(x)) {
		| Some(x) => x
		| None =>
			Js.Console.error("khong tim thay element #root");
			failwith("lol")
		}
}

module SecondaryNavigator = {
	let querySelector = () => {
		ReactDOM.querySelector("[role=\"secondaryBar\"]")->Option.get
	}
}

open Decorator

module App' =
(
	val (module Dashboard)
	->React.use(module Language.Make)
	->React.use(module Keyboard.Make2(SecondaryNavigator))
	->React.use(module Command__highlight.Make)
  ->React.use(module Tileset.Make)
  ->React.use(module AuthContext.Provider)
)

// let%comptime element = ReactDOM1.Page.make(Page.url)

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App' />)
}
