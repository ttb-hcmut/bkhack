module Diff = {
  let rec stringDisassembler = (input:string,split:list(char),index:int,hold:string,list:list(string)) => {
    (index,input.[index],split) |> fun
    | (0,e,[]) => [String.make(1, e),...list]
    | (_,e,[]) => stringDisassembler(input,split,index-1,"",[String.make(1, e),...list])
    | (0,e,l) when List.mem(e, l) => [String.make(1, e),...[hold,...list]]
    | (_,e,l) when List.mem(e, l) => stringDisassembler(input,l,index-1,"",[String.make(1, e),...[hold,...list]])
    | (0,e,_l) => [String.make(1, e) ++ hold,...list]
    | (_,e,l) => stringDisassembler(input,l,index-1,String.make(1, e) ++ hold,list)
  }
  let matrixAt = (x:int,y:int,matrix:ref(array(array(int)))) => {
    (x,y)
    |> fun
    | (x',y') when x'<0 || y'<0 => 0
    | (x',y') => matrix^[x'][y']
  }
  let setMatrix = (x:int,y:int,value:int,matrix:ref(array(array(int)))) => {
    matrix := matrix^
    |> Array.mapi((i,row)=>
      i
      |> fun
      | i' when i' != x => row
      | _ => row |> Array.mapi((j,column) =>
        j
        |> fun
        | j' when j' != y => column
        | _ => value
      )
    )
  }
  let max = (a,b) => a > b ? a : b
  let evaluateMatrixCell = 
    ( x: int, y: int
    , isSpecial: bool
    , matrix:ref(array(array(int)))
    ) => {
    isSpecial
    |> fun
    | true => //you are my special
      setMatrix(x, y
      , matrixAt(x-1,y-1,matrix) + 1
      , matrix)
    | false =>
      setMatrix(x, y
      , max(matrixAt(x-1,y,matrix),matrixAt(x,y-1,matrix))
      , matrix)
  }
  let rec retraceLCS = 
    ( x':int, y':int
    , array1:array(string)
    , array2:array(string)
    , lcs:list(string)
    , matrix:ref(array(array(int)))
    ) => {
    (x',y')
    |> fun
    | (x , y) when x < 0 || y < 0 => lcs
    | (x , y) =>
      array1[x] == array2[y]
      |> fun
      | true => //you are my special
        retraceLCS( x-1, y-1
        , array1, array2
        , [array1[x], ...lcs]
        , matrix)
      | false =>
        matrixAt(x-1,y,matrix) > matrixAt(x,y-1,matrix) ?
        retraceLCS( x-1, y
        , array1, array2
        , lcs
        , matrix)
        :
        retraceLCS( x, y-1
        , array1, array2
        , lcs
        , matrix)
  }
  let rec diff = ( input1: list(string), input2: list(string), lcs:list(string)) => {
    (input1,input2,lcs) |> fun
    | ([],[],[]) => []
    | ([f1,...r1],_,[]) => [("-",f1),...diff(r1,input2,[])]
    | (_,[f2,...r2],[]) => [("+",f2),...diff(input1,r2,[])]
    | ([f1,...r1],_,[flcs,..._rlcs]) when f1 != flcs => [("-",f1),...diff(r1,input2,lcs)]
    | (_,[f2,...r2],[flcs,..._rlcs]) when f2 != flcs => [("+",f2),...diff(input1,r2,lcs)]
    | ([_f1,...r1],[_f2,...r2],[flcs,...rlcs]) => [("=",flcs),...diff(r1,r2,rlcs)]
    | (_,_,_) => []

  }
  let compare = (input1:string, input2:string, split:list(char)) => {
    let array1:array(string) = stringDisassembler(input1,split,String.length(input1)-1,"",[]) |> Array.of_list
    let array2:array(string) = stringDisassembler(input2,split,String.length(input2)-1,"",[]) |> Array.of_list
    let scoreMatrix:ref(array(array(int))) = ref( 0 |> Array.make(Array.length(array2)) |> Array.make(Array.length(array1)))
    
    let () = array1
    |> Array.iteri((i,row)=>
      array2
      |> Array.iteri((j,column) =>
        evaluateMatrixCell(i,j,row==column,scoreMatrix)
      )
    )
    let lcs = retraceLCS( Array.length(array1)-1, Array.length(array2)-1
    , array1, array2
    , [], scoreMatrix)


    diff( array1 |> Array.to_list
        , array2 |> Array.to_list
        ,lcs)
  }
}

let () = {
  let split = (Sys.argv |> Array.length) > 3 ? (Diff.stringDisassembler(Sys.argv[3],[],String.length(Sys.argv[3])-1,"",[]) |> List.map(a=>a.[0])) : []
  Diff.compare(Sys.argv[1],Sys.argv[2],split)
  |>List.iter(((d,v))=>(print_endline(d++" "++v)))
}

//ask about the jwt