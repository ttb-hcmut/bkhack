[@page "/item"]
open Melange__containers.Fun

module Tags = {
	type t = list([`unfetched(string)])

	let of_string : string => t =
		String.split_on_char(',')
		%> List.map(x => `unfetched(x))
}

module View = {
	type t =
		| Article
		| Discussion
		| Pullrequest
		| Log
		| Edit

	let uu = [
		( Article, "article" ),
		( Discussion, "discussions" ),
		( Pullrequest, "pullrequests" ),
		( Log, "log" ),
		( Edit, "edit")
	]

	let uu' = uu |> List.map(((k, v)) => (v, k))

	let to_string = k => List.assoc(k, uu)

	let of_string = k => List.assoc(k, uu')
}

module ItemNav = {
	open View

  [@react.component]
  let make = (~currentTab,~setCurrentTab,~prCount) => {
    <>
    <button onClick={_ => setCurrentTab(_ => Article)} className={"article " ++ (currentTab == Article ? "selected" : "")}>
      <label>{React.string("article")}</label>
    </button>
    <button onClick={_ => setCurrentTab(_ => Discussion)} className={"discussions " ++ (currentTab == Discussion ? "selected" : "")}>
      <label>{React.string("discussions")}</label>
      <data className="count">{React.int(24)}</data>
    </button>
    <button onClick={_ => setCurrentTab(_ => Pullrequest)} className={"pullrequests " ++ (currentTab == Pullrequest ? "selected" : "")}>
      <label>{React.string("pull-requests")}</label>
      <data className="count">{React.int(prCount)}</data>
    </button>
    <button onClick={_ => setCurrentTab(_ => Log)} className={"log " ++ (currentTab == Log ? "selected" : "")}>
      <label>{React.string("history")}</label>
    </button>
    <button onClick={_ => setCurrentTab(_ => Edit)} className={"edit " ++ (currentTab == Edit ? "selected" : "")}>
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
					<data className="comments">{React.int(13)}</data>
					<data className="karma">{React.int(364)}</data>
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
    let open Fetch__syntax;
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
  module AddComment = {
    [@react.component]
    let make = (~id, ~parentType, ~setShow) => {
      let (isBusy, setIsBusy) = React.useState(()=> false)
      let (content, setContent) = React.useState(()=> "")
      let sendComment = () => {
        setIsBusy(_ => true);
        open Fetch__syntax
        let payload = Js.Dict.empty();
        // TODO: [khang] identity provider sth sth somehow
        Js.Dict.set(payload, "user_id", Js.Json.string("SomeBody"));
        Js.Dict.set(payload, "id", Js.Json.string(id));
        Js.Dict.set(payload, "type", Js.Json.string(parentType));
        Js.Dict.set(payload, "content", Js.Json.string(content));
        let json = Js.Json.object_(payload);
        Fetch.fetchWithInit(
          Env.backend ++"/api/postcomment",
          Fetch.RequestInit.make(
            ~method_=Post,
            ~body=Fetch.BodyInit.make(Js.Json.stringify(
              json
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
          Js.Promise.resolve(j)
        })
        >!= (err => {
          Js.log(err);
          setIsBusy(_ => false);
          Js.Promise.resolve(Js.Json.null)
        })
        |> ignore
      };
      <div className="comments add-reply">
        <div className="content">
          <header>
            // TODO: [khang] identity provider sth sth somehow
            <div className="author_name">{React.string("@AuthorName")}</div>
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
      <li key={"loadingcomment"++id} className="comments loading" hidden={!show}>
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
      ~id : string,
      ~pType : string,
      ~showRep : bool,
      ~nestDepth : int
      ) => React.element)) = ref(None);
  module Comments = {
    [@react.component]
    let make = (
      ~id           : string,
      ~text         : string,
      ~rating       : string,
      ~user_rating  : string,
      ~timestamp    : string,
      ~post_vers    : string,
      ~author_name  : string,
      ~author_id    : string,
      ~author_role  : string,
      ~author_rep   : string,
      ~nestDepth: int
    ) => {
      let autoExpand = 1;
      // kinda have to keep track of if the user has upvoted or downvoted this comment yikes
      // you know what that means~ more column in the fetching
      let (userRating,setUserRating) = React.useState(() => user_rating); // "-1" = down, "0" = neutral, "1" = up
      let (showRep, setShowRep) = React.useState(() => false);
      let (addRep, setAddRep) = React.useState(() => false);
      let pType="comment";
      let timeAgo = (seconds: int): string => {
        let now =
            Js.Date.make()
            |> Js.Date.getTime
            |> int_of_float;

        let diffMs = (now - seconds*1000)/1000;
        let minutes = diffMs / 60;
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
      let setVote = (action) => {
        open Fetch__syntax;
        let payload = Js.Dict.empty();
        Js.Dict.set(payload, "id", Js.Json.string(id));
        // TODO: [khang] identity provider sth sth somehow
        Js.Dict.set(payload, "user_id", Js.Json.string("SomeBody"));
        Js.Dict.set(payload, "type", Js.Json.string("comment"));
        // mofo will grab userRating before setUserRating fires bruh
        switch (action) {
          | "-1"|"1"|"0" =>
            if (userRating == action){
              setUserRating(_ =>"0")
              Js.Dict.set(payload, "action", Js.Json.string("0"));
            }
            else{
              setUserRating(_ =>action);
              Js.Dict.set(payload, "action", Js.Json.string(action));
            }
            
            let json = Js.Json.object_(payload);
            Fetch.fetchWithInit(
              Env.backend ++"/api/setvote",
              Fetch.RequestInit.make(
                ~method_=Post,
                ~body=Fetch.BodyInit.make(Js.Json.stringify(
                  json
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
          | _ => ()
        };
      };
      React.useEffect0(()=>{
        if (nestDepth < autoExpand){
          setShowRep(_=>true);
        }
        None
      });
      <li key={"comment"++id} className="comments">
        <div className="content">
          <header>
            <div className="author_name">{React.string(author_name)}</div>
            <div className="author_id" hidden=true >{React.string(author_id  )}</div>
            <div className={"author_role "++author_role}>{React.string(author_role)}</div>
            <div className="author_rep" >{React.string("rep: " ++ author_rep )}</div>
            <div className="timestamp"  >{React.string(timeAgo(int_of_string(timestamp)))}</div>
            <div className="post_vers"  >{React.string("v: " ++ post_vers  )}</div>
          </header>
          <div className="text"       >{React.string(text       )}</div>
          <div className="rating"     >
            <button className="up"
            onClick={_ => setVote("1")}>
              {React.string(">")}
            </button>
            <span className={"v"++userRating}>{{React.int(int_of_string(rating) + int_of_string(userRating))}}</span>
            <button className="down"
            onClick={_ => setVote("-1")}>
              {React.string("<")}
            </button>
          </div>
          <button className="show-replies"
          onClick={ _ => setShowRep(a => !a) }>
            {React.string((showRep?"Hide":"Show") ++ " replies")}
          </button>
          <button className="add-reply"
          onClick={ _ => setAddRep(a => !a)}>
            {React.string(addRep?"Cancel":"Add Reply")}
          </button>
        </div>
        <span className="spacer" hidden={!showRep && !addRep}/>
        
        {!addRep ? 
        React.null
        :
        <AddComment id parentType=pType setShow=setAddRep/>}
        {switch (cRef.contents) {
        | None => React.null
        | Some(comp) => comp(~id, ~pType, ~showRep, ~nestDepth=nestDepth+1)
        }}
      </li>
    }
  };

  module CommentGroup = {
    [@react.component]
    let make = (
      ~id : string,
      ~pType : string,
      ~showRep : bool,
      ~nestDepth : int
    ) => {
      let (comments,setComments) = React.useState(() => [||]);
      let (showMore, setShowMore) = React.useState(() => true);
      let (loading, setLoading) = React.useState(() => false);
      let limit = 3;
      // opening concept: Js.Promise.()
      let fetchComments = () => {
        let open Fetch__syntax;
        setLoading(_=>true);
        Fetch.fetch(Env.backend ++ "/api/comment"
          ++ "?limit="  ++ string_of_int(limit)
          ++ "&offset=" ++ string_of_int(Array.length(comments))
          ++ "&parent=" ++ id
          ++ "&type="   ++ pType)
        >>= Fetch.Response.json
        |> decodeJson
        >>= (aod => {
          setComments( x => Array.append(x,aod));
          setShowMore( _ => Array.length(aod) < limit ? false : true);
          setLoading(_=>false);
          Js.Promise.resolve(aod)
        })
        >!= (err => {
            Js.log(err);
            setShowMore( _ => false);
            setLoading(_=>false);
            return([||])
          })
        |> ignore;
      };
      let revealReplies = () => {
        if (Array.length(comments) == 0 && showMore){
          fetchComments();
        };
      };
      React.useEffect1(()=>{
        if(showRep) revealReplies();
        None
      },[|showRep|]);
      <>
      <ol className="replies" hidden={!showRep}>
        {
          comments
          |> Array.map(x => {
            <Comments
              key =  {Js.Dict.get(x,"id") |> Option.value(~default="67")} 
              id          = {Js.Dict.get(x,"id")          |> Option.value(~default="Error: Bad Fetch")} 
              text        = {Js.Dict.get(x,"text")        |> Option.value(~default="Error: Bad Fetch")} 
              rating      = {Js.Dict.get(x,"rating")      |> Option.value(~default="Error: Bad Fetch")} 
              user_rating = {Js.Dict.get(x,"user_rating") |> Option.value(~default="Error: Bad Fetch")} 
              timestamp   = {Js.Dict.get(x,"timestamp")   |> Option.value(~default="Error: Bad Fetch")} 
              post_vers   = {Js.Dict.get(x,"post_vers")   |> Option.value(~default="Error: Bad Fetch")} 
              author_name = {Js.Dict.get(x,"author_name") |> Option.value(~default="Error: Bad Fetch")} 
              author_id   = {Js.Dict.get(x,"author_id")   |> Option.value(~default="Error: Bad Fetch")} 
              author_role = {Js.Dict.get(x,"author_role") |> Option.value(~default="Error: Bad Fetch")} 
              author_rep  = {Js.Dict.get(x,"author_rep")  |> Option.value(~default="Error: Bad Fetch")} 
              nestDepth
            />
            })
          |> React.array
        }
        <LoadingComments id show={showRep && loading} />
      </ol>
      <button className="more-replies"
      onClick={ _ => fetchComments() }
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
    ~nestDepth
  ) => 
    <CommentGroup id pType showRep nestDepth />);
	[@react.component]
	let make = () => {
    <CommentGroup id="1" pType="post" showRep=true nestDepth=0 />
	}
}

module PullrequestsHint = {
	[@react.component]
	let make = (~num_open, ~num_merged, ~num_closed) => {
		<>
			<div className="logo" />
			<h1>{React.string("pull requests")}</h1>
			<div className="sub">
				<span className="command">{React.string("pr --list")}</span>
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
	let make = (~pullrequests, ~prsExpand, ~expand_this) => {
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
				let status_class = switch (status) { | `Open => "open" | `Closed => "closed" | `Merged => "merged" };
				let is_expanded = List.assoc_opt(id, prsExpand) |> Option.value(~default=false);
				<li key=string_of_int(id) className=("pull-request-row " ++ (is_expanded ? "expanded" : " "))>
					<div className="head">
						<button onClick={_ => expand_this(id)}>{React.string(">")}</button>
					</div>
					<span className="id">{React.int(id)}</span>
					<span className={"status " ++ status_class}></span>
					<div className="aee">
						<span className="title">{React.string(title)}</span>
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
						<span className="id">{React.int(id)}</span>
						<span className="title">{React.string(title)}</span>
						<ul className="tags">{ tags |> List.map(x =>
							<li key=x><span className="tag">{React.string(x)}</span></li>
						) |> Array.of_list |> React.array}</ul>
						<span className="contributor user">{React.string(contributor_name)}</span>
					</div>
				</li>
			}) |> React.array}
		</ul>
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

	let row  = [@warning "-8"] fun | [|user_id, name|] =>
		( Float.to_int(Json.decodeNumberExn(user_id)), Json.decodeStringExn(name) );

	let json = {
		let per_row = row % Json.decodeArrayExn;
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
		let url = ReasonReactRouter.useUrl();
		let (prsExpand, setPrsExpand) = React.useState(() => []);
		let (tab, setTab) = React.useState(() => {
			Util.parseQueryParams(url.search)
			->Js.Dict.get("view")
			->Option.value(~default=View.to_string(Article))
			->View.of_string
		});
		let (pullrequests, setPrs) = React.useState(() => [||]);
		let (postInfo, setPostInfo) = React.useState(() => None);
		let tags = [| "Algorithm", "Rust" |];
		try ({
			let test = Melange__re.({
				Re.exec(Re.compile @@ Re.(seq @@ [char('a'), group(any |> rep1), char('b')]))
				%> (x => Re.Group.get(x, 1))
			});
			let u = test("annb");
			Js.Console.log("result:'" ++ u ++ "'");
		}) { | Invalid_argument(msg) => Js.Console.log("Invalid argument: '" ++ msg ++ "'") };
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
		let id = React.useMemo1(() => View.to_string(tab), [|tab|]);
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
		React.useEffect0(React__effect.async @@ () => Fetch__syntax.({
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
		let setCurrentTab = React.useCallback2(f => setTab(x => {
			let y = f(x);
			ReasonReactRouter.push(String.concat("/", ["", ...url.path]) ++ {
				let dict = Util.parseQueryParams'(url.search);
				"/?" ++ ( dict |> Util.List.replace_assoc'("view", View.to_string(y)) |> Util.stringQueryParams' )
			});
			y
		}), (setTab, url));
		let show = (x, f) => switch (x) { | Some(info) => f(info) | None => { <> </> } };
		React.useEffect1(() => {
			let show = (x, f) => switch (x) { | Some(info) => { f(info); None } | None => None };
			show(art) @@ (((title, _, _, _), _, _)) =>
			try ({
				Js__dom.Document.title_set(title)
			})
			{
			| e => Js.Console.error(e)
			}
		}, [|art|]);
		show(art) @@ ((postInfo, headings, article_body)) =>
		<>
			<header>
				<Component__header />
			</header>	
			<nav className=sidebarState>
				<ItemNav currentTab=tab setCurrentTab prCount=Array.length(pullrequests)/>
			</nav>
			<main className={sidebarState ++ " " ++ id}>
				<>
					<header className=Printf.sprintf("only %s", View.to_string(Article))><ArticleHeader tags info=postInfo /></header>
					<div className=Printf.sprintf("innerbody only %s", View.to_string(Article))><ArticleBody headings article_body /></div>
				</>
				<>
					<header className=Printf.sprintf("only %s", View.to_string(Discussion))>
						<DiscussionHint />
						<nav>
							<DiscussionFilter />
						</nav>
					</header>
					<main className=Printf.sprintf("only %s", View.to_string(Discussion))><DiscussionBody /></main>
				</>
				<>
					<header className=Printf.sprintf("only %s", View.to_string(Pullrequest))>
						<PullrequestsHint
							num_open={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Open => acc + 1 | _ => acc }), 0)}
							num_merged={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Merged => acc + 1 | _ => acc }), 0)}
							num_closed={pullrequests |> Array.fold_left(((acc, ((_, _, _, _, _, it, _, _), _)) => switch (it) { | `Closed => acc + 1 | _ => acc }), 0)}
							/>
						<nav>
							<PullrequestsFilter />
						</nav>
					</header>
					<main className=Printf.sprintf("only %s", View.to_string(Pullrequest))><PullrequestsBody pullrequests prsExpand expand_this=on_prs_update_expand /></main>
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
