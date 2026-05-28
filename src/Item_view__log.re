module Inspectview = {
	[@react.component]
	let make = (~className=?) => {
    let cls = className |> Option.value(~default="");
		<>
		<header className=("only "++cls)></header>
		<main></main>
		</>
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
        limit = 3
        searchPrompt=true
        countApi={"/api/history/count?postid="++string_of_int(parentId)++"&"}
        fetchApi={"/api/history/list?postid="++string_of_int(parentId)++"&"}
        filter  ={[
          ("searchby",["message","username","title","body"])
        , ("sortby",  ["merge","age"])
        , ("orderby", ["ascending","descending"])
        ]}
        setResult
      />
	}
};
[@alert warning("Bao, what the  is a subgrid")]
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
    let (expand,setExpand) = React.useState(()=> false)
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
        open Fetch__syntax;
        result
        |> Model.Decode.Response.fetchedCommits
        >>= (aod => {
          setItems(_ => aod)
          return(aod)
        })
        |> ignore;
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
          key={"listviewbodycard"++(x.commit_id |> string_of_int)}
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
      </main>
    </>
	}
};
module App = {
  [@react.component]
  let make = (~className=?, ~parentId) => {
    <Listview className=?className parentId/>
  }
}