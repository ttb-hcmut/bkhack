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

let rec stringDisassembler = (input:string,split:list(char),index:int,hold:string,list:list(string),nukeDelim:bool) => 
{
  (index,input.[index],split) |> fun
  | (0,e,[]) => [String.make(1, e),...list]
  | (_,e,[]) => stringDisassembler(input,split,index-1,"",[String.make(1, e),...list],nukeDelim)
  | (0,e,l) when List.mem(e, l) => if(!nukeDelim) [String.make(1, e),...[hold,...list]] else [hold,...list] 
  | (_,e,l) when List.mem(e, l) => stringDisassembler(input,l,index-1,"",if(!nukeDelim) [String.make(1, e),...[hold,...list]] else [hold,...list],nukeDelim)
  | (0,e,_l) => [String.make(1, e) ++ hold,...list]
  | (_,e,l) => stringDisassembler(input,l,index-1,String.make(1, e) ++ hold,list,nukeDelim)
};
// let stringDisassembler2 = (~input:string, ~split:Js.Re.t ,~nukeDelim:bool): array(string) => {
//   let l = ref(0)
//   and r = ref(1)
//   and length = String.length(input)
//   let res = [];
//   while (r^ < length && r^>l^) {
//     r := split |> Array.fold_left(
//       (acc, ele) => {
//         Js.String.indexOf(~search=ele,~start=l^) != -1 ? item : result
//       },-1);
//       input |> Js.String.indexOf(~search="a",~start=l^)
//   };
// }



let evaluateMatrix = (array1:array(string),array2:array(string)) => 
{
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

let evaluateMatrix2 = (array1:array(string),array2:array(string)) => 
{
  let l1 = Array.length(array1)
  and l2 = Array.length(array2);
  let mat = Array.make(l1*l2, 0 )
  // mat[0] = score of the cell
  // mat[1] = where lcs should jump to next
  and i  = ref(0);

  let at = (dx:int , dy: int, j: int, arr: array(int)) => {
    ((j / l2) + dx, (j mod l2) + dy) |> fun 
    | (a',b') when a' >= 0 && b' >= 0 => arr[a'*l2+b'] 
    | _ => 0
  }
  
  let max = (a: int, b: int) => {
    a > b ? a : b
  }
  
  while( i^ < l1*l2)
  {
    array1[i^ / l2] == array2[i^ mod l2] |> fun
    | true  => mat[i^] = (mat |> at(-1,-1,i^)) + 1
    | false => mat[i^] = max(mat|>at(-1,0,i^), mat|>at(0,-1,i^))
    ;
    i := i^ + 1;
  }
  mat
  // let (_,_,evalMatrix) = array1 |> Array.fold_left(((x:int,prevRow:array(int),matOfRows:list(array(int))),row:string)=>{
  //   let (_,_,evalRow)  = array2 |> Array.fold_left(((y:int,prevCol:int       ,rowOfCols:array(int)       ),col:string)=>{
  //     let eval = (row == col,y) |> fun 
  //     | (true,y') when y' > 0 => //you are my special
  //       prevRow[y-1] + 1
  //     | (true,_) => //you are my special
  //       1
  //     | (false,_) =>
  //       prevCol > prevRow[y] ? prevCol : prevRow[y]
  //     ;
  //     rowOfCols[y] = eval
  //     ;
  //     (y+1,eval,rowOfCols)
  //   },(0,0,Array.make(l2,0)))
  //   let evalRow = evalRow
  //   ;
  //   (x+1,evalRow,[evalRow,...matOfRows])
  // },(0,Array.make(l2,0),Array.make(l2,0)));
  // evalMatrix |> Array.of_list
}


let evaluateMatrix3 = (arrayA:array(string),arrayB:array(string)) => 
{
  let la = Array.length(arrayA)
  and lb = Array.length(arrayB);
  let mat = Array.make(Js.Math.ceil_int(float_of_int(la * lb)/. 32.), 0x00000000)
  let searchFrontEven = Array.make(lb, 0)
  let searchFrontOdd  = Array.make(lb, 0)
  and i  = ref(0);

  
  let searchFrontAt = (dx:int, dy:int, j:int) => {
    ((j/lb + dx) mod 2 , (j mod lb) + dy) |> fun 
    | (0, a) when a >= 0 => searchFrontEven[a] 
    | (1, a) when a >= 0 => searchFrontOdd[a] 
    | _ => 0
  }
  let setSearchFront = (j:int, v:int) => {
    ((j/lb) mod 2) |> fun 
    | 0 => searchFrontEven[j mod lb] = v 
    | 1 => searchFrontOdd[j mod lb] = v
    | _ => ()
  }
  let setMat = (j:int, v:bool) => {
    if(v) {
      mat[j / 32] = mat[j / 32] lor (0x00000001 lsl (j mod 32))
    }
  }
  while( i^ < la*lb)
  {
    arrayA[i^ / lb] == arrayB[i^ mod lb] |> fun
    | true  => { // you are my special
      setSearchFront( i^ , searchFrontAt(-1,-1,i^) + 1);
    }
    | false => {
      setMat( i^
        , searchFrontAt(-1,0, i^ ) > searchFrontAt(0,-1, i^ ));
      setSearchFront( i^
        , searchFrontAt(-1,0, i^ ) > searchFrontAt(0,-1, i^ ) 
        ? searchFrontAt(-1,0, i^ ) : searchFrontAt(0,-1, i^ ));
    }
    ;
    i := i^ + 1;
  }
  mat
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
let retraceLCS2 = (array1:array(string), array2:array(string), matrix:array(int) ) =>
{
  let mlen = Array.length(matrix)
  let l2 = Array.length(array2)
  let i = ref(mlen - 1)
  and lcs = ref([])

  
  let at = (dx:int , dy: int, j: int, arr: array(int)) => {
    ((j / l2) + dx, (j mod l2) + dy) |> fun 
    | (a',b') when a' >= 0 && b' >= 0 => arr[a'*l2+b'] 
    | _ => 0
  }
  while(i^ >= 0){
    (i^ / l2 , i^ mod l2) |> fun
    | (x', y') when array1[x'] == array2[y'] =>
    { i := i^ - l2 - 1
      lcs := [array1[x'],...(lcs^)]}
    | (x', y') when (matrix|>at(x' -1,y',0)) > (matrix|>at(x',y' -1,0)) =>
    { i := i^ - l2}
    | _=>
    { i := i^ - 1}
  }
  ;
  lcs^
};

let retraceLCS3 = (arrayA:array(string), arrayB:array(string), matrix:array(int) ) =>
{
  let la = Array.length(arrayA)
  and lb = Array.length(arrayB);
  let i = ref((la * lb) - 1)
  and lcs = ref([])

  
  let matAt = (j: int) => {
    (matrix[j / 32] land (0x00000001 lsl (j mod 32))) != 0
  }
  while(i^ >= 0){
    (i^ / lb , i^ mod lb) |> fun
    | (x', y') when arrayA[x'] == arrayB[y'] =>
    { i := i^ - lb - 1
      lcs := [arrayA[x'],...(lcs^)]}
    | _ when matAt(i^) =>
    { i := i^ - lb}
    | _=>
    { i := i^ - 1}
  }
  ;
  lcs^
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

let compare' = (input1:string, input2:string, split:list(char), nukeDelim:bool) => {
  let start = Js.Date.now();
  let array1:array(string) = String.length(input1)>0 ? stringDisassembler(input1,split,String.length(input1)-1,"",[],nukeDelim) |> Array.of_list : [||];
  let array2:array(string) = String.length(input2)>0 ? stringDisassembler(input2,split,String.length(input2)-1,"",[],nukeDelim) |> Array.of_list : [||];
  
  let afterInput = Js.Date.now();
  // setStatus|> fun | None => () | Some(f) => f("Evaluating differences");
  let evalMatrix = evaluateMatrix(array1,array2)

  let afterEval = Js.Date.now();
  let lcs = retraceLCS(
    array1, array2
    , evalMatrix);
  // Js.log(lcs|> Array.of_list)

  let afterLCS = Js.Date.now();
  let diffList = diff( array1
      , array2
      , lcs)

  let afterDiffList = Js.Date.now();
  Js.logMany([|
    "Logging Diff1 performance of element count " ++ string_of_int(String.length(input1)) ++ " " ++ string_of_int(String.length(input2))
  , "\n========================"
  , "\nInput disassembly: " ++ string_of_float(afterInput -. start)
  , "\nMatrix eval: " ++ string_of_float(afterEval -. afterInput)
  , "\nLCS retrace: " ++ string_of_float(afterLCS -. afterEval)
  , "\nDiff listing: " ++ string_of_float(afterDiffList -. afterLCS)
  , "\n------------------------"
  , "\nTotal: " ++ string_of_float(afterDiffList -. start)
  |]);
  (diffList, `tokens(array1))
};

let compare = (input1, input2, split, nukeDelim) => {
	let (res, _) = compare'(input1, input2, split, nukeDelim);
	res
}

let compareSplitByRe = (~setStatus=?, ~input1:string, ~input2:string, ~split:Js.Re.t,()) => {
  setStatus |> Option.iter(l => l(_ => "Initializing inputs..."));
  let start = Js.Date.now();
  let array1:array(string) = Js.String.match(~regexp=split,input1) |> Option.value(~default= [||]) |> Array.map(x => x |> Option.value(~default="balls"));
  let array2:array(string) = Js.String.match(~regexp=split,input2) |> Option.value(~default= [||]) |> Array.map(x => x |> Option.value(~default="balls"));
  
  setStatus |> Option.iter(l => l(_ => "Evaluating matrix..."));
  let afterInput = Js.Date.now();
  let evalMatrix = evaluateMatrix2(array1,array2)

  setStatus |> Option.iter(l => l(_ => "Retracing LCS..."));
  let afterEval = Js.Date.now();
  let lcs = retraceLCS2(
    array1, array2
    , evalMatrix);
  // Js.log(lcs|> Array.of_list)

  setStatus |> Option.iter(l => l(_ => "Diffing..."));
  let afterLCS = Js.Date.now();
  let diffList = diff( array1
      , array2
      , lcs)

  let afterDiffList = Js.Date.now();
  
  setStatus |> Option.iter(l => l(_ => "Finished (" ++ string_of_float(afterDiffList -. start) ++ "ms)"));
  Js.logMany([|
    "Logging Diff2 performance of element count " ++ string_of_int(String.length(input1)) ++ " " ++ string_of_int(String.length(input2))
  , "\n========================"
  , "\nInput disassembly: " ++ string_of_float(afterInput -. start)
  , "\nMatrix eval: " ++ string_of_float(afterEval -. afterInput)
  , "\nLCS retrace: " ++ string_of_float(afterLCS -. afterEval)
  , "\nDiff listing: " ++ string_of_float(afterDiffList -. afterLCS)
  , "\n------------------------"
  , "\nTotal: " ++ string_of_float(afterDiffList -. start)
  |])
  diffList
};

let compareBitOp = (~setStatus=?, ~input1:string, ~input2:string, ~split:Js.Re.t,()) => {
  setStatus |> Option.iter(l => l(_ => "Initializing inputs..."));
  let start = Js.Date.now();
  let array1:array(string) = Js.String.match(~regexp=split,input1) |> Option.value(~default= [||]) |> Array.map(x => x |> Option.value(~default="balls"))
  and array2:array(string) = Js.String.match(~regexp=split,input2) |> Option.value(~default= [||]) |> Array.map(x => x |> Option.value(~default="balls"));
  
  let l1 = Array.length(array1)
  and l2 = Array.length(array2);

  setStatus |> Option.iter(l => l(_ => "Evaluating matrix..."));
  let afterInput = Js.Date.now();
  let evalMatrix = l1 > l2 ? evaluateMatrix3(array1,array2) : evaluateMatrix3(array2,array1)

  setStatus |> Option.iter(l => l(_ => "Retracing LCS..."));
  let afterEval = Js.Date.now();
  let lcs = l1 > l2 ? retraceLCS3(array1, array2, evalMatrix) : retraceLCS3(array2, array1, evalMatrix);
  // Js.log(lcs|> Array.of_list)

  setStatus |> Option.iter(l => l(_ => "Diffing..."));
  let afterLCS = Js.Date.now();
  let diffList = diff( array1
      , array2
      , lcs)

  let afterDiffList = Js.Date.now();
  
  setStatus |> Option.iter(l => l(_ => "Finished (" ++ string_of_float(afterDiffList -. start) ++ "ms)"));
  Js.logMany([|
    "Logging Diff3 performance of element count " ++ string_of_int(String.length(input1)) ++ " " ++ string_of_int(String.length(input2))
  , "\n========================"
  , "\nInput disassembly: " ++ string_of_float(afterInput -. start)
  , "\nMatrix eval: " ++ string_of_float(afterEval -. afterInput)
  , "\nLCS retrace: " ++ string_of_float(afterLCS -. afterEval)
  , "\nDiff listing: " ++ string_of_float(afterDiffList -. afterLCS)
  , "\n------------------------"
  , "\nTotal: " ++ string_of_float(afterDiffList -. start)
  |])
  diffList
};
