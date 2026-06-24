module Linenumbering = {
  [@react.component]
  let make = (~text, ~mode) => {
    let final = React.useMemo1(()=>{
      let (_,jay,hol,lis) = text 
      |> List.fold_left( ((i,j,hold,listicle),(d,v)) => {
        let hideThisLine = mode != d && mode != "=" && d != "=";
        v |> fun
        | "\n" =>
          ( hideThisLine? i : i+1
          , j+2 
          , []
          , [ <li key={string_of_int(j+1)} className="line-numbering"> 
                <span className={"text-style " ++ (hideThisLine?"invisible":"")}>{React.int(i)}</span>
              </li>
            , <li key={string_of_int(j)} className="ghost" >
                {
                  hold
                  |> List.rev
                  |> Array.of_list
                  |> React.array
                }
              </li>
            , ...listicle]
          )
        | _ =>  
          ( i
          , j+1
          , [<span key={string_of_int(j)}
          className="text-style invisible"> 
            {React.string(v)}
          </span>,...hold]
          , listicle
          )
      }
      , (1,1,[],[<li key="0" className="line-numbering"> <span className="text-style">{React.int(0)}</span></li>])
      )
      ; 
      [ <li className="ghost" key={jay |> string_of_int}>
          {
            hol
            |> List.rev
            |> Array.of_list
            |> React.array
          }
        </li>
      , ...lis]
    },[|text|])
    ;
    <ol> 
    {
      final
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
    <div className="body l2">
    { text
      |> List.mapi( (i,(d,v)) => {
        let hideThisLine = mode != d && mode != "=" && d != "=";
        <span key={i |> string_of_int}
        className={"text-style " ++ (hideThisLine?"invisible":d)}> 
          {React.string(v)} 
        </span>
      })
      |> Array.of_list
      |> React.array
    }
    </div>
  }
}

module Code__box = {
  [@react.component]
  let make = (~text,~mode) => {
    <div className="code-box l0">
      // <ol>
      <Linenumbering text mode />
        // <Ghost text />
      // </ol>
      <TextContent text mode />
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
      | 1 => (['\n'    ,'.',':',',','!','?',';','"','(',')','[',']','{','}'],false)
      | 2 => (['\n',' ','.',':',',','!','?',';','"','(',')','[',']','{','}'],false)
      | _ => (['\n'],false)
     },[|option|])
    let (status,setStatus) = React.useState(() => "")
    let diffList = React.useMemo1(() => Diff.compare(input1,input2,split,nukeDelim,~setStatus = a => setStatus(_=>a),()),[|split|])
    ;
    <main>
      <div> {React.string(status)} </div>
      <div className="side-by-side">
      <Code__box text=diffList mode="-" />
      <Code__box text=diffList mode="+" />
      </div>
      <Code__box text=diffList mode="=" />
    </main>
  } 
};
module App = {
  [@react.component]
  let make = (~input1:string,~input2:string) => {
    let (option,setOption) = React.useState(()=> 0);
    <div className="diff-box">
      <App__controls option setOption />
      <App__display input1 input2 option />
    </div>
  }
};
