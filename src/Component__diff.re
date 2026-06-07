module Linenumbering = {
  [@react.component]
  let make = (~text,~mode) => {
    let (_,_,_,lis) = text 
      |> List.fold_left( ((i,j,hold,listicle),(d,v)) => {
        let hideThisLine = mode != d && mode != "=" && d != "=";
         v |> fun
        | "\n" =>
          ( hideThisLine? i : i+1
          , j+1
          , []
          , [ <li key={j |> string_of_int} className={"line-numbering text-style l2 " ++ (hideThisLine?"invisible":"")}> {React.int(i)}</li>
            , <li className="ghost l3" key={i |> string_of_int}>
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
          , [<span key={j |> string_of_int}
          className={ "l3 text-style invisible"}> 
            {React.string(v)}
          </span>,...hold]
          , listicle
          )
      },(1,1,[],[<li key="0" className="line-numbering text-style l2"> {React.int(0)}</li>]))
    ;
    <ol>
    {
      lis
      |> List.rev
      |> Array.of_list
      |> React.array
    }
    </ol>
  }
}
// module Ghost = {
//   [@react.component]
//   let make = (~text) => {
//     let (_,_,lis) = text 
//       |> List.fold_left( ((i,hold,listicle),(_,v)) => {
//         v |> fun
//         | "\n" =>
//           ( i
//           , []
//           , [hold,...listicle]
//           )
//         | _ =>
//           ( i+1
//           , [<span key={i |> string_of_int}
//           className={ "l3 text-style invisible"}> 
//             {React.string(v)}
//           </span>,...hold]
//           , listicle
//           )
//       },(0,[],[]))
//     ;
//     <>
//     { 
//       lis
//       |> List.mapi( (i,l)=>
//         <li className="ghost l3" key={i |> string_of_int}>
//           {
//             l
//             |> List.rev
//             |> Array.of_list
//             |> React.array
//           }
//         </li>
//       )
//       |> List.rev
//       |> Array.of_list
//       |> React.array
//     }
//     </>
//   }
// }
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
      | 1 => (['\n','.','!','?',';','"'],false)
      | 2 => (['\n',' ','.','!','?',';','"'],false)
      | _ => (['\n'],false)
     },[|option|])
    let diffList = React.useMemo1(() => Diff.compare(input1,input2,split,nukeDelim),[|split|])
    ;
    <main>
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