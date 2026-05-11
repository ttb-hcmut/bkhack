open React

module Notes{

	// placeholder
	let placeholder = [
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar.",
		"Fibonacci heap practical considerations",
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar."
	];

	// TODO: Some implementation to add a new note
	let createNewNote =  _ => ();

	[@react.component]
	let make = () => {
		let (noteList, setNoteList) = useState(()=>[]);
		let (expanded, setExpanded) = useState(() => false);
		let filter = [|expanded|] |> useMemo1 @@ () =>
			if (List.length(noteList)>2)
			{	
				<button className="expand" onClick={ _ => setExpanded( _ => !expanded ) }>
					<span className={expanded ? "expanded":""}>{string(">")}</span> 
				</button>
			}
			else
			{ <> </> };
		let noteList = (expanded, noteList) |> useMemo2 @@ () =>
			if (List.length(noteList) <=0 )
			{
				<div>{string("Add note to start taking notes")}</div>
			}
			else
			{
				<ul>
				{
					noteList
					|> List.take(expanded?10:2)
					|> List.mapi((index,item) => <li key=string_of_int(index) className={expanded?"":"truncated"}> {string(item)} </li>)
					|> Array.of_list
					|> array
				}
				</ul>
			};
		useEffect0(() => {
			// TODO: fetch notes here
			setNoteList(_ => placeholder);
			None;
		});
		<section id="sidebar-notes">
			<header> {string("My Notes")} </header>
			{filter}
			{noteList}
			<button className="addnote" onClick={createNewNote}>{string("+ Add note")}</button>
		</section>
	}
};

module Search{

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

module Trending{

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

module Activities{

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
let make = () =>
	<>
	<Search />
	<Notes />
	<Trending />
	<Activities />
	</>
