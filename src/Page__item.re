[@page "/item"]
open Melange__containers.Fun
module Melange__cmarkit = Remark_it
open Auth

module ItemNav{
	open Item.View

  [@react.component]
  let make = (~post_id, ~currentTab, ~setCurrentTab, ~prCount, ~owner_id) => {
    let auth = AuthContext.use();
		let id = post_id;
		let className = x =>
			x->Item.View.to_string++" " ++ (currentTab == x ? "selected" : "");
    let (disCount,setDisCount) = React.useState(() => 0);
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
    React.useEffect0(()=>{
      fetchCommentCount(~id=id)
      None
    });
		let choose = React.useCallback2(kind => {
			if (kind != currentTab) setCurrentTab(_ => kind)
		}, (setCurrentTab, currentTab));
    <>
    <button onClick={_ => choose(Article)} className=className(Article)> <label /> </button>
    <button onClick={_ => choose(Discussion)} className=className(Discussion)>
      <label>{React.string("discussions")}</label>
      <data className="count">{React.int(disCount)}</data>
    </button>
    <button onClick={_ => choose(Pullrequest)} className=className(Pullrequest)>
      <label>{React.string("pull-requests")}</label>
      <data className="count">{React.int(prCount)}</data>
    </button>
    <button onClick={_ => choose(Log)} className=className(Log)>
      <label>{React.string("history")}</label>
    </button>
    { (auth.getUserId() |> fun | None => true | Some(u) => owner_id != u)?
      React.null
      :
      <button onClick={_ => choose(Edit)} className=className(Edit)> <label /> </button>
      }
    </>
  }
}

module ArticleHeader = {
	[@react.component]
	let make = (~tags, ~info) => {
    open Model.FetchedPost;
		<>
			<div className="counter">
				<button className="up" />
				<span>{React.int(330)}</span>
				<button className="down" />
			</div>
			<h1>{React.string(info.title)}</h1>
			<ul className="tags">
      { open Model.TagButTheColorIsAString;
        tags 
        |> List.map(x => 
        <li key={string_of_int(x.tag_id)}>
          <span className="tag" 
          style={ReactDOM.Style.make(
            ~color           = x.tag_color
          , ~borderColor     = x.tag_color
          , ~backgroundColor = "color-mix(in srgb, "++x.tag_color++", transparent 75%)"
          , ())}>
            {React.string(x.tag_name)}
          </span>
        </li>) |> Array.of_list |> React.array}
      </ul>
			<div className="author">
				<span>{React.string(info.owner_name)}</span>
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

module React{
	include React
	open Melange__iter
	open Melange__containers.Fun

	let iter = array % Iter.to_array
}

module ArticleBody{
	open Melange__iter
	open React

	let heading = ((level, title, id) as _it) =>
		<li key=id>
			<a href=("#"++id)>
				<span>{level->string}</span>
				<span>{title->string}</span> </a>
		</li>
	;

	[@react.component]
	let make = (~headings, ~article_body) => {
		let toc = (headings, k) => if (headings->Iter.length == 0) { null } else k(headings);
		<>
		{ toc(headings) @@ headings =>
			<nav className="toc">
				<ol> {headings |> Iter.map(heading) |> React.iter} </ol> </nav>
		}
		<main className="markdown">
			<div dangerouslySetInnerHTML={make_html_obj @@ article_body} /> </main>
		</>
	}
}

module DiscussionView = {
  module DiscussionHint = {
    [@react.component]
    let make = (~addRep, ~setAddRep) => {
      let auth = AuthContext.use();
      <>
        <div className="logo" />
        <h1>{React.string("discussions")}</h1>
        <div className="sub">
          <span className="command">{React.string("discuss $id")}</span>
          <span className="summary">
            <data className="n-comments">{React.int(13)}</data>
            <data className="karma">{React.int(364)}</data>
          </span>
        </div>
        <button className="action"
            onClick={ _ => 
              if(auth.checkAuth()){setAddRep(a => !a)}else{auth.forceAuth()}
            }>
              {React.string(addRep?"Cancel":"New Comment")}
          </button>
      </>
    }
  };
  module DiscussionFilter = {
    [@react.component]
    let make = (~parentId,~refresh,~setResult,~setOpts) => {
      let auth = AuthContext.use()
      ;
      <Pagination.App 
        limit=3
        searchPrompt=true
        countApi={"/api/comment/count?parent="++string_of_int(parentId)++"&type=post&recursive=false&"}
        fetchApi={"/api/comment/get?parent="++string_of_int(parentId)
                ++"&user="  ++ string_of_int(Option.value(auth.getUserId(),~default=-1))
                ++"&type=post&"}
        filter  ={[
          ("searchby",["comment","username"])
        , ("sortby",  ["age","popularity"])
        , ("orderby", ["ascending","descending"])
        , ("filterby",["none","prof","student"])
        ]}
        refresh
        setResult
        setOpts
      />
    }
  };
  module DiscussionBody = {
    module AddComment = {
      [@react.component]
      let make = (~id, ~parentType, ~setShow, ~signalRefresh) => {
        let auth = AuthContext.use()
        let (isBusy, setIsBusy) = React.useState(()=> false)
        let (content, setContent) = React.useState(()=> "")
        let sendComment = () => {
          if (!auth.checkAuth()) {auth.forceAuth()}
          setIsBusy(_ => true);
          let open Js.Json;
          let body = Json__syntax.( empty()
          |> "user_id"        ^^ int    @@ Option.value(auth.getUserId(),~default=67)  
          |> "id"             ^^ int    @@ id
          |> "type"           ^^ int    @@ (parentType == "post"? 0 : 1)
          |> "content"        ^^ string @@ content
          |> "post_version"   ^^ int    @@ 0
          |> finish );
          open Fetch__syntax;
          Fetch.fetchWithInit(
            Env.backend ++"/api/postcomment",
            Fetch.RequestInit.make(
              ~method_=Post,
              ~body=Fetch.BodyInit.make(Js.Json.stringify(
                body
              )),
              ~headers=Fetch.HeadersInit.make({
                "Content-Type": "application/json"
              }),
              ()
            )
          )
          >>= Fetch.Response.json
          >>= (j => {
            setIsBusy(_ => false);
            setShow(_ => false);
            signalRefresh((!));
            Js.Promise.resolve(j)
          })
          >!= (err => {
            Js.log(err);
            setIsBusy(_ => false);
            Js.Promise.resolve(Js.Json.null)
          })
          |> ignore
        };
        React.useEffect0(()=>{
          None
        });
        <div className="comments add-reply">
          <div className="content">
            <header>
              <div className="author_name">{Option.value(auth.getUserName(),~default="Oops") |> React.string}</div>
            </header>
            <form onSubmit={ e => {
              React.Event.Form.preventDefault(e);
              sendComment()
            }}>
              <textarea autoFocus=true id="comment-body" className="text" 
              onChange={ e => setContent( _=> React.Event.Form.target(e)##value)}
              onKeyDown= { e => {
                if(React.Event.Keyboard.ctrlKey(e) && React.Event.Keyboard.key(e) === "Enter") sendComment()
              }}
              disabled=isBusy
              value=content/>
              <div className="text ghost">{React.string(content++"\n")}</div>
              <button type_="submit" className="submit" 
              disabled=isBusy>
                {React.string(isBusy?"Sending":"Send")}
              </button>
            </form>
          </div>
        </div>
      }
    }

    module LoadingComments = {
      [@react.component]
      let make = (~id,~show) => {
        !show ? 
        React.null
        :
        <li key={"loadingcomment"++string_of_int(id)} className="comments loading" hidden={!show}>
          <div className="content">
            <header>
              <div className="author_name">{React.string("loading")}</div>
              <div className={"author_role"}>{React.string("loading")}</div>
              <div className="author_rep" >{React.string("loading")}</div>
              <div className="timestamp"  >{React.string("loading")}</div>
              <div className="post_vers"  >{React.string("loading")}</div>
            </header>
            <div className="text"       >{React.string("loading loading loading loading")}</div>
            <div className="rating"     >
              <button className="up" disabled=true>
                {React.string(">")}
              </button>
              <span>{React.string("loading")}</span>
              <button className="down" disabled=true>
                {React.string("<")}
              </button>
            </div>
            <button className="show-replies" disabled=true>
              {React.string("Show replies")}
            </button>
          </div>
        </li>
      }
    }

    let cRef : ref(option((
        ~id : int,
        ~pType : string,
        ~showRep : bool,
        ~nestDepth : int,
        ~signalRefresh : (bool => bool) => unit,
        ~opts:list((string,string))
        ) => React.element)) = ref(None);

    module Comments = {
      [@react.component]
      let make = (
        ~id           : int,
        ~text         : string,
        ~rating       : int,
        ~user_rating  : int,
        ~timestamp    : string,
        ~post_vers    : int,
        ~author_name  : string,
        ~author_id    : int,
        ~author_role  : int,
        // ~author_rep   : int,
        ~nestDepth: int,
        ~signalRefresh,
        ~opts
      ) => {
        let auth = AuthContext.use()
        let autoExpand = 1;
        // kinda have to keep track of if the user has upvoted or downvoted this comment yikes
        // you know what that means~ more column in the fetching
        let (userRating,setUserRating) = React.useState(() => user_rating); // "-1" = down, "0" = neutral, "1" = up
        let (showRep, setShowRep) = React.useState(() => false);
        let (addRep, setAddRep) = React.useState(() => false);
        let pType="comment";
        let setVote = React.useCallback1([@warning "-8"] ((-1|0|1) as action) => {
          open Fetch__syntax;
          open Js.Json;
          open Json__syntax;
          let body = empty()
          |> "user_id"  ^^ int    @@ Option.value(auth.getUserId(),~default = 67)
          |> "id"       ^^ int    @@ id
          |> "type"     ^^ string @@ "comment"
          |> "action"   ^^ int    @@
            ( userRating == action
            ? { setUserRating(_ => 0); 0 }
            : { setUserRating(_ => action); action })
          |> finish;
          Fetch.fetchWithInit(
            Env.backend ++"/api/setvote",
            Fetch.RequestInit.make(
              ~method_=Post,
              ~body=Fetch.BodyInit.make(Js.Json.stringify(
                body
              )),
              ~headers=Fetch.HeadersInit.make({
                "Content-Type": "application/json"
              }),
              ()
            )
          )
          >>= Fetch.Response.json
          >!= (err => {
              Js.log(err);
              Js.Promise.resolve(Js.Json.null)
            })
          |> ignore;
        }, [|userRating|]);
        React.useEffect0(()=>{
          if (nestDepth < autoExpand){
            setShowRep(_=>true);
          }
          None
        });
        <li key={"comment"++string_of_int(id)} className="comments">
          <div className="content">
            <header>
              <div className="author_name">{React.string(author_name)}</div>
              <div className="author_id" hidden=true >{React.int(author_id  )}</div>
              <div className={"author_role "++ (author_role==0?"student":"prof")}>{React.string(author_role==0?"student":"prof")}</div>
              // <div className="author_rep" >{React.string("rep: " ++ string_of_int(author_rep) )}</div>
              <div className="timestamp"  >{React.string(Util.utcToRelative(timestamp))}</div>
              <div className="post_vers"  >{React.string("v: " ++ string_of_int(post_vers))}</div>
            </header>
            <div className="text"       >{React.string(text       )}</div>
            <div className="rating"     >
              <button className="up"
              onClick={_ => if(!auth.checkAuth()) {auth.forceAuth()}else{setVote(1)}}>
                {React.string(">")}
              </button>
              <span className={"v"++string_of_int(userRating)}>{{React.int(rating - user_rating + userRating)}}</span>
              <button className="down"
              onClick={_ => if(!auth.checkAuth()) {auth.forceAuth()}else{setVote(-1)}}>
                {React.string("<")}
              </button>
            </div>
            <button className="show-replies"
            onClick={ _ => setShowRep(a => !a) }>
              {React.string((showRep?"Hide":"Show") ++ " replies")}
            </button>
            <button className="add-reply"
            onClick={ _ => {
              if(auth.checkAuth()){setAddRep(a => !a)}else{auth.forceAuth()}
            }}>
              {React.string(addRep?"Cancel":"Add Reply")}
            </button>
          </div>
          <span className="spacer" hidden={!showRep && !addRep}/>
          
          {!addRep ? React.null : <AddComment id parentType=pType setShow=setAddRep signalRefresh/>}
          {switch (cRef.contents) {
          | None => failwith("this should not happen")
          | Some(comp) => comp(~id, ~pType, ~showRep, ~signalRefresh, ~nestDepth=nestDepth+1, ~opts)
          }}
        </li>
      }
    };

		let i = ref(0);

		[@alert deprecated("bao, please use WeakMap")]
		let getObjectId = o => {
			ignore(o);
			let v = i^;
			i := v + 1;
			v
		}

    module CommentGroup = {
      [@react.component]
      let make = (
        ~id : int
      , ~pType : string
      , ~showRep : bool
      , ~nestDepth : int
      , ~signalRefresh
      , ~result: option(Js.Json.t)=?
      , ~opts
      ) => {
        let auth = AuthContext.use()
        let (comments,setComments) = React.useState(() => [||]);
        let (showMore, setShowMore) = React.useState(() => true);
        let (loading, setLoading) = React.useState(() => false);
        let limit = 3;
        // opening concept: Js.Promise.()
        let fetchComments = result => {
          let open Fetch__syntax;
          if(loading){ () }
          else{
            setLoading(_=>true);
            switch(pType,result){
            | ("post",x) when x == Js.Json.null => ();
            | (t,r) =>
              switch(t,r){
              | ("post",r) when r != Js.Json.null => 
                setComments( _ => r |> Model.Decode.fetchedComments);
                setShowMore( _ => false);
                setLoading( _ => false);
              | _ =>
                let request = Env.backend ++ "/api/comment/get"
                  ++ "?limit="  ++ string_of_int(limit)
                  ++ "&offset=" ++ string_of_int(Array.length(comments))
                  ++ "&user="   ++ string_of_int(Option.value(auth.getUserId(),~default=-1))
                  ++ "&parent=" ++ string_of_int(id)
                  ++ "&type=comment&"
                  ++ (switch(opts |> Util.stringQueryParams'){
                    | "" => ""
                    | v  => "&" ++ v 
                  })
                Fetch.fetch(request)
                >>= Fetch.Response.json 
                >>= Model.Decode.Response.fetchedComments
                >>= (aod => {
                  setComments( x => Array.append(x,aod));
                  setShowMore( _ => Array.length(aod) < limit ? false : true);
                  setLoading(_=>false);
                  Js.Promise.resolve(aod)
                })
                >!= (err => {
                    Js.log(err);
                    setShowMore( _ => false );
                    setLoading( _ => false );
                    return([||])
                  })
                |> ignore;
              } 
            }
          }
          
        };
        let revealReplies = result => {
          if (Array.length(comments) == 0 && showMore){
            fetchComments(result);
          };
        };
        React.useEffect2(()=>{
          if(showRep) revealReplies(result |> Option.value(~default=Js.Json.null));
          None
        },(showRep, result))
        React.useEffect1(()=>{
          fetchComments(result |> Option.value(~default=Js.Json.null));
          None
        },[|result|])
        // React.useEffect1(()=>{
				// 	Js.Console.log("result changed");
				// 	None
        // },[|result|])
        // React.useEffect1(()=>{
				// 	Js.Console.log("comments changed");
				// 	None
        // },[|comments|])
        ;
        <>
        <ol className="replies" hidden={!showRep}>
          {
            comments
            |> Array.map(x => {
              open Model.FetchedComment;
              <Comments
                key         = {string_of_int(x.id)++string_of_int(comments->getObjectId)}
                id          = {x.id          }
                text        = {x.text        }
                rating      = {x.rating      }
                user_rating = {x.user_rating }
                timestamp   = {x.timestamp   }
                post_vers   = {x.post_vers   }
                author_name = {x.author_name }
                author_id   = {x.author_id   }
                author_role = {x.author_role }
                // author_rep  = {x.author_rep  }
                nestDepth
                signalRefresh
                opts
              /> 
              })
            |> React.array
          }
          <LoadingComments id show={showRep && loading} />
        </ol>
        <button className="more-replies"
        onClick={ _ => fetchComments(result |> Option.value(~default=Js.Json.null)) }
        hidden={!showRep || !showMore || loading}>
          {React.string("More replies")}
        </button>
        </>
      }
    };

    let () = cRef := Some((
      ~id, 
      ~pType, 
      ~showRep,
      ~nestDepth,
      ~signalRefresh,
      ~opts
    ) => 
      <CommentGroup id pType showRep nestDepth signalRefresh opts/>);

    [@react.component]
    let make = (~id, ~addRep, ~setAddRep, ~result, ~signalRefresh, ~opts) => {
      <>
      {!addRep ? 
      React.null
      :
      <AddComment id parentType="post" setShow=setAddRep signalRefresh/>}
      <CommentGroup id pType="post" showRep=true nestDepth=0 result signalRefresh opts/>
      </>
    }
  };

  [@react.component]
  let make = (~post_id : int) => {
    let (addRep, setAddRep) = React.useState(() => false)
    and (result, setResult) = React.useState(() => Js.Json.null)
    and (refresh, signalRefresh) = React.useState(() => false)
    and (opts, setOpts) = React.useState(() => []);
    <>
      <header className={"only " ++ Item.View.to_string(Discussion)}>
        <DiscussionHint addRep setAddRep />
        <nav>
          <DiscussionFilter parentId=post_id refresh setResult setOpts />
        </nav>
      </header>
      <main className={"only " ++ Item.View.to_string(Discussion)}>
        <DiscussionBody id=post_id addRep setAddRep result signalRefresh opts />
      </main>
    </>
  }
}

module PullrequestsHint = {
	[@react.component]
	let make = (~num_open, ~num_merged, ~num_closed) => {
		<>
			<div className="logo" />
			<h1>{React.string("pull requests")}</h1>
			<div className="sub">
				<span className="command">{React.string("pr list $id")}</span>
				<span className="summary">
					<data className="pr-open">{React.int(num_open)}</data>
					<data className="pr-merged">{React.int(num_merged)}</data>
					<data className="pr-closed">{React.int(num_closed)}</data>
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
	let duration = (x, y) => {
		let (end_, begin_) = (Js__dom.Date.get_time(x) / 1000, Js__dom.Date.get_time(y) / 1000);
		let span = end_ - begin_;
		if (span < 60) {
			Some(`Seconds(span))
		} else {
			let span2 = span / 60;
			if (span2 < 60) {
				Some(`Minutes(span2))
			} else {
				let span3 = span / (60 * 60);
				if (span3 < 24) {
					Some(`Hours(span3))
				} else {
					let span4 = span / (60 * 60 * 24);
					if (span4 < 4) {
						Some(`Days(span4))
					} else None
				}
			}
		}
	};

	let date_to_string = d => (d->Js__dom.Date.Utc.date->string_of_int, (d->Js__dom.Date.Utc.month+1)->string_of_int, d->Js__dom.Date.Utc.full_year->string_of_int);

	[@react.component]
	let make = (~pullrequests, ~prsExpand, ~expand_this, ~inspect_this) => {
		let now = Js__dom.Date.of_now();
		<ul>
			{pullrequests |> Array.map(x => {
				let ((id, _post_id, _contributor_id, title, _desc, status, tags, created), contributor_name) = x;
				let created = Js__dom.Date.of_iso_string(created);
				let duration = duration(now, created) |> Option.map @@ fun
					| `Seconds(i) => <span className="time ago second">{React.int(i)}</span>
					| `Minutes(i) => <span className="time ago minute">{React.int(i)}</span>
					| `Hours(i) => <span className="time ago hour">{React.int(i)}</span>
					| `Days(i) => <span className="time ago day">{React.int(i)}</span>
					;
				let status_class = fun | `Open => "open" | `Closed => "closed" | `Merged => "merged";
				let is_expanded = List.assoc_opt(id, prsExpand) |> Option.value(~default=false);
				<li key=string_of_int(id) onClick={_ => expand_this(id)} className=("pull-request-row " ++ (is_expanded ? "expanded" : " "))>
					<div className="head">
						<button onClick={_ => expand_this(id)}>{React.string(">")}</button>
					</div>
					<span className="id">{React.int(id)}</span>
					<span className={"status " ++ status_class(status)}></span>
					<div className="aee">
						<a className="title" onClick={inspect_this(id)}>{React.string(title)}</a>
						<span className="contributor user">{React.string(contributor_name)}</span>
						{ switch (duration) {
							| Some(duration) => duration
							| None => {
								let (date, month, year) = created->date_to_string;
								<span className="time">
									<span className="date">{React.string(date)}</span>
									<span className="month">{React.string(month)}</span>
									<span className="year">{React.string(year)}</span>
								</span>
							}
						} }
					</div>
					<div className="expanded-content">
						<hgroup>
							<span className="id">{React.int(id)}</span>
							<a className="title" onClick={inspect_this(id)}>{React.string(title)}</a>
							<span className=("status "++status_class(status))></span>
						</hgroup>
						<div className="sub">
							<span className="contributor user">{React.string(contributor_name)}</span>
							{ switch (duration) {
								| Some(duration) => duration
								| None => {
									let (date, month, year) = created->date_to_string;
									<span className="time">
										<span className="date">{React.string(date)}</span>
										<span className="month">{React.string(month)}</span>
										<span className="year">{React.string(year)}</span>
									</span>
								}
							} }
						</div>
						<ul className="tags">{ tags |> List.map(x =>
							<li key=x><span className="tag">{React.string(x)}</span></li>
						) |> Array.of_list |> React.array}</ul>
					</div>
				</li>
			}) |> React.array}
		</ul>
	}
}

module PullrequestsInspectHint{
	open React

	[@react.component]
	let make = (~pullrequests, ~pr_inspect, ~inspect_back_this) => {
		let pullrequest =
			(pullrequests, pr_inspect) |> useMemo2 @@ () =>
			pullrequests |> Array.find_map @@ (((id, _, _, _, _, _, _, _), _) as x) =>
			Option.bind(pr_inspect) @@ pr_inspect =>
			id == pr_inspect ? Some(x) : None;
		let show = (it, f) => switch (it) { | None => <> </> | Some(it) => f(it) };
		let status_class = fun | `Open => "open" | `Closed => "closed" | `Merged => "merged";
		show(pullrequest) @@ (((id, _post_id, _contributor_id, title, _desc, status, _, _), contributor_name)) =>
		<>
		<button className="back" onClick={_ => inspect_back_this()}></button>
		<div>
			<span className="id">{int(id)}</span><span>{title->string}</span>
		</div>
		<div>
			<span className={"status "++(status->status_class)}></span>
			<span className="contributor user wants-to">{contributor_name->string}</span>
		</div>
		</>
	}
}

module PullrequestsInspectBody{
	open React

	[@react.component]
	let make = (~pullrequests, ~pr_inspect, ~info) => {
    open Model.FetchedPost;
		let pullrequest =
			(pullrequests, pr_inspect) |> useMemo2 @@ () =>
			pullrequests |> Array.find_map @@ (((id, _, _, _, _, _, _, _), _) as x) =>
			Option.bind(pr_inspect) @@ pr_inspect =>
			id == pr_inspect ? Some(x) : None;
		let show = (it, f) => switch (it) { | None => <> </> | Some(it) => f(it) };
		show(pullrequest) @@ (((_, _, _, _, desc, _, _, _), _)) =>
		<>
			<section className="cat">
				<header className="command">{"pr cat pullrequest.md"->string}</header>
				<div className="content">{desc->string}</div>
			</section>
			<section className="reviews">
				<header className="command">{"pr status"->string}</header>
				<ul className="content">
					<li><span className="contributor user">{info.owner_name->string}</span><span className="unknown"></span></li>
				</ul>
			</section>
		</>
	}

}

module At_repo_0'(S : {
	include Bkhack__experimental.S;
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
	include Bkhack__experimental.S;
	let tgt_post_id : int }) =
{
	include At_repo_0'(S)
	module Json = Js__json

	type t = array((int, int, int, string, string, S.pr_status, list(string), string));

	let  row = [@warning "-8"] fun | [id, post_id, contributor, title, description, status, tags, created, ..._] => {
		let status = switch(Json.decodeStringExn(status)) {
			| "open" => `Open
			| "closed" => `Closed
			| "merged" => `Merged
		};
		let tags = String.split_on_char(',', Json.decodeStringExn(tags));
		( Float.to_int(Json.decodeNumberExn(id)), Float.to_int(Json.decodeNumberExn(post_id)), Float.to_int(Json.decodeNumberExn(contributor)), Json.decodeStringExn(title), Json.decodeStringExn(description), status, tags, Json.decodeStringExn(created) );
	}

	let json = {
		let per_row = row % Array.to_list % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

module At_repo_1'(S : {
	include Bkhack__experimental.S;
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
	include Bkhack__experimental.S;
	let tgt_user_id : int }) =
{
	include At_repo_1'(S)
	module Json = Js__json

	type t = array((int, string))

	let row  = [@warning "-8"] fun | [user_id, name, ..._] =>
		( Float.to_int(Json.decodeNumberExn(user_id)), Json.decodeStringExn(name) );

	let json = {
		let per_row = row % Array.to_list % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

module At_repo_2'(S : {
	include Bkhack__experimental.S;
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
	include Bkhack__experimental.S;
	let tgt_post_id : int }) =
{
	include At_repo_2'(S)
	module Json = Js__json

	type t = array((int, string, int, string));

	let  row = [@warning "-8"] fun | [id, title, creator, text,..._] =>
		( Float.to_int(Json.decodeNumberExn(id)), Json.decodeStringExn(title), Float.to_int(Json.decodeNumberExn(creator)), Json.decodeStringExn(text) );

	let json = {
		let per_row = row % Array.to_list % Json.decodeArrayExn;
		Array.map(per_row) % Json.decodeArrayExn
	}
}

exception Item_not_found

module App{
	open React

	let show = (x, f) => switch (x) { | Some(info) => f(info) | None => { <> </> } };

	[@react.component]
	let make = () => {
    let auth = AuthContext.use()
		let url = ReasonReactRouter.useUrl();
		let (prsExpand, setPrsExpand) = useState(() => []);
		let (tab, setTab) = useState(() => {
			Util.parseQueryParams(url.search)
			->Js.Dict.get("view")
			->Option.value(~default=Article->Item.View.to_string)
			->Item.View.of_string
		});
		let (pr_inspect, pr_inspect_set) = React.useState(() => {
			let pr_id = Util.parseQueryParams(url.search)->Js.Dict.get("pr_id");
			pr_id |> Option.map(int_of_string)
		});
		let (pullrequests, setPrs)  = React.useState(() => [||]);
		let (postInfo, setPostInfo) = React.useState(() : option(Model.FetchedPost.t) => None);
		let (postTag, setPostTag)   = React.useState(() : list(Model.TagButTheColorIsAString.t) => []);
		// let tags = [| "Algorithm", "Rust" |];
		let renderer = React.useMemo0(() => Melange__cmarkit.Cmarkit_html.renderer(~safe=false, ()));
		let art = React.useMemo2(() => {
			open Melange__cmarkit; open Cmarkit;
			postInfo |> Option.map @@ (postInfo) =>
			try ({
        open Model.FetchedPost;
				let skel = postInfo.body |> Doc.of_string(~strict=false);
				let block = Doc.block(skel) 
				let rec s = { fun
					| Block.Block_Heading((t, _)) => {
						[@warning "-8"] let (level, Inline.Text((textcontent, _))) = Block.Heading.((level(t), inline(t)));
						[(Int.to_string(level), textcontent, textcontent)] }
					| Block.Blocks((xs, _)) => xs |> List.map(s) |> List.flatten
					| _ => []
				};
				let headings = s(block) |> Melange__iter.Iter.of_list;
				(postInfo, headings, Melange__cmarkit.Cmarkit_renderer.doc_to_string(renderer, skel))
			}) {
				| Invalid_argument(msg) => { Js.Console.error("rendering error: '" ++ msg ++ "'"); failwith("something bad happened") }
				| Js.Exn.Error(x) => { Js.Console.error("js error: '" ++ Option.value(~default="", Js.Exn.message(x)) ++ "'"); failwith("sdf") }
			}
		}, (renderer, postInfo));
		let id = React.useMemo2(() => switch (tab) { | Item.View.Pullrequest as tab => {
			Item.View.to_string(tab) ++ " " ++ (pr_inspect |> Option.map(_ => "inspect") |> Option.value(~default=""))
		} | tab => Item.View.to_string(tab) }, (tab, pr_inspect));
		let (sidebarState, setSidebarState) = React.useState( _ => "state0");
		let module X = Bkhack__experimental;
		let join = ((_, _, contributor_id, _, _, _, _, _) as it) => Fetch__syntax.({
			let* user_info = X.Fetch.all(module At_repo_1(
				{ include X.GenSQL; let tgt_user_id = contributor_id }))(module Env);
			let (_, name) = user_info[0];
			return @@ (it, name)
		});
		React.useEffect0(React__effect.async @@ () => Fetch__syntax.({
			let id = Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"));
			let* prs = X.Fetch.all(module At_repo_0(
				{ include X.GenSQL; let tgt_post_id = int_of_string(id) }))(module Env);
			let* dict = Js.Promise.all @@ Array.map(join) @@ prs;
			return @@ ignore @@ setPrs(_ => dict);
		}));
		React__effect.useAsync0(() => Fetch__syntax.({
			let post_id = Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"));
      Fetch.fetch(Env.backend ++ "/api/tag/post"
        ++ "?postid=" ++ post_id)
      >>= Fetch.Response.json
      >>= Model.Decode.Response.tags
      >!= (err => {
          Js.log(err);
          Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
        })
      >>= (aod => {
        open Model.Tag;
        setPostTag(
            _ => aod
            |> Array.map((d) => 
              { Model.TagButTheColorIsAString.tag_id    : d.tag_id
              , Model.TagButTheColorIsAString.tag_name  : d.tag_name
              , Model.TagButTheColorIsAString.tag_nick  : d.tag_nick
              , Model.TagButTheColorIsAString.tag_color : d.tag_color |> Util.rgbaIntToHexString
              } 
            )
            |> Array.to_list
        );
        return(aod)
      })
      |> ignore
      Fetch.fetch(Env.backend ++ "/api/post/get/"
        ++ "?post_id=" ++ post_id
        ++ "&user_id=" ++ string_of_int(Option.value(auth.getUserId(), ~default= -1))
        ++ "&v=latest")
      >>= Fetch.Response.json
      >>= Model.Decode.Response.fetchedPost
      >!= (err => {
          Js.log(err);
          Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
        })
      >>= (aod => {
        setPostInfo(_ => Some(aod));
        return(())
      })
      // X.Fetch.all(module At_repo_2(
			// 	{ include X.GenSQL; let tgt_post_id = post_id }))(module Env);
			// if (posts->Array.length == 0) { raise(Item_not_found) } else {
			// 	let (_, post_title, creator_id, post_text) = posts[0];
			// 	let* users = X.Fetch.all(module At_repo_1(
			// 		{ include X.GenSQL; let tgt_user_id = creator_id }))(module Env);
			// 	let (_, creator_name) = users[0];
			// 	return @@ ignore @@ setPostInfo(_ => Some((post_id, post_title, creator_name, post_text)))
			// }
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
		let on_prs_update_inspect = React.useMemo1(() => (id, e) => {
			React.Event.Synthetic.stopPropagation(e);
			ReasonReactRouter.push(String.concat("/", ["", ...url.path]) ++ {
				let dict = Util.parseQueryParams'(url.search);
				"/?" ++ ( dict |> Util.List.replace_assoc'("pr_id", string_of_int(id)) |> Util.stringQueryParams' )
			});
			pr_inspect_set(_ => Some(id))
		}, [|pr_inspect_set|])
		let on_prs_update_inspect_back = React.useMemo1(((), ()) => {
			ReasonReactRouter.push(String.concat("/", ["", ...url.path]) ++ {
				let dict = Util.parseQueryParams'(url.search);
				"/?" ++ ( dict |> List.remove_assoc("pr_id") |> Util.stringQueryParams' )
			});
			pr_inspect_set(_ => None)
		}, [|pr_inspect_set|])
		let setCurrentTab = React.useCallback2(f => setTab(x => {
			let y = f(x);
			ReasonReactRouter.push(String.concat("/", ["", ...url.path]) ++ {
				let dict = Util.parseQueryParams'(url.search);
				"/?" ++ ( dict |> Util.List.replace_assoc'("view", y->Item.View.to_string) |> Util.stringQueryParams' )
			});
			y
		}), (setTab, url));
		let memo_transition = React.useCallback2((url, url_args, k) => {
      postInfo
      |> fun
      | None => ()
      | Some(pi) =>
      {
			  open Model.FetchedPost;
				if (url === "/item/" && (
					List.assoc("id", url_args) |> int_of_string |> (x => x == pi.post_id)
				)) {
					Some(() => {
						let view = List.assoc_opt("view", url_args) |> Option.map(Item.View.of_string) |> Option.value(~default=Item.View.Article);
						setCurrentTab(_ => view)
					})
				} else if (url === "") {
					Some(() => setCurrentTab(Fun.id))
				} else {
					None
				}
			} |> fun
				| None => k ()
				| Some(f) => f ()
		}, (setCurrentTab, postInfo));
		show(art) @@ ((postInfo, headings, article_body)) =>
		<>
			<title>{React.string(postInfo.title++" | bkhack")}</title>
			<header>
				<Component__header memo_transition />
			</header>	
			<nav className=sidebarState>
				<ItemNav owner_id=postInfo.owner_id post_id={Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id"))} currentTab=tab setCurrentTab prCount=Array.length(pullrequests)/>
			</nav>
			<main className={sidebarState ++ " " ++ id}>
				<>
					<header className=("only "++Article->Item.View.to_string)><ArticleHeader tags=postTag info=postInfo /></header>
					<div className=("innerbody only "++Article->Item.View.to_string)><ArticleBody headings article_body /></div>
				</>
        <DiscussionView post_id= {int_of_string(Option.get(Util.parseQueryParams(url.search) -> Js.Dict.get("id")))}/>
				<>
					<header className=("only "++Pullrequest->Item.View.to_string)>
						<PullrequestsHint
							num_open={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Open => acc + 1 | _ => acc }), 0)}
							num_merged={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Merged => acc + 1 | _ => acc }), 0)}
							num_closed={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Closed => acc + 1 | _ => acc }), 0)}
							/>
						<nav> <PullrequestsFilter /> </nav>
					</header>
					<main className=("only "++Pullrequest->Item.View.to_string)><PullrequestsBody pullrequests prsExpand expand_this=on_prs_update_expand inspect_this=on_prs_update_inspect /></main>
					<header className=("only "++Pullrequest->Item.View.to_string++" inspect")>
						<PullrequestsInspectHint pullrequests pr_inspect inspect_back_this=on_prs_update_inspect_back />
					</header>
					<main className=("only "++Pullrequest->Item.View.to_string++" inspect")>
						<PullrequestsInspectBody pullrequests pr_inspect info=postInfo />
					</main>
				</>
        			{
				(auth.getUserId()|> fun | None => true | Some(u) => postInfo.owner_id != u) ?
				React.null
				:
				<Item_view__editor.App className={Edit->Item.View.to_string} title=postInfo.title body=postInfo.body 
        tag={open Model.TagButTheColorIsAString;
          postTag |> List.map((a)=>a.tag_id)} />}
					<Item_view__log.App className={Log->Item.View.to_string} parentId=postInfo.post_id />
			</main>
			
			<Component__sidebar sidebarState setSidebarState />
			
		</>
	}
};

module Error_page(C : Decorator.Component) {
	open React
	open ReasonReactErrorBoundary

	let fallback = fun
	| Item_not_found =>
		<dialog open_=true>"not_found"->string</dialog>
	| e => {
    Js.Console.error2("damn", e);
		<div>("error")->string</div>
  }
	;

	[@react.component] let make = () =>
		<ReasonReactErrorBoundary fallback={({ error, _ }) => fallback(error)}> <C /> </ReasonReactErrorBoundary>
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

open Decorator

module App' =
(
	val (module App)
	->React.use(module Language.Make)
	->React.use(module Keyboard.Make)
	->React.use(module Command.Make)
  ->React.use(module Tileset.Make)
	->React.use(module Error_page)
  ->React.use(module AuthContext.Provider)
)

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App' />)
}
