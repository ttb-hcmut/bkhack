module type Comparable {
  type t
  let ( > ) : t => t => bool
}

// let with_duration = (~tag="", ~clock, k) => {
//   let start = Eio.Time.now(clock);
//   let v = k();
//   let stop = Eio.Time.now(clock);
//   Eio.traceln("duration %s: %f", tag, stop -. start);
//   v
// }

module Int {
  include Int
  type t = int
  let (>) = (>)
}

module Number {
  let max = (type t, module Comparable : Comparable with type t = t, a: t, b: t) => Comparable.(>)(a, b) ? a : b
}

type matrix('t) = array(array('t));

/* Imperative matrix */
module Matrix {
  type t('a) = matrix('a)
  and row('t) = array('t) and column('t) = array('t)

  let at = (x, y, matrix:matrix(int)) => {
    (x,y)
    |> fun
    | (x',y') when x'<0 || y'<0 => 0
    | (x',y') => matrix[x'][y']
  }

  // let set = (x:int,y:int,value:int,matrix:ref(matrix(int))) => {
  //   // let temp = matrix^
  //   // temp[x][y] = value
  //   // matrix := temp 
  //   // Array.set(matrix^, x, Array.set((matrix^)[x], y, value))
  //   // Js.log3(x,y,value)
  //   matrix := matrix^ |> Array.mapi((i,row)=>
  //     row |> Array.mapi((j,col)=>
  //       (i,j) |> fun 
  //       | (i',j') when i' == x && j' == y => value
  //       | _ => col
  //     )
  //   )
  //   // Array.set((matrix^)[x], y, value)
  // }
};

let rec stringDisassembler = (input:string,split:list(char),index:int,hold:string,list:list(string),nukeDelim:bool) => {
  (index,input.[index],split) |> fun
  | (0,e,[]) => [String.make(1, e),...list]
  | (_,e,[]) => stringDisassembler(input,split,index-1,"",[String.make(1, e),...list],nukeDelim)
  | (0,e,l) when List.mem(e, l) => if(!nukeDelim) [String.make(1, e),...[hold,...list]] else [hold,...list] 
  | (_,e,l) when List.mem(e, l) => stringDisassembler(input,l,index-1,"",if(!nukeDelim) [String.make(1, e),...[hold,...list]] else [hold,...list],nukeDelim)
  | (0,e,_l) => [String.make(1, e) ++ hold,...list]
  | (_,e,l) => stringDisassembler(input,l,index-1,String.make(1, e) ++ hold,list,nukeDelim)
};

let evaluateMatrix = (array1:array(string),array2:array(string)) => {
  let (_,_,evalMatrix) = array1 |> Array.fold_left(((x:int,prevRow:array(int),matOfRows:list(array(int))),row:string)=>{
    let (_,_,evalRow)  = array2 |> Array.fold_left(((y:int,prevCol:int       ,rowOfCols:list(int)       ),col:string)=>{
      let eval = (row == col,y) |> fun 
      | (true,y') when y' > 0 => //you are my special
        prevRow[y-1] + 1
      | (true,_) => //you are my special
        1
      | (false,_) =>
        prevCol > prevRow[y] ? prevCol : prevRow[y]
      ;
      (y+1,eval,[eval,...rowOfCols])
    },(0,0,[]))
    let evalRow = evalRow |> List.rev |> Array.of_list 
    ;
    (x+1,evalRow,[evalRow,...matOfRows])
  },(0,Array.make(Array.length(array2),0),[]));
  evalMatrix |> List.rev |> Array.of_list
}

// let evaluateMatrixCell = 
//   ( x: int, y: int
//   , isSpecial: bool
//   , matrix:ref(array(array(int)))
//   ) => 
//   if (isSpecial) { //you are my special
//     Matrix.set(x, y
//     , Matrix.at(x-1,y-1,matrix) + 1
    // , matrix)
//   } else {
//     Matrix.set(x, y
//     , Number.max(module Int)(Matrix.at(x-1,y,matrix),Matrix.at(x,y-1,matrix))
//     //  a > b ? a : b
//     , matrix)
//   };

let retraceLCS = 
  ( 
    // x':int, y':int
    array1:array(string)
  , array2:array(string)
  // , lcs:list(string)
  , matrix:matrix(int)
  ) =>
  {
    let x = ref(Array.length(array1)-1)
    and y = ref(Array.length(array2)-1)
    and lcs = ref([]);

    while(x^ >= 0 && y^ >= 0){
      (x^,y^) |> fun
      | (x', y') when array1[x'] == array2[y'] =>
      { x := x'-1 
        y := y'-1 
        lcs := [array1[x'],...(lcs^)]}
      | (x', y') when Matrix.at(x'-1,y',matrix) > Matrix.at(x',y'-1,matrix) =>
      { x := x'-1}
      | (_ , y')=>
      { y := y'-1}
    }
    ;
    lcs^
  // switch (x',y') {
  // | (x , y) when x < 0 || y < 0 => lcs
  // | (x , y) when array1[x] == array2[y] => //you are my special
  //   retraceLCS( x-1, y-1
  //   , array1, array2
  //   , [array1[x], ...lcs]
  //   , matrix)
  // | (x , y ) when Matrix.at(x-1,y,matrix) > Matrix.at(x,y-1,matrix) =>
  //   retraceLCS( x-1, y
  //   , array1, array2
  //   , lcs
  //   , matrix)
  // | (x, y) =>
  //   retraceLCS( x, y-1
  //   , array1, array2
  //   , lcs
  //   , matrix)
  };

let diff = ( input1: array(string), input2: array(string), lcs:list(string)) =>
{
  let i1 = ref(input1 |> Array.to_list)
  let i2 = ref(input2 |> Array.to_list)
  let l  = ref(lcs)
  let d  = ref([])
  while(List.length(i1^) > 0 || List.length(i2^) > 0 || List.length(l^) > 0){
    switch (i1^,i2^,l^) {
    | ([],[],[]) => {()}
    | ([f1,...r1],_,[]) => {
      i1 := r1
      // i2 := 
      // l  :=
      d  := [("-",f1),...(d^)]
    } 
    | (_,[f2,...r2],[]) =>
    {
      // i1 := r1
      i2 := r2
      // l  :=
      d  := [("+",f2),...(d^)]
    }
    | ([f1,...r1],_,[flcs,..._rlcs]) when f1 != flcs =>
    {
      i1 := r1
      // i2 := r2
      // l  :=
      d  := [("-",f1),...(d^)]
    }
    | (_,[f2,...r2],[flcs,..._rlcs]) when f2 != flcs =>
    {
      // i1 := r1
      i2 := r2
      // l  :=
      d  := [("+",f2),...(d^)]
    }
    | ([_f1,...r1],[_f2,...r2],[flcs,...rlcs]) =>
    {
      i1 := r1
      i2 := r2
      l  := rlcs
      d  := [("=",flcs),...(d^)]
    }
    | (_,_,_) => {()}
    }
  }
  ;
  d^ |> List.rev
};

let compare = (input1:string, input2:string, split:list(char), nukeDelim:bool, ~setStatus: option(string=>unit) =?, ()) => {
  setStatus|> fun | None => () | Some(f) => f("Initializing inputs");
  let array1:array(string) = String.length(input1)>0 ? stringDisassembler(input1,split,String.length(input1)-1,"",[],nukeDelim) |> Array.of_list : [||];
  let array2:array(string) = String.length(input2)>0 ? stringDisassembler(input2,split,String.length(input2)-1,"",[],nukeDelim) |> Array.of_list : [||];

  setStatus|> fun | None => () | Some(f) => f("Evaluating differences");
  let evalMatrix = evaluateMatrix(array1,array2)

  setStatus|> fun | None => () | Some(f) => f("Creating LCS");
  let lcs = retraceLCS(
    array1, array2
    , evalMatrix);
  // Js.log(lcs|> Array.of_list)

  setStatus|> fun | None => () | Some(f) => f("Creating diff list");
  diff( array1
      , array2
      , lcs)
};

let compare' = (input1:string, input2:string, split:list(char), nukeDelim:bool, ~setStatus: option(string=>unit) =?, ()) => {
  setStatus|> fun | None => () | Some(f) => f("Initializing inputs");
  let array1:array(string) = String.length(input1)>0 ? stringDisassembler(input1,split,String.length(input1)-1,"",[],nukeDelim) |> Array.of_list : [||];
  let array2:array(string) = String.length(input2)>0 ? stringDisassembler(input2,split,String.length(input2)-1,"",[],nukeDelim) |> Array.of_list : [||];

  setStatus|> fun | None => () | Some(f) => f("Evaluating differences");
  let evalMatrix = evaluateMatrix(array1,array2)

  setStatus|> fun | None => () | Some(f) => f("Creating LCS");
  let lcs = retraceLCS(
    array1, array2
    , evalMatrix);
  // Js.log(lcs|> Array.of_list)

  setStatus|> fun | None => () | Some(f) => f("Creating diff list");
  let res = diff( array1 , array2 , lcs);
	(res, `tokens(array1))
};
