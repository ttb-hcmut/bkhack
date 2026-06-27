
let%Fiber.bind p' = ((), (interval)) => {
  let input = String.make(interval, ' ');
	// open Fiber.Syntax;
  // let count = ref(0);
  // let lastSet = ref(0);
  Diff.compare(input,input,[' '],false,~setStatus = _ => (),())
}

module Timer = {
  [@react.component]
  let make = () => {
    let (interval,setInterval) = React.useState(() => 0)
    // let (count,setCount) = React.useState(()=>0);
		let ctrl = React.useMemo0(Fiber.Ctrl.create)
		let k = React.useMemo0(() => Fiber.With_ctrl1.make(~ctrl, p'));
    // let balls = ;
    let run = () => {  
      ignore(Fetch__syntax.({
				let* u = Fiber.With_ctrl1.run_promise(~ctrl, (interval), k);
        // u ;
				if (false) { ignore([("",""),...u]) };
				Js.Console.log(u|>Array.of_list);
				return(())
			}>!= (e => { Js.Console.error(e); return(()) })));
    }
    ;  
    <div> 
      <input onChange={e => setInterval(_ => React.Event.Form.target(e)##value |> fun | v when String.length(v) == 0 => 0 | v => {v |> int_of_string})}/>
      <button onClick={_=>run()}>{React.string("Start  Timer")}</button>
      // <button onClick={_=>Js.log(count^)}>{React.string("query")}</button>
      // <label> {React.int(count^)} </label>  
    </div>
  } 
}
