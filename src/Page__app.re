[@page "/"]
open Stdlib
open Melange__containers.Fun
open Auth

module Wifi {
	[@react.component]
	let make = () =>
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 11a9 9 0 0 1 9 9"></path><path d="M4 4a16 16 0 0 1 16 16"></path><circle cx="5" cy="19" r="1"></circle></svg>
}

module HintPanel {
	open React

	let%comptime feed__hint = {
		module At__sh (Syntax : Shell__sym.SymL) {
			let command = Syntax.observe @@ Syntax.(
				feed @| Split_by.count(10) @| nil )
		}

		open At__sh(Shellgen)

		Css_gen.Stylesheet.format1(~className=__name__, {| 
			&.command::before { content: ? ;}
		|}, command)

	};

	[@react.component]
	let make = () => {
    let auth = Auth.AuthContext.use();
		<>
			<div className="logo">
				<Wifi />
			</div>
			<h1 className="home-feed"> </h1>
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
        }>{string("+ Add post")}</button>
		</>
	}
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
	let make = (~onUpdateCount) =>
	{ let submission = React.useRef(Js.Nullable.null);
		let onSubmit = e => {
			React.Event.Synthetic.preventDefault(e);
			let u = React.Event.Form.target(e)##showCount##value;
			onUpdateCount(u)
		};
		<form ref={ReactDOM.Ref.domRef(submission)} className="dashboard-filter" onSubmit>
			<input id="feedFilter" />
			{methods @@ ["hot", "new", "top-voted", "most-discussed", "recent-activity"]}
			{options @@ [10, 25, 50, 100, 0]}
		</form>
	}
}

module Dashboard = {
	open React

	module Card = {
		[@react.component]
		let make = (
      ~rank
    , ~id
    , ~title
    , ~creator
    , ~verified
    , ~public
    , ~timestamp
    ) => {
      let auth = AuthContext.use()
      let (disCount,setDisCount) = React.useState(() => 0);
      let fetchCommentCount = (~id) => {
        let open Fetch__syntax;
        Fetch.fetch(Env.backend ++ "/api/comment"
          ++ "?parent="  ++ id
          ++ "&type="    ++ "0")
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
      React.useEffect0(()=>{
        fetchCommentCount(~id=string_of_int(id))
        None
      });
      switch(public,auth.checkAuth(), creator == Option.value(auth.getUserId(),~default = 67)){
            | (0,true, true) | (1,_, _) => 
              <li key={string_of_int(id)}>
                <div className="counter">
                  <span>{React.int(rank)}</span>
                </div>
                <header>
                  <a href={"item/?id="++string_of_int(id)}>{string(title)}</a>
									<span className="post_id">{id->React.int}</span>
                </header>
                <footer>
                  <div className="has-left-indicator tagline">
                    <span className="tag" title="Algorithm, Optimization">{string("AgAa")}</span>
                  </div>
                  <div className="status">
                    <span>{string(verified==1?"verified":"unverified")}</span>
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
                    <span className="verb">{string("commented")}</span>
                    <span className="agent">{string("@kinten108101")}</span>
                    <span className="theme"></span>
                    <span className="time">{string("2h ago")}</span>
                  </div>
                  <div className="created-from">
                    <span>{string("created ")}</span><span>{string(Util.utcToRelative(timestamp))}</span>
                  </div>
                  <div className="ref">
                    <span>{string("2000")}</span>
                  </div>
                </footer>
              </li>
            | (_,_,_) => React.null
          }
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
		let (counts, setCounts) = React.useState(() => 10);
		let (items, setItems) = React.useState(() => [||]);
		let (sidebarState, setSidebarState) = React.useState( _ => "state0");
		let ticketParam = ReasonReactRouter.useUrl().search;
		React.useEffect1(() => {
			let limit = ticketParam->Util.parseQueryParams->Js.Dict.get("limit");
			let limit = limit |> Option.map(int_of_string);
			ignore( limit |> Option.iter @@ limit => setCounts(_ => limit) );
			None
		}, [|counts|]);
		let module X = Bkhack__experimental;
		React__effect.useAsync1(() => 
    Fetch__syntax.({
			test(counts);
			let module U (S : X.S) = At_repo_0({ let paginate = limit => limit(counts, 0) })(S);
			let* posts = X.Fetch.all((
        module At_repo_0({ let paginate = limit => limit(counts, 0) }, X.GenSQL)
      ),(module Env));
      setItems(_ => posts);
      return(());
		})
    , [|counts|]);
		let onUpdateCount = React.useCallback0(newVal => setCounts(_ => newVal));
		<>
			<header>
				<Component__header />
			</header>
			<nav className=sidebarState>
				<header>
					<HintPanel />
				</header>
				<Filter onUpdateCount />
			</nav>
			<main className=sidebarState><ol>
			{ items
				|> Array.map(((id, title, creator, _text, verified, public, timestamp)) => {
					let rank = 9;
                <Card
									key={id->string_of_int}
                  rank
                  id
                  title
                  creator
                  verified
                  public
                  timestamp
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
		ReactDOM.querySelector("#feedFilter")->Option.get
	}
}

open Decorator

module App' =
(
	val (module Dashboard)
	->React.use(module Language.Make)
	->React.use(module Keyboard.Make2(SecondaryNavigator))
	->React.use(module Command.Make)
  ->React.use(module AuthContext.Provider)
)

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App' />)
}
