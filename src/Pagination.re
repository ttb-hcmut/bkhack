module Pagination__dropdown = {
  [@react.component]
  let make = (~action:string,~options:list(string),~set,~value) => {
    let (isOpen,setIsOpen) = React.useState(()=>false)
    // React.useEffect0(()=>{
    //   set(v => v |> Util.List.replace_assoc'(action,options|> List.hd))
    //   None
    // })
    ;
    <button className={"dropdown "}
    onClick={_=>setIsOpen((!))}>
      <div className={action++" "++Option.value(List.assoc_opt(action, value),~default="")}>
        {React.string("|")}
      </div>
      <dialog open_=isOpen>
        <ol>
          {
            options
            |> List.map(listOption=>{
              <li key={action++listOption}
              className=listOption
              onClick={_=>set(dRes=>dRes |> Util.List.replace_assoc'(action,listOption))}>
              </li>
            })
            |> Array.of_list
            |> React.array
          }
        </ol>
      </dialog>
    </button>
    
  }
}
module Pagination__textinput = {
  [@react.component]
  let make = (~action:string, ~input_placeholder:option(string), ~searchbar_id:option(string), ~is_secondary:bool, ~set, ~value) => {
    let (search,setSearch) = React.useState(() => Option.value(List.assoc_opt(action, value),~default=""))
    ;
    <input type_="text"
    className=action
    placeholder={Option.value(input_placeholder,~default= action)}
    value=search
    onChange={e => setSearch(_ => React.Event.Form.target(e)##value)}
    onKeyDown={e => 
      if(React.Event.Keyboard.key(e) === "Enter") 
      {
        String.length(search) |> fun
        | 0 => set(v => v |> List.remove_assoc(action))
        | _ => set(v => v |> Util.List.replace_assoc'(action,search))
      }
    }
    id=?searchbar_id
    role=?{is_secondary?Some("secondaryBar"):None}
    />
  }
}

module Pagination__limit = {
  [@react.component]
  let make = (~action:string, ~input_placeholder:option(string),~options:list(int), ~set,~value) => {
    let (isOpen,setIsOpen) = React.useState(()=>false)
    let (limit,setLimit) = React.useState(() => Option.value(List.assoc_opt(action, value),~default="0"))
    ;
    <button className={"dropdown "}>
      <div className=action
      onClick={_=>setIsOpen((!))}>
        {React.string("|" ++ limit)}
      </div>
      <dialog open_=isOpen>
        <ol>
          <li> 
            <label className="custom"/>
            <input type_="number"
            placeholder={Option.value(input_placeholder,~default= action)}
            value=limit
            onChange={e => setLimit(_ =>React.Event.Form.target(e)##value)}
            onKeyDown={e => 
              if(React.Event.Keyboard.key(e) === "Enter") 
              {
                String.length(limit) |> fun
                | 0 => setLimit(_ => Option.value(List.assoc_opt(action, value),~default="0") )
                | _ => 
                {
                  setLimit(v => ( v |> int_of_string |> fun | x when x > 99 => 99 | x when x < 0 => 0 | x => x ) |> string_of_int )
                  set(v => v |> Util.List.replace_assoc'(action,( limit |> int_of_string |> fun | x when x > 99 => 99 | x when x < 0 => 0 | x => x ) |> string_of_int ));
                }
                setIsOpen(_ => false)
              }
            }
            disabled={!isOpen}
            />
          </li>
          {
            options
            |> List.map(listOption=>{
              <li key={action++(listOption |> string_of_int)}
              onClick={_=>
              {
                setIsOpen(_ => false)
                setLimit(_ => listOption |> string_of_int)
                set(v => v |> Util.List.replace_assoc'(action,listOption |> string_of_int))}
              }>
              {React.int(listOption)}
              </li>
            })
            |> Array.of_list
            |> React.array
          }
        </ol>
      </dialog>
    </button>
    
  }
}

type kind =
  | Dropdown({action: string, options: list(string)})
  | Textinput({action: string, input_placeholder: option(string), searchbar_id: option(string), is_secondary: bool})
  | Limit({action: string, input_placeholder: option(string), options: list(int)});

let dropdown = 
  ( ~options           : list(string) 
  , ~action            : string 
  ) =>  Dropdown({action, options})
and textinput =
  ( ~placeholder       : option(string)=?
  , ~searchbar_id      : option(string)=?
  , ~is_secondary      : bool=false 
  , ~action            : string
  , ()
  ) => Textinput({action: action, input_placeholder: placeholder, searchbar_id: searchbar_id, is_secondary: is_secondary})
and limit = 
  ( ~placeholder       : option(string)=?
  , ~options           : list(int)
  , ~action            : string
  , ()
  ) => Limit({action: action, input_placeholder: placeholder, options: options});


module App = {
  [@react.component]
  let make = (
    ~countApi       :option(string)=?
  , ~fetchApi       :option(string)=?
  , ~setResult      :(Js.Json.t=>Js.Json.t) => unit
  // , ~searchPrompt   :bool=false
  , ~options        :option(list(kind))=?
  , ~refresh        :option(bool)=?
  , ~defaultLimit   :int = 10
  // , ~searchBarId    :string = ""
  , ~setOpts        :option((list((string,string)) => list((string,string))) => unit)=?
  ) => {
    let auth = Auth.AuthContext.use()
    let url = ReasonReactRouter.useUrl()
		// let searchParams = [|url|]|>React.useMemo1(() => url.search->Util.parseQueryParams')
    let (paginationOptions: list((string,string)),setPaginationOptions) = React.useState(()=>
        options |> fun
          | None | Some([]) => [("limit", defaultLimit|>string_of_int)]
          | Some(list) =>
            list
            |> List.filter_map( fun
              | Dropdown({action: a, options: o}) => Some((a, o |> List.hd))
              | Textinput({action: a,_}) when a == "search" => 
              {
                url.search
                |> Util.parseQueryParams'
                |> List.assoc_opt("search")
                |> fun
                | None => None
                | Some(i) => Some(("search", i))
                }
              | _ => None
            )
            |> Util.List.replace_assoc'("limit", Option.value(
                url.search
                |> Util.parseQueryParams'
                |> List.assoc_opt("limit")
              , ~default= defaultLimit|>string_of_int)
            )
    )
    // and (search,setSearch) = React.useState(() => List.assoc_opt("search", searchParams) |> Option.value(~default=""))
    // and (dropdownResult,setDropdownResult) = React.useState(()=>[])
    and (count,setCount) = React.useState(()=>0)
    and (offset,setOffset) = React.useState(()=>0);
    let limit = Option.value(List.assoc_opt("limit", paginationOptions),~default=defaultLimit |> string_of_int) |>int_of_string
    let getCurrentOffset = url.search
                -> Util.parseQueryParams
                -> Js.Dict.get("offset")
                -> Option.value(~default = "0")
                -> int_of_string
    let moveToPage = (number:int) => {
      ReasonReactRouter.push(
				String.concat("/",["",...url.path]) ++ "/?"
				++( url.search
					|> Util.parseQueryParams'
					|> Util.List.replace_assoc'("offset", string_of_int(number+offset)) 
					|> Util.stringQueryParams' )
			);
			setOffset(offset => number+offset)
    }
    let fetch = offset => Option.iter(a => Fetch__syntax.({
			let request = Env.backend ++ a
				// ++ "limit="  ++ string_of_int(limit)
				++ "&offset=" ++ string_of_int(offset*limit)
				// ++ ((searchPrompt && search!="")?("&search=" ++ (search |> Js.Global.encodeURIComponent)):"")
				++ "&" ++ (paginationOptions->Util.stringQueryParams')
      Fetch.fetchWithInit(
        request,
        Fetch.RequestInit.make(
          ~method_=Get,
          ~headers=Fetch.HeadersInit.make({
            "Content-Type": "application/json",
            "jwterrible": auth.withAuth(false) |> Js.Json.stringify
          }),
          ()
        )
      )
			>>= Fetch.Response.json
			>>= (json => { setResult(_=>json); return(json) })
			>!= (err => {
					Js.log(err);
					Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
				})
			|> ignore;
    }), fetchApi)
    let syncPageCount = () => Option.iter(a => Fetch__syntax.({
			let request = Env.backend ++ a
				// ++ "limit="  ++ string_of_int(limit)
				++ "&offset=" ++ string_of_int(offset*limit)
				// ++ ((searchPrompt && search!="")?("&search=" ++ search):"")
				++ "&" ++ paginationOptions->Util.stringQueryParams'
      Fetch.fetchWithInit(
        request,
        Fetch.RequestInit.make(
          ~method_=Get,
          ~headers=Fetch.HeadersInit.make({
            "Content-Type": "application/json",
            "jwterrible": auth.withAuth(false) |> Js.Json.stringify
          }),
          ()
        )
      )
			>>= Fetch.Response.json
			>!= (err => {
					Js.log(err);
					return(Js.Json.number(0.0))
				})
			>>= (json => {
				let x = Js.Json.decodeNumber(json) |> Option.value(~default = 0.0);
				setCount(_ =>Int.max(Js.Math.ceil_int(x/.float_of_int(Int.max(1,limit)))-1,0));
				if(offset>Int.max(Js.Math.ceil_int(x/.float_of_int(Int.max(1,limit)))-1,0))
				{
					setOffset(_ =>Int.max(Js.Math.ceil_int(x/.float_of_int(Int.max(1,limit)))-1,0));
				} else {
					fetch(offset);
				}
				Js.Promise.resolve(json)
			})
			|> ignore;
    }), countApi)
    React.useEffect1(()=>{
      if (getCurrentOffset == offset)
        fetch(offset)
      else
        setOffset( _ => getCurrentOffset );
      None
    },[|refresh|])
   
    React.useEffect1(()=>{
      setOpts |> Option.iter(f =>  f( _ => paginationOptions))
      syncPageCount();
      None
    },[|paginationOptions|])
    React.useEffect1(()=>{
      fetch(offset);
      None
    },[|offset|])
    ;
    <div className="pagination">
      {
        options |> fun
          | None | Some([]) => React.null
          | Some(list) =>
          list
          |> List.map(fun
            | Dropdown({action: a, options: o}) => 
              <Pagination__dropdown key={"dropdown"++a} action=a options=o set=setPaginationOptions value=paginationOptions />
            | Textinput({action: a, input_placeholder: p, searchbar_id: i, is_secondary: s}) => 
              <Pagination__textinput key={"textinput"++a} action=a input_placeholder=p searchbar_id=i is_secondary=s set=setPaginationOptions value=paginationOptions />
            | Limit({action: a, input_placeholder: p, options: o}) =>
              <Pagination__limit key={"textinput"++a} action=a input_placeholder=p  options=o set=setPaginationOptions value=paginationOptions />
          )
          |> Array.of_list
          |> React.array
      }
      <div className="paging">
        <button className="prev-page"
        onClick={_=>moveToPage(-1)}
        disabled={offset<=0}/>
        <span>
        {React.int(offset+1)}
        {React.string(" / ")}
        {React.int(count+1)}
        </span>
        <button className="next-page"
        onClick={_=>moveToPage( 1)}
        disabled={offset>=count}/>
      </div>
    </div>
  }
}
