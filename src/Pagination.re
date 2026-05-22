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
  ) => {
    let url = ReasonReactRouter.useUrl();
    let (search,setSearch) = React.useState(()=>"")
    let (dropdownResult,setDropdownResult) = React.useState(()=>[])
    let (count,setCount) = React.useState(()=>0)
    let (offset,setOffset) = React.useState(()=>0)
    let getCurrentOffset = url.search
                -> Util.parseQueryParams
                -> Js.Dict.get("offset")
                -> Option.value(~default = "0")
                -> int_of_string
    let moveToPage = (number:int) => {
      ReasonReactRouter.push(String.concat("/",["",...url.path]) ++ "/?"
      ++( url.search
        |> Util.parseQueryParams'
        |> Util.List.replace_assoc'("offset", string_of_int(number+offset)) 
        |> Util.stringQueryParams' )
        )
    }
    let getPageCount = () => {
      switch(countApi){
        | None => ()
        | Some(a) =>let open Fetch__syntax;
          Fetch.fetch(Env.backend ++ a)
          >>= Fetch.Response.json
          >!= (err => {
              Js.log(err);
              return(Js.Json.number(0.0))
            })
          >>= (json => {
            let x = Js.Json.decodeNumber(json) |> Option.value(~default = 0.0);
            setCount(_ =>Int.max(Js.Math.ceil_int(x/.float_of_int(Int.max(1,limit)))-1,0));
            Js.Promise.resolve(json)
          })
          |> ignore;
      }
      
    }
    let fetch = (offset) => {
      switch(fetchApi){
        | None => ()
        | Some(a) => let open Fetch__syntax;
          let request = Env.backend ++ a
            ++ "limit="  ++ string_of_int(limit)
            ++ "&offset=" ++ string_of_int(offset*limit)
            ++ ((searchPrompt && search!="")?("&search=" ++ search):"")
            ++ (switch(filter,dropdownResult |> Util.stringQueryParams'){
              | (None,_) | (_,"") => ""
              | (Some(_),v)=> "&" ++ v 
            })
          Fetch.fetch(request)
          >>= Fetch.Response.json
          >>= (json => {
            setResult(_=>json)
            Js.Promise.resolve(json)
          })
          >!= (err => {
              Js.log(err);
              Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
            })
          |> ignore;
      }
    }
    React.useEffect2(()=>{
      setOffset( _ => getCurrentOffset );
      getPageCount();
      fetch(getCurrentOffset);
      None
    },(refresh,url))
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
        onKeyDown={e => if(React.Event.Keyboard.key(e) === "Enter"){fetch(getCurrentOffset)}}
        id=?{ String.length(searchBarId)>0? Some(searchBarId) : None}
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
        {React.int(offset)}
        {React.string(" / ")}
        {React.int(count)}
        </span>
        <button className="next-page"
        onClick={_=>moveToPage( 1)}
        disabled={offset>=count}/>
      </div>
    </div>
  }
}