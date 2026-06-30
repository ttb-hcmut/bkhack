
[@in_: (_, int)] [@ret: int]
let%Fiber.bind p' = ((), (setResult, count)) => Fetch__syntax.({
  let input = String.make(count, ' ');
	let i = ref(0);
	while (true) {
		if (i^ mod 1000000 == 0) {
			ignore @@ Lam.app(i^ / 1000000, setResult);
		}
		i := i^ + 1;
	}
  let _ = Diff.compare(input,input,[' '],false);
  return(0)
});

[@in_: (_, int)] [@ret: int]
let%Fiber.bind q' = ((), (_setResult, count)) => Fetch__syntax.({
  let input = String.make(count, ' ');
  let _ = Diff.compareSplitByRe(~input1=input, ~input2=input, ~split=[%re {|/(?:.)/gm|}]);
  return(0)
});

module Timer = {
  [@react.component]
  let make = () => {
    let (interval, setInterval) = React.useState(() => 0)
		let (result, setResult) = React.useState(() => 0)
    // let (count,setCount) = React.useState(()=>0);
		let ctrl = React.useMemo0(Fiber.Ctrl.create)
		let n = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, p'));
		let m = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, q'));
    // let balls = ;
    let run' = k => {
      ignore(Fetch__syntax.({
				let f = i => setResult(_ => i);
				let* u = Fiber.With_ctrl1.run_promise2(~ctrl,
					ctrl->Fiber.lam(f), interval, k);
				Js.Console.log(u);
				return(())
			}>!= (e => { Js.Console.error(e); return(()) })));
    }
    ;
    let run = () => {
      run'(n); run'(m);
    }; 
    <div> 
			<div>result->React.int</div>
      <input onChange={e => setInterval(_ => React.Event.Form.target(e)##value |> fun | v when String.length(v) == 0 => 0 | v => {v |> int_of_string})}/>
      <button onClick={_=>run()}>{React.string("Start Timer")}</button>
      // <button onClick={_=>Js.log(count^)}>{React.string("query")}</button>
      // <label> {React.int(count^)} </label>  
    </div>
  } 
}
