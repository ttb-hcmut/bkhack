open Eio

let () = Eio_main.run @@ env => {
  let cwd = Stdenv.cwd(env) and clock = Stdenv.clock(env);
  let input1 = Path.load(Path.(cwd / "test" / "input1.txt"));
  let input2 = Path.load(Path.(cwd / "test" / "input2.txt"));
  let input3 = Path.load(Path.(cwd / "test" / "split.txt"));
  let split = String.length(input3)>0? Diff.stringDisassembler(input3,[],String.length(input3)-1,"",[],false) |> List.map(a=>a.[0]):[]
  let nukeDelim = (Sys.argv |> Array.length) > 1
  |> fun
  | true => Sys.argv[1] == "nukeDelim"
  | false => true
  let res = Diff.compare(~clock, input1,input2,split,nukeDelim)|>List.map(((d,v))=>d++"|\t"++v)|>String.concat("\n");
  Path.save(~create=(`Or_truncate(0o700)), Path.(cwd / "test" / "res.txt"), res)
}