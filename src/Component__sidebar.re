open React

module ShowHide = {
  [@react.component]
  let make = (~sidebarState,~setSidebarState) => {
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
      <span className="hamburger">
        <span className="0"/>
        <span className="1"/>
        <span className="2"/>
      </span>
    </button>
  }
}
module Notes__Card = {
  [@react.component]
  let make = (~index,~text,~updateNote,~swapNoteIndices,~deleteNote) => {
    let (value,setValue) = React.useState(()=>text)
    ;
    <li className={"note"}>
      <span/>
      <div className="controls">
        <button className="up"
          onClick={_=>swapNoteIndices(index,index+1)}>
          <span>{React.string("<")}</span>
        </button>
        <button className="down"
          onClick={_=>swapNoteIndices(index,index-1)}>
          <span>{React.string(">")}</span>
        </button>
      </div>
      <div className="body">
        <textarea
          value
          className="text-style"
          onKeyDown={e => {
            switch(React.Event.Keyboard.key(e)){
              | "Escape" => 
                React.Event.Keyboard.target(e)##blur()
              | "Enter"  => 
                if(React.Event.Keyboard.ctrlKey(e)){
                  updateNote(index,value)
                }
              | _ => ()
            }
          }}
          onChange={e => setValue(_ => React.Event.Form.target(e)##value)}
          onBlur={_ => updateNote(index,value)}
        />
        <div className="ghost text-style">
        {React.string(value++"\n.")}
        </div>
      </div>
    </li>
  }
}
module Notes = {
  type note = {
    index : int,
    text  : string,
  };
	[@react.component]
	let make = () => {
		let (noteList: list(note), setNoteList) = React.useState(() => []);
		let (expanded, setExpanded) = useState(() => false);
		let filter = [|expanded|] |> useMemo1 @@ () =>
			if (true)
			{	
				<button className="expand" onClick={ _ => setExpanded( _ => !expanded ) }>
					<span className={expanded ? "expanded":""}>{string(">")}</span> 
				</button>
			}
			else
			{ <> </> };

    let decoder = (json: Js.Json.t): note => {
	    open Melange_json;
      Of_json.
      { index : json |> field("index", int)
      , text  : json |> field("text", string)
      };
    };
    let insertNote = () => {
      setNoteList(l => [{index: List.length(noteList), text: "New note"},...l] )
    }
    let updateNote = (index , text) => {
      if(String.length(text)==0)
        deleteNote(index)
      else
        setNoteList(l => 
        l
        |> List.map((n)=>{
          n.index
          |> fun
          | x when x == index => {index:n.index,text:text}
          | _ => n
        })
      )
    }
    let swapNoteIndices = ( a:int , b:int ) => {
      if( a >= 0 && a < List.length(noteList) && b >= 0 && b < List.length(noteList))
      setNoteList(l => 
        l
        |> List.map((n)=>{
          n.index
          |> fun
          | x when x == a => {index:b,text:n.text}
          | x when x == b => {index:a,text:n.text}
          | _ => n
        })
        |> List.sort((b, a) => a.index - b.index)
      )
    }
    let normalizeList = (l) => {
      l
      |> List.mapi((i,n)=>{index:List.length(l)-i-1,text:n.text})
    }
    let deleteNote = ( i:int) => {
      setNoteList(l => 
        l
        |> List.filter(n => n.index != i)
        |> normalizeList
      )
    }
    let loadNoteList = () => {
      let fromStorage= Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.sidebar.notes") |> Option.value(~default="{}")
      setNoteList(_ => {
        try {
          Js.Json.parseExn(fromStorage) 
          |> Melange_json.Of_json.list(decoder)
          |> normalizeList
        }{
        | _ => {
            Dom.Storage.localStorage 
            |> Dom.Storage.setItem("bkhack.sidebar.notes")
            @@ (Js.Json.objectArray([||])
            |> Js.Json.stringify);
            []
          }
        }
      })
    }
    let saveNoteList = () => {
      let json = noteList
      |> List.sort((b, a) => a.index - b.index)
      |> List.map( (n) =>{
        let dict = Js.Dict.empty();
        Js.Dict.set(dict, "index" , n.index |> float_of_int  |> Js.Json.number)
        Js.Dict.set(dict, "text", n.text  |> Js.Json.string)
        dict
      })
      |> Array.of_list
      Dom.Storage.localStorage 
      |> Dom.Storage.setItem("bkhack.sidebar.notes")
      @@ (json
      |> Js.Json.objectArray
      |> Js.Json.stringify)
    }
    
		useEffect0(() => {
      loadNoteList();
			None
		})
		useEffect1(() => {
      saveNoteList();
			None
		},[|noteList|])
    ;
		<section id="sidebar-notes">
			<header> {string("My Notes")} </header>
			{filter}
				<ul className={expanded?"expanded":"truncated"}>
				{
					noteList
					|> List.map(note =>
              <Notes__Card key={"note"++(note.index|>string_of_int)++"-"++note.text} 
              index=note.index
              text=note.text
              updateNote
              swapNoteIndices
              deleteNote/>
            )
					|> Array.of_list
          |> array
				}
				</ul>
			<button className="addnote" 
      onClick={ _ =>{
      insertNote();
      }
    }>{string("+ Add note")}</button>
		</section>
	}
};

module Search = {

	// placeholder filter list
	let placeholder = [
		(0,"Unseen"),
		(1,"Subscribed"),
		(2,"Modified"),
		(3,"Verified"),
	];

  [@react.component]
  let make = () => {
    let (expanded, setExpanded) = useState(() => false);
    let (filterList,setFilterList) = useState(()=>[]);
    let (activeFilters, setActiveFilters) = useState(()=>[]);
    let (search,setSearch) = useState(()=>"");
    useEffect0(() => {
      // TODO: fetch filter list here
      setFilterList(_ => placeholder);
      None;
    });
    let changeSearchQueries = (input) => {
      setSearch(_ => input);
      // TODO: maybe do search hints thingies idk
    };
    let submitSearchAndFilters = () => ()
    // TODO: submit the search here
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
      // TODO: send filter data to refresh the feed here (usecontext?)
    };
    let filterCount=List.length(activeFilters);
    <section id="sidebar-search">
      <header>{string("Search Posts")}</header>
      <input className="searchbar" type_="text" 
        id="search" placeholder="Search..."
        onInput={(e) => {changeSearchQueries(Event.Form.target(e)##value)}}
        value = search
        />
      <button className="submitSearch" onClick={_=>submitSearchAndFilters()}>{string("Search")}</button>
      <button className="expand" onClick={ _ => setExpanded( _ => !expanded ) }>
        {string("Filters")}
        <div>{string(filterCount==0 ? "=":string_of_int(filterCount))}</div>
        <span className={expanded ? "expanded":""}>{string(">")}</span> 
      </button>
      <ul className={"filter-list"++ (expanded ? " expanded":"")}>
      {
        filterList
        |> List.map(((id,name)) =>
          <li key=string_of_int(id)>
            <button id=string_of_int(id)
              onClick={_=>toggleActive(id)}
              className={isActive(id)?"active":""}>
              {string(name)}    
            </button>
            <label htmlFor=string_of_int(id) className="visually-hidden">
            {string(name)}
            </label>
          </li>)
        |> Array.of_list
        |> array
      }
      </ul>
    </section>
  }
};

module Trending = {

	// placeholder filter list
	let placeholder = [
		(0,"algorithms"),
		(1,"golang"),
		(2,"rust"),
		(3,"performance"),
		(4,"distributed-sys"),
		(5,"ai-ml"),
	];

  [@react.component]
  let make = () => {
    let (trendingTags, setTrendingTags) = useState(()=>[]);
    let getTagColor = (name:string) => "c" ++ string_of_int(Char.code((name).[0]) mod 11);
    let searchForTag = (_id:int) => ();
    useEffect0(() => {
      // TODO: fetch trending tags here
      setTrendingTags(_ => placeholder);
      None;
    });
    // TODO: on click searches for posts with the tag
    <section id="sidebar-trendingtags">
      <header> {string("Trending Tags")} </header>
      <ul className="tag-list">
      {
        trendingTags
        |> List.map(((id,name)) =>
          <li key=string_of_int(id) 
            className={getTagColor(name)}>
            <button id=string_of_int(id)
              onClick={_=>searchForTag(id)}>
              {string("#" ++ name)}    
            </button>
            <label htmlFor=string_of_int(id) className="visually-hidden">
            {string(name)}
            </label>
          </li>)
        |> Array.of_list
        |> array
      }
      </ul>
    </section>
  }
};

module Activities = {

	// placeholder timestamp generators (you'd just fetch the timestamp string when fetching)
	// XXX(kinten) possibly duplicated with [Page__item.PullrequestsBody.duration]
	

	// placeholder hot tags list
	let placeholder = [ //(activity_id,activity_type, author, content, timestamp)
		(0, "commented","@dr.kim","This is a great resource on getting started with llms","6h ago"),
		(1, "opened issue","@prof.wilson","Link nolonger points to the paper","7m ago"),
		(2, "merged PR","@tran.phu","Breakthrough in quantum computing","5!s ago"),
	];

  [@react.component]
  let make = () => {
    let (activities,setActivities) = useState(()=>[]);
    useEffect0(() => {
      // TODO: fetch activities here
      setActivities(_ => placeholder);
      None;
    });
    let seeMoreActivities = () => ();
    // TODO: forward to the notifications page
    let viewActivity = (_id:int) => ();
    // TODO: forward to the page referenced
    <section id="sidebar-recent-activities">
      <header> {string("Recent Activities")} </header>
      <button className="see-more" onClick={_ => seeMoreActivities()}>{string("All activities")}</button>
      <ul>
        {
          activities
          |> List.map(((activity_id,activity_type, author, content, timestamp)) =>
            <li key=string_of_int(activity_id) onClick={_ => viewActivity(activity_id)}>
              <span className="agent truncated">{string(author)}</span>
              <span className="verb truncated">{string(activity_type)}</span>
              <span className="content truncated">{string(content)}</span>
              <span className="time">{string(timestamp)}</span>
            </li>)
          |> Array.of_list
          |> array
        }
			</ul>
		</section>
	}
};

[@react.component]
let make = (~sidebarState:string, ~setSidebarState:(string=>string)=>unit) =>
	<>
  <ShowHide  sidebarState setSidebarState/>
	<aside className=sidebarState>
    <Search />
    <Notes />
    <Trending />
    <Activities />
	</aside>
	</>
