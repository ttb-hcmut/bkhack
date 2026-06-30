type fiber('in_, 'ret, 'yield, 'yieldback) =
	{ fiber_id: int, fiber_run: fiber'('in_, 'ret, 'yield, 'yieldback) }

and fiber'('in_, 'ret, 'yield, 'yieldback) = 'in_ => Js.promise('ret)

and continuation('in_, 'ret, 'yield, 'yieldback) = (
	~tbl:Hashtbl.t(int, ('ret => unit, int => 'yield => unit, exn => unit)),
	~idgen:ref(int),
	~handletbl:Hashtbl.t(int, 'yield => Js.promise('yieldback))
) => fiber'('in_, 'ret, 'yield, 'yieldback)

and ctrl('ret, 'yield, 'yieldback) = 
	{ ctrl_id: int, ctrl_gen: unit =>
		(
			Hashtbl.t(int, ('ret => unit, int => 'yield => unit, exn => unit)),
			ref(int)
		),
		ctrl_lambda_data: 
			( Hashtbl.t(int, 'yield => Js.promise('yieldback)),
				ref(int))
	};

module Js__worker {
	include Js__worker
	module Fiber {
		type request('in_, 'ret, 'yield, 'yieldback) = Either.t(
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `requested ]),
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `set ])
		)
		and  reply('in_, 'ret, 'yield, 'yieldback)   = Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `replied ])
	}
}

let rec of_worker = (mkworker: unit => Js__worker.worker(Js__worker.Fiber.request('in_, 'ret, 'yield, 'yieldback), Js__worker.Fiber.reply('in_, 'ret, 'yield, 'yieldback))) : continuation('in_, 'ret, 'yield, 'yieldback) => {
	(~tbl, ~idgen, ~handletbl) => {
		let worker = mkworker() |> onmessage(~tbl) |> onerror;
		worker->submit(~idgen, ~tbl, ~handletbl)
	}
}

and submit = (worker, ~idgen, ~tbl, ~handletbl) => {
	in_ => {
		open { [@mel.send] external call1 : Js.Fn.arity1('a => 'b) => 'this => 'a => 'b = "call"; };
		let workid = idgen^;
		idgen := idgen^ + 1;
		Js.Promise.make @@ (~resolve, ~reject) => {
			let resolve = data => resolve->call1(Js.null, data)
			and reflect = (id: int, x: 'yield) => {
				ignore(Fetch__syntax.({
					let handle = Hashtbl.find(handletbl, id);
					let* u = handle(x)
					Js__worker.Worker.postMessage(worker, Either.Right(Fiber__core.Comm__set(id, u)));
					return()
				}>!= (e => { Js.Console.error(e); return() })) );
			}
			and reject  = e => reject->call1(Js.null, e);
			tbl->Hashtbl.add(workid, (resolve, reflect, reject));
			Js__worker.Worker.postMessage(worker, Either.Left(Fiber__core.Comm__request(workid, in_)))
		}
	}
}

and onmessage = (worker, ~tbl) => { worker->Js__worker.Worker.onmessage(e => {
	let Fiber__core.Comm__reply(_, owner, res) = Js__worker.Message.data(e);
	let (resolve, reflect, reject_) = tbl->Hashtbl.find(owner);
	switch (res) {
	| Result.Ok(Fiber__core.Rep_ly(data)) =>
		tbl->Hashtbl.remove(owner);
		resolve(data)
	| Result.Ok(Fiber__core.Rep_(id, x)) =>
		reflect(id, x)
	| Result.Error(e) =>
		tbl->Hashtbl.remove(owner);
		reject_(e)
	}
}); worker }

and onerror = worker => { worker->Js__worker.Worker.onerror(e => {
	Js.Console.error2("fiber: uncaught internal tbl error", e)
}); worker };

module Ctrl {
	let idgen = ref(5);

	let create = () : ctrl(_) => {
		let id = idgen^
		and handletbl = Hashtbl.create(1) and yieldgen = ref(0)
		and f = () => {
			let tbl = Hashtbl.create(4) and idgen = ref(0);
			(tbl, idgen)
		};
		idgen := id + 1;
		{ ctrl_id: id, ctrl_gen: f, ctrl_lambda_data: (handletbl, yieldgen) }
	}
}

module With_ctrl1 {
	let make = (~ctrl:ctrl('ret, 'yield, 'yieldback), k: continuation('in_, 'ret, 'yield, 'yieldback)) : fiber('in_, 'ret, 'yield, 'yieldback) => {
		let { ctrl_id, ctrl_gen: ctrl, ctrl_lambda_data: (handletbl, _) } = ctrl;
		let (tbl, idgen) = ctrl();
		{ fiber_id: ctrl_id, fiber_run: k(~tbl, ~idgen, ~handletbl) }
	}

	let run_promise = (type in_, type ret, type yield, type yieldback, ~ctrl:ctrl(ret, yield, yieldback), arg, k:fiber(in_, ret, yield, yieldback)) => {
		let { fiber_id: fiber_group_id, fiber_run: k } = k;
		let { ctrl_id: ctrl_group_id, _ } = ctrl;
		assert(fiber_group_id == ctrl_group_id);
		k(arg)
	}

	let run_promise2 = (~ctrl, arg1, arg2, k) => run_promise(~ctrl, (arg1, arg2), k)

	let run_promise3 = (~ctrl, arg1, arg2, arg3, k) => run_promise(~ctrl, (arg1, arg2, arg3), k)

}

module With_ctrl0 {
	let makef = With_ctrl1.make
	and runf  = With_ctrl1.run_promise
}

let lam' = (type ret, type a, type b, ctrl:ctrl(ret, a, b), f: a => Js.promise(b)): Fiber__core.lambda(a, b) => {
	let { ctrl_lambda_data: (handletbl, yieldgen), _ } = ctrl;
	let await_id = yieldgen^;
	yieldgen := yieldgen^ + 1;
	Hashtbl.add(handletbl, await_id, f);
	Fiber__core.Lambda({ await_id: await_id })
}

let lam = (type ret, type a, type b, ctrl:ctrl(ret, a, b), f: a => b): Fiber__core.lambda(a, b) => {
	lam'(ctrl, Fetch__syntax.({ a => return@@f(a)}))
}

