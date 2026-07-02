open Melange__containers.Fun

[@in_: (_, int)] [@ret: int]
let%Fiber.bind p' = (~ctrl, (setResult, count)) => Fiber__world.({
  let input = String.make(count, ' ');
	let i = ref(0);
	while (true) {
		if (i^ mod 1000000 == 0) {
			ignore @@ ctrl->Lam.app(i^ / 1000000, setResult);
		}
		i := i^ + 1;
	}
  let _ = Diff.compare(input,input,[' '],false);
  return(0)
});

[@in_: (_, int)] [@ret: int]
let%Fiber.bind q' = (~ctrl as _, (_setResult, count)) => Fiber__world.({
  let input = String.make(count, ' ');
  let _ = Diff.compareSplitByRe(~input1=input, ~input2=input, ~split=[%re {|/(?:.)/gm|}]);
  return(0)
});

class cancel('ret, 'yield, 'yieldback) {
	val tbl = Hashtbl.create(1);
	val idgen = ref(0);
	pri clone = Hashtbl.to_seq %> List.of_seq;
	pub lation_register = k => {
		let id = idgen^;
		idgen := idgen^ + 1;
		tbl->Hashtbl.add(id, k);
	};
	pub all_and_clear = (~ctrl: Fiber.ctrl('ret, 'yield, 'yieldback)) => {
		tbl |> this#clone |> List.iter(((k, f)) => {
			f(~ctrl); tbl->Hashtbl.remove(k)
		})
	}
}

module Timer = {
  [@react.component]
  let make = () => {
    let (interval, setInterval) = React.useState(() => 0)
		let (count, setCount) = React.useState(()=>0);
		let ctrl = React.useMemo0(Fiber.Ctrl.create)
		let cancel = React.useMemo0(() => new cancel);
    let run' = k => Fetch__syntax.({
			let k = Fiber.With_ctrl1.make(~ctrl, k);
			cancel#lation_register((~ctrl) => Fiber.With_ctrl1.Cancel.force(~ctrl, k));
			let* u = Fiber.(With_ctrl1.run_promise2(~ctrl,
				ctrl->lam(i => setCount(_ => i)), interval, k));
			Js.Console.log2("result", u);
			return(())
		} >!= (e => { Js.Console.error(e); return(()) }));
    let run = () => {
      ignore@@run'(p');
			ignore@@run'(q');
    }; 
    <div> 
			<div>count->React.int</div>
      <input onChange={e => setInterval(_ => React.Event.Form.target(e)##value |> fun | v when String.length(v) == 0 => 0 | v => {v |> int_of_string})}/>
      <button onClick={_=>run()}>{React.string("Start Timer")}</button>
      <button onClick={_=>cancel#all_and_clear(~ctrl)}>{React.string("Cancel")}</button>
      // <button onClick={_=>Js.log(count^)}>{React.string("query")}</button>
      // <label> {React.int(count^)} </label>  
    </div>
  } 
}
