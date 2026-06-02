module Dropdown = {
  [@react.component]
  let make = (~name,~options:list(string),~set,~value) => {
    let (isOpen,setIsOpen) = React.useState(()=>false)
    React.useEffect0(()=>{
      set(v => v |> Util.List.replace_assoc'(name,options|> List.hd))
      None
    })
    ;
    <button className={"dropdown "++name++" "++Option.value(List.assoc_opt(name, value),~default="")}
    onClick={_=>setIsOpen((!))}>
      {React.string("|")}
      <dialog open_=isOpen>
        <ol>
          {
            options
            |> List.map(listOption=>{
              <li key={name++listOption}
              className=listOption
              onClick={_=>set(dRes=>dRes |> Util.List.replace_assoc'(name,listOption))}>
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

module App = {
  [@react.component]
  let make = (
    ~countApi       :option(string)=?
  , ~fetchApi       :option(string)=?
  , ~setResult      :(Js.Json.t=>Js.Json.t) => unit
  , ~searchPrompt   :bool=false
  , ~filter         :option(list((string,list(string))))=?
  , ~refresh        :option(bool)=?
  , ~limit          :int = 10
  , ~searchBarId    :string = ""
  , ~setOpts        :option((list((string,string)) => list((string,string))) => unit)=?
  ) => {
    let auth = Auth.AuthContext.use()
    let url = ReasonReactRouter.useUrl()
		let searchParams = [|url|]|>React.useMemo1(() => url.search->Util.parseQueryParams');
    let (search,setSearch) = React.useState(() => List.assoc_opt("search", searchParams) |> Option.value(~default=""))
    let (dropdownResult,setDropdownResult) = React.useState(()=>[])
    let (count,setCount) = React.useState(()=>0)
    let (offset,setOffset) = React.useState(()=>0);
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
				++ "limit="  ++ string_of_int(limit)
				++ "&offset=" ++ string_of_int(offset*limit)
				++ ((searchPrompt && search!="")?("&search=" ++ (search |> Js.Global.encodeURIComponent)):"")
				++ (switch(filter,dropdownResult){
					| (None,_) | (_,[]) => ""
					| (Some(_),v)=> "&" ++ (v->Util.stringQueryParams')
				})
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
				++ "limit="  ++ string_of_int(limit)
				++ "&offset=" ++ string_of_int(offset*limit)
				++ ((searchPrompt && search!="")?("&search=" ++ search):"")
				++ (switch(filter,dropdownResult){
					| (None,_) | (_,[]) => ""
					| (Some(_),v)=> "&" ++ v->Util.stringQueryParams'
				})
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
      setOffset( _ => getCurrentOffset );
      None
    },[|refresh|])
   
    React.useEffect1(()=>{
      setOpts |> Option.iter(f =>  f( _ => dropdownResult))
      syncPageCount();
      None
    },[|dropdownResult|])
    React.useEffect1(()=>{
      fetch(offset);
      None
    },[|offset|])
    ;
    <div className="pagination">
      {
        !searchPrompt
        ?
        React.null
        :
        <input type_="text"
        className="search"
        placeholder="Search..."
        value=search
        onChange={e => setSearch(_ => React.Event.Form.target(e)##value)}
        onKeyDown={e => if(React.Event.Keyboard.key(e) === "Enter") syncPageCount()}
        id=?{ String.length(searchBarId)>0? Some(searchBarId) : None}
				role="secondaryBar"
        />
      }
      
      {
        switch(filter){
          | None | Some([]) => React.null
          | Some(list) =>
          list
          |> List.map(((k,v))=>{
            <Dropdown key={"dropdown"++k} name=k options=v set=setDropdownResult value=dropdownResult />
          })
          |> Array.of_list
          |> React.array
        }
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
