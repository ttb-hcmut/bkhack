[@react.component]
let make = () => {
    module Notes{
        [@react.component]
        let make = () => {
            // placeholder
            let placeholder = [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar.",
                "Fibonacci heap practical considerations",
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed convallis quis sapien pellentesque viverra. Donec efficitur eleifend tortor eget pulvinar."
            ];
            let (noteList, setNoteList) = React.useState(()=>[]);
            let (expanded, setExpanded) = React.useState(() => false);

            React.useEffect0(() => {
                // TODO: fetch notes here
                setNoteList(_ => placeholder);

                None;
            });
            
                // TODO: Some implementation to add a new note
            let createNewNote =  _ => ();


            // return element
            <section id="sidebar-notes">
                <header> {React.string("My Notes")} </header>
                {
                    if (List.length(noteList)>2)
                    {	
                        <button className="expand" onClick={ _ => setExpanded( _ => !expanded ) }>
                            <span className={expanded ? "expanded":""}>{React.string(">")}</span> 
                        </button>
                    }
                    else
                    { <> </>}
                }
                {
                    if (List.length(noteList) <=0 )
                    {
                        <div>{React.string("Add note to start taking notes")}</div>
                    }
                    else
                    {
                        <ul>
                        {
                            noteList
                            |> List.take(expanded?10:2)
                            |> List.mapi((index,item) => <li key=string_of_int(index) className={expanded?"":"truncated"}> {React.string(item)} </li>)
                            |> Array.of_list
                            |> React.array
                        }
                        </ul>
                    }
                }
                <button className="addnote" onClick={createNewNote}>{React.string("+ Add note")}</button>

            </section>
        }
    };

    module Search{
        [@react.component]
        let make = () => {
            
            let (expanded, setExpanded) = React.useState(() => false);
            
            // placeholder filter list
            let placeholder = [
                (0,"Unseen"),
                (1,"Subscribed"),
                (2,"Modified"),
                (3,"Verified"),
            ];
            let (filterList,setFilterList) = React.useState(()=>[]);
            let (activeFilters, setActiveFilters) = React.useState(()=>[]);
            let (search,setSearch) = React.useState(()=>"");

            React.useEffect0(() => {
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
            <>
            <section id="sidebar-search">
                <header>{React.string("Search Posts")}</header>
                <input className="searchbar" type_="text" 
                    id="search" placeholder="Search..."
                    onInput={(e) => {changeSearchQueries(React.Event.Form.target(e)##value)}}
                    value = search
                    />
                <button className="submitSearch" onClick={_=>submitSearchAndFilters()}>{React.string("Search")}</button>

                <button className="expand" onClick={ _ => setExpanded( _ => !expanded ) }>
                    {React.string("Filters")}
                    <div>{React.string(filterCount==0 ? "=":string_of_int(filterCount))}</div>
                    <span className={expanded ? "expanded":""}>{React.string(">")}</span> 
                </button>
                <ul className={"filter-list"++ (expanded ? " expanded":"")}>
                {
                    filterList
                    |> List.map(((id,name)) =>
                        <li key=string_of_int(id)>
                            <button id=string_of_int(id)
                                onClick={_=>toggleActive(id)}
                                className={isActive(id)?"active":""}>
                                {React.string(name)}    
                            </button>
                            <label htmlFor=string_of_int(id) className="visually-hidden">
                            {React.string(name)}
                            </label>
                        </li>)
                    |> Array.of_list
                    |> React.array
                }
                </ul>
            </section>
            </>
        }
    };

    module Trending{
        [@react.component]
        let make = () => {
            // placeholder filter list
            let placeholder = [
                (0,"algorithms"),
                (1,"golang"),
                (2,"rust"),
                (3,"performance"),
                (4,"distributed-sys"),
                (5,"ai-ml"),
            ];
            let (trendingTags, setTrendingTags) = React.useState(()=>[]);
            
            React.useEffect0(() => {
                // TODO: fetch trending tags here
                setTrendingTags(_ => placeholder);

                None;
            });


            let getTagColor = (name:string) => "c" ++ string_of_int(Char.code((name).[0]) mod 11);

            let searchForTag = (_id:int) => ();
                // TODO: on click searches for posts with the tag

            // return element
            <section id="sidebar-trendingtags">
                <header> {React.string("Trending Tags")} </header>
                <ul className="tag-list">
                {
                    trendingTags
                    |> List.map(((id,name)) =>
                        <li key=string_of_int(id) 
                            className={getTagColor(name)}>

                            <button id=string_of_int(id)
                                onClick={_=>searchForTag(id)}>
                                {React.string("#" ++ name)}    
                            </button>
                            <label htmlFor=string_of_int(id) className="visually-hidden">
                            {React.string(name)}
                            </label>
                        </li>)
                    |> Array.of_list
                    |> React.array
                }
                </ul>
            </section>
        }
    };

    module Activities{
        [@react.component]
        let make = () => {
            let (activities,setActivities) = React.useState(()=>[]);
            
            // placeholder timestamp generators (you'd just fetch the timestamp string when fetching)
            let timeAgo = (ms: int): string => {
                // let now =
                //     Js.Date.make()
                //     |> Js.Date.getTime
                //     |> int_of_float;

                // let diffMs = now - ms;

                let seconds = ms / 1000;
                let minutes = seconds / 60;
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
            // placeholder hot tags list
            let placeholder = [ //(activity_id,activity_type, author, content, timestamp)
                (0, "commented","@dr.kim","This is a great resource on getting started with llms",timeAgo(2228449)),
                (1, "opened issue","@prof.wilson","Link nolonger points to the paper",timeAgo(8422)),
                (2, "merged PR","@tran.phu","Breakthrough in quantum computing",timeAgo(55636711)),
            ];

            React.useEffect0(() => {
                // TODO: fetch activities here
                setActivities(_ => placeholder);

                None;
            });

            let seeMoreActivities = () => ();
            // TODO: forward to the notifications page

            let viewActivity = (_id:int) => ();
            // TODO: forward to the page referenced

            // return element
            <section id="sidebar-recent-activities">
                <header> {React.string("Recent Activities")} </header>
                
                <button className="see-more" onClick={_ => seeMoreActivities()}>{React.string("See More")}</button>
            
                <ul>
                {
                    activities
                        |> List.map(((activity_id,activity_type, author, content, timestamp)) =>
                            <li key=string_of_int(activity_id) onClick={_ => viewActivity(activity_id)}>
                                <span className="agent truncated">{React.string(author)}</span>
                                <span className="verb truncated">{React.string(activity_type)}</span>
                                <span className="content truncated">{React.string(content)}</span>
                                <span className="time">{React.string(timestamp)}</span>
                            </li>)
                        |> Array.of_list
                        |> React.array
                }
                </ul>
                

            </section>
        };
    };
	<>
        <Search />
        <Notes />
        <Trending />
        <Activities />
	</>
}
