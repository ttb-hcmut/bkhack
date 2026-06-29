
let%Fiber.bind p' = ((), (count)) => {
  let input = String.make(count, ' ');
  let _ = Diff.compare(input,input,[' '],false);
  0
}
let%Fiber.bind q' = ((), (count)) => {
  let input = String.make(count, ' ');
  let _ = Diff.compareSplitByRe(~input1=input, ~input2=input, ~split=[%re {|/(?:.)/gm|}]);
  0
}

module Timer = {
  [@react.component]
  let make = () => {
    let (interval, setInterval) = React.useState(() => 0)
    // let (count,setCount) = React.useState(()=>0);
		let ctrl = React.useMemo0(Fiber.Ctrl.create)
		let n = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, p'));
		let m = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, q'));
    // let balls = ;
    let run' = k => {
      ignore(Fetch__syntax.({
				let* u = Fiber.With_ctrl1.run_promise(~ctrl, `apply0(interval), k);
        // u ;
				if (false) { ignore(u+1) };
				Js.Console.log(u);
				return(())
			}>!= (e => { Js.Console.error(e); return(()) })));
    }
    ;
    let run = () => {
      run'(n); run'(m);
    }; 
    <div> 
      <input onChange={e => setInterval(_ => React.Event.Form.target(e)##value |> fun | v when String.length(v) == 0 => 0 | v => {v |> int_of_string})}/>
      <button onClick={_=>run()}>{React.string("Start Timer")}</button>
      // <button onClick={_=>Js.log(count^)}>{React.string("query")}</button>
      // <label> {React.int(count^)} </label>  
    </div>
  } 
}
