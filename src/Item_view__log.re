module DiffContext = {
  type t = {
    cid1              : option(int)
  , message1          : string
  , title1            : string
  , input1            : string
  , set1              : (option(int),string,string,string) => unit
  , cid2              : option(int)
  , message2          : string
  , title2            : string
  , input2            : string
  , set2              : (option(int),string,string,string) => unit
  };

  let defaultValue: t = {
    cid1              : None
  , message1          : ""
  , title1            : ""
  , input1            : ""
  , set1              : (_,_,_,_) => ()
  , cid2              : None
  , message2          : ""
  , title2            : ""
  , input2            : ""
  , set2              : (_,_,_,_) => ()
  };

  let ctx = React.createContext(defaultValue);

  module Provider = {
    [@react.component]
    let make = (~children: React.element) => {
    let (cid1    , setCid1')     = React.useState(()=>None)    
    and (message1, setMessage1') = React.useState(()=>"")
    and (title1  , setTitle1')   = React.useState(()=>"")  
    and (input1  , setInput1')   = React.useState(()=>"")  
    and (cid2    , setCid2')     = React.useState(()=>None)    
    and (message2, setMessage2') = React.useState(()=>"")
    and (title2  , setTitle2')   = React.useState(()=>"")  
    and (input2  , setInput2')   = React.useState(()=>"");
    
    let set1 = (i,m,t,b) => {
      setCid1'(_    => i);
      setMessage1'(_=> m);
      setTitle1'(_  => t);
      setInput1'(_  => b);
    }
    let set2 = (i,m,t,b) => {
      setCid2'(_    => i);
      setMessage2'(_=> m);
      setTitle2'(_  => t);
      setInput2'(_  => b);
    }
     
    let ctxValue: t = {
    cid1              : cid1    
  , message1          : message1
  , title1            : title1  
  , input1            : input1  
  , set1              : set1    
  , cid2              : cid2    
  , message2          : message2
  , title2            : title2  
  , input2            : input2  
  , set2              : set2    
    }; 
    let provider = React.Context.provider(ctx);
    React.createElement(provider, {"value": ctxValue, "children": children})
    };
  };
  let use = () => React.useContext(ctx);
};

let%Fiber.bind k' = ((), _) => {
	// open Fiber.Syntax;
	Diff.compare("a b c","a d c",[' '],true,~setStatus = _ => (),())
}

module Inspectview = {
	[@react.component]
	let make = () => {
    let (status, setStatus) = React.useState(() => "")
		let ctrl = React.useMemo0(Fiber.Ctrl.create);
		let k = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, k'));
		let () = React.useEffect0(() => {
			ignore(Fetch__syntax.({
				let* u = Fiber.With_ctrl1.run_promise(~ctrl, (), k);
				if (false) { ignore(u+1) };
				Js.Console.log(u);
				return(())
			}>!= (e => { Js.Console.error(e); return(()) })));
			None
		});
    let (option,setOption) = React.useState(()=> 0)
    let diff = DiffContext.use()
    let (split, nukeDelim) = React.useMemo1(()=>{ 
      option |> fun
      | 0 => (['\n'],false)
      | 1 => (['\n'    ,'.',':',',','!','?',';','"','(',')','[',']','{','}'],false)
      | 2 => (['\n',' ','.',':',',','!','?',';','"','(',')','[',']','{','}'],false)
      | _ => (['\n'],false)
     },[|option|])
    let diffList = React.useMemo3(() => {
    (diff.cid1,diff.cid2)|> fun
      | (Some(_),Some(_)) => Diff.compare(diff.input1,diff.input2,split,nukeDelim,~setStatus = a => setStatus(_=>a),())
      | _ => []
    },(split,diff.cid1,diff.cid2))
    ;
    <div className="diff-box">
      <Component__diff.App__controls option setOption />
      <main>
        <div> {React.string(status)} </div>
        <div className="side-by-side">
          <div className="diff1">
          {
            diff.cid1 |> fun
            | None => <label>{React.string("Diff input 1: Unset")}</label>
            | Some(c) => 
              <>
              <label>{React.string("Diff input 1:")}</label>
              <span className="cid">{React.int(c)}</span>
              <span className="spacer"/>
              <span className="message">{React.string(diff.message1)}</span>
              <div className="title">
                <input
                  type_="text" 
                  autoComplete="off" 
                  value=diff.title1
                  disabled=true/>
              </div>
              <Component__diff.Code__box text=diffList mode="-" />
              </>
          }
          </div>
          <div className="diff2">
          {
            diff.cid2 |> fun
            | None => <label>{React.string("Diff input 2: Unset")}</label>
            | Some(c) => 
              <>
              <label>{React.string("Diff input 2:")}</label>
              <span className="cid">{React.int(c)}</span>
              <span className="spacer"/>
              <span className="message">{React.string(diff.message2)}</span>
              <div className="title">
                <input
                  type_="text" 
                  autoComplete="off" 
                  value=diff.title2
                  disabled=true/>
              </div>
              <Component__diff.Code__box text=diffList mode="+" />
              </>
          }
          </div>
        </div>
        {
            (diff.cid1,diff.cid2) |> fun
            | (Some(_),Some(_)) => <Component__diff.Code__box text=diffList mode="=" />
            | _ => React.null  
        }
      </main>
    </div>
	}
};


module Listview__Hint = {
	[@react.component]
	let make = () => {
		<>
			<div className="logo" />
			<h1>{React.string("commit history")}</h1>
			<div className="sub">
				<span className="command">{React.string("commit list $id")}</span>
				<span className="summary">
					// <data className="pr-open">{React.int(num_open)}</data>
					// <data className="pr-merged">{React.int(num_merged)}</data>
					// <data className="pr-closed">{React.int(num_closed)}</data>
				</span>
			</div>
			// <button className="action">{React.string("new pr")}</button>
		</>
	}
}
module Listview__Filter = {
	[@react.component]
	let make = (~setResult,~parentId) => {
    <Pagination.App 
      defaultLimit = 3
      countApi={"/api/history/count?postid="++string_of_int(parentId)++"&"}
      fetchApi={"/api/history/list?postid="++string_of_int(parentId)++"&"}
      options={[
        Pagination.textinput( ~action = "search"
                            , ~placeholder = "Search..."
                            , ~is_secondary = true
                            , ())
      , Pagination.dropdown(  ~action = "searchby"
                            , ~options = ["message","username","title","body"])
      , Pagination.dropdown(  ~action = "sortby"
                            , ~options = ["merge","age"])
      , Pagination.dropdown(  ~action = "orderby"
                            , ~options = ["ascending","descending"])
      ]}
      setResult
    />
	}
};
module Listview__Body_Card = {
	[@react.component]
  let make = (
    ~commit_id      
  , ~commit_message
  , ~owner_name          
  , ~post_title    
  , ~post_text      
  , ~timestamp      
  ) => {
    let diff = DiffContext.use();
    let (expand,setExpand) = React.useState(()=> false)
    let (tags,setTags) = React.useState(()=> [||])
    let fetchTags = (~id) => {
      let open Fetch__syntax;
      open Model.Tag;
      Fetch.fetch(Env.backend ++ "/api/tag/commit"
        ++ "?commitid="  ++ string_of_int(id))
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
      fetchTags(~id=commit_id);
      None
    })
    ;
    <li className={"card " ++ (expand?"expand":"")}>
        <header>
          <button
          onClick={_ => setExpand((!))}
          className="show-hide">
            {React.string(">")}
          </button>
          <span className="cid">{React.int(commit_id)}</span>
          <span className="spacer"/>
          <span className="message">{React.string(commit_message)}</span>
          <span className="author">{React.string(owner_name)}</span>
          <span className="timestamp">{React.string(Util.utcToRelative(timestamp))}</span>
        </header>
        <main hidden={!expand}>
          <ul className="tags">
          { open Model.TagButTheColorIsAString;
            tags 
            |> Array.map(x => 
            <li key={string_of_int(x.tag_id)}>
              <span className="tag" 
              style={ReactDOM.Style.make(
                ~color           = x.tag_color
              , ~borderColor     = x.tag_color
              , ~backgroundColor = "color-mix(in srgb, "++x.tag_color++", transparent 75%)"
              , ())}>
                {React.string(x.tag_name)}
              </span>
            </li>) |> React.array}
          </ul>
          <div className="title">
            <input
              type_="text" 
              autoComplete="off" 
              value=post_title
              disabled=true/>
          </div>
          <div className="body">
            <div className="row-number text-style">
            {
              let list = post_text |> String.split_on_char('\n')
              switch(List.length(list)){
                | 0 => [|"1"|]
                | x => Array.init(x-1, i => string_of_int(i + 2))
              }
              |> Array.fold_left((acc,ele) => acc++"\n"++ele,"1")
              |> (x)=> x++"\n."
              |> React.string
            }
            </div>
            <textarea className="body-input text-style" 
              value=post_text 
              placeholder="e.g. # details about..."
              disabled=true/>
            // <div className="ghost body-input text-style">{React.string(post.postBody++"\n")}</div>
          </div>
          <div className="side-by-side">
            <button
              onClick={_=>
                diff.set1(
                  Some(commit_id)      
                , commit_message          
                , post_title    
                , post_text
                )
              }
            >{React.string("Set as diff input 1")}</button>
            <button
              onClick={_=>
                diff.set2(
                  Some(commit_id)      
                , commit_message          
                , post_title    
                , post_text
                )
              }
            >{React.string("Set as diff input 2")}</button>
          </div>
        </main>
    </li>
  }
};
module Listview__Body = {
	[@react.component]
  let make = (~result) => {
    let (items,setItems) = React.useState(() => [||])
    React.useEffect1(()=>{
      if(result != Js.Json.null){
        setItems(_ => result |> Model.Decode.fetchedCommits)
      }
      None
    },[|result|])
    ;
    <ol>
    {
      open Model.FetchedCommit;
      items
      |> Array.map(x => {
        <Listview__Body_Card 
          key={x.commit_id |> string_of_int}
          commit_id      = {x.commit_id      }
          commit_message = {x.commit_message }
          owner_name     = {x.owner_name     }
          post_title     = {x.post_title     }
          post_text      = {x.post_text      }
          timestamp      = {x.timestamp      }
        />
      })
      |> React.array
    }
    </ol>
  }
};
module Listview = {
	[@react.component]
	let make = (~className=?,~parentId) => {
    let cls = className |> Option.value(~default="")
    let (result, setResult) = React.useState(() => Js.Json.null)
    ;
    <>
      <header className=("only listview "++cls)>
        <Listview__Hint />
        <nav> 
          <Listview__Filter setResult parentId /> 
        </nav>
      </header>
      <main className=("only listview "++cls)>
        <Listview__Body result />
          
        <Inspectview />
      </main>
    </>
	}
};
module App = {
  [@react.component]
  let make = (~className=?, ~parentId) => {
    <DiffContext.Provider >
      <Listview className=?className parentId />
    </DiffContext.Provider >
  }
};
