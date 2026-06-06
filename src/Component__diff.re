module Linenumbering = {
  [@react.component]
  let make = (~text,~mode) => {
    let (_,_,lis) = text 
      |> List.fold_left( ((i,j,listicle),(d,_)) => {
        let hideThisLine = mode != d && mode != "=" && d != "=";
        ( hideThisLine? i : i+1
        , j+1
        , [<li key={j |> string_of_int} className={hideThisLine?"invisible":""}> {React.int(i)}</li>,...listicle]
        )
      },(0,0,[]))
    ;
    <ol className="line-numbering">
    {
      lis
      |> List.rev
      |> Array.of_list
      |> React.array
    }
    </ol>
  }
}
module TextContent = {
  [@react.component]
  let make = (~text,~mode) => {
    <div className="body">
    { text 
      |> List.mapi( (i,(d,v)) => {
        let hideThisLine = mode != d && mode != "=" && d != "=";
        <span key={i |> string_of_int} 
        className={ "text-style " ++ (hideThisLine?"invisible":d)}> 
          {React.string(v)}
        </span>
      })
      |> Array.of_list
      |> React.array
    }
    </div>
  }
}
module Ghost = {
  [@react.component]
  let make = (~text) => {
    let (_,_,lis) = text 
      |> List.fold_left( ((i,hold,listicle),(_,v)) => {
        v |> fun
        | "\n" =>
          ( i+1
          , [<span key={i |> string_of_int} 
          className={ "text-style invisible"}> 
            {React.string(v)}
          </span>,...hold]
          , listicle
          )
        | _ =>
          ( i
          , []
          , [hold,...listicle]
          )
      },(0,[],[]))
    ;
    <div className="ghost">
    { 
      lis
      |> List.mapi( (i,l)=>
        <div key={i |> string_of_int}>
          {
            l
            |> List.rev
            |> Array.of_list
            |> React.array
          }
        </div>
      )
      |> List.rev
      |> Array.of_list
      |> React.array
    }
    </div>
  }
}

module Code__box = {
  [@react.component]
  let make = (~text,~mode) => {
    <div className="code-box">
      <Linenumbering text mode />
      <main>
        <TextContent text mode />
        <Ghost text />
      </main>
    </div>
  }
}


module App__controls = {
  [@react.component]
  let make =  (~option, ~setOption) => {
    <header className="diff-controls">
      <label> {React.string("Split mode: ")}</label>
      <button className="split-mode"
      onClick={_=>setOption(a => (a+1) mod 3)}>
      {
        React.string(option|>fun
        | 0 => "On lines"
        | 1 => "On sentences"
        | 2 => "On words"
        | e => {Js.Console.error("split option illegal: "++string_of_int(e)); ""}
        )
      }
      </button>
    </header>
  }
};
module App__display = {
  [@react.component]
  let make = (~input1, ~input2, ~option) => {
    let (split, nukeDelim) = React.useMemo1(()=>{ 
      option |> fun
      | 0 => (['\n'],false)
      | 1 => (['\n','.','!','?',';','"'],false)
      | 2 => (['\n',' ','.','!','?',';','"'],false)
      | _ => (['\n'],false)
     },[|option|])
    let diffList = React.useMemo1(() => Diff.compare(input1,input2,split,nukeDelim),[|split|])
    ;
    <main>
      <Code__box text=diffList mode="-" />
      <Code__box text=diffList mode="+" />
      <Code__box text=diffList mode="=" />
    </main>
  }
};
module App = {
  [@react.component]
  let make = (~input1:string,~input2:string) => {
    let (option,setOption) = React.useState(()=> 0);
    <>
    <App__controls option setOption />
    <App__display input1 input2 option />
    </>
  }
};