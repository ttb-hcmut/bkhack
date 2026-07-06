type fiber('in_, 'ret, 'yield, 'yieldback) =
	{ fiber_id: int, fiber_run: fiber'('in_, 'ret, 'yield, 'yieldback), fiber_cancel: unit => unit }

and fiber'('in_, 'ret, 'yield, 'yieldback) = 'in_ => Js.promise('ret)

and fibercancel = unit => unit

and continuation('in_, 'ret, 'yield, 'yieldback) = (
	~tbl:Hashtbl.t(int, ('ret => unit, int => int => 'yield => unit, exn => unit)),
	~idgen:ref(int),
	~handletbl:Hashtbl.t(int, 'yield => Js.promise('yieldback))
) => (fibercancel, fiber'('in_, 'ret, 'yield, 'yieldback))

and ctrl('ret, 'yield, 'yieldback) = 
	{ ctrl_id: int, ctrl_gen: unit =>
		(
			Hashtbl.t(int, ('ret => unit, int => int => 'yield => unit, exn => unit)),
			ref(int)
		),
		ctrl_lambda_data: 
			( Hashtbl.t(int, 'yield => Js.promise('yieldback)),
				ref(int))
	};

exception Cancelled

open { [@mel.send] external call1 : Js.Fn.arity1('a => 'b) => 'this => 'a => 'b = "call"; };

module Js__worker {
	include Js__worker
	module Fiber {
		type worker('in_, 'ret, 'yield, 'yieldback) = Js__worker.worker(request('in_, 'ret, 'yield, 'yieldback), reply('in_, 'ret, 'yield, 'yieldback))
		and request('in_, 'ret, 'yield, 'yieldback) = Either.t(
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `requested ]),
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `set ])
		)
		and  reply('in_, 'ret, 'yield, 'yieldback)  = Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `replied ])
	}
}

let ignore_task = p => {
	ignore(p |> Js.Promise.then_(() => Js.Promise.resolve()))
}

let rec of_worker = (mkworker: unit => Js__worker.Fiber.worker('in_, 'ret, 'yield, 'yieldback)) : continuation('in_, 'ret, 'yield, 'yieldback) => {
	(~tbl) => {
		let worker = mkworker() |> onmessage(~tbl) |> onerror;
		let cancel = worker->cancel(~tbl);
		(~idgen, ~handletbl) => {
			let f = worker->submit(~idgen, ~tbl, ~handletbl);
			(cancel, f)
		}
	}
}

and submit = (worker, ~idgen, ~tbl, ~handletbl) => {
	in_ => {
		let workid = idgen^;
		idgen := idgen^ + 1;
		Js.Promise.make @@ (~resolve, ~reject) => {
			let resolve = data => resolve->call1(Js.null, data)
			and reflect = (async_id: int, await_id: int, x: 'yield) =>
				ignore_task(Fetch__syntax.({
				let handle = Hashtbl.find(handletbl, async_id);
				let* u = handle(x)
				Js__worker.Worker.postMessage(worker, Either.Right(Fiber__core.Comm__set(await_id, u)));
				return()
			} >!= e => {
				Js.Console.error(e);
				return()
			}))
			and reject  = e => reject->call1(Js.null, e);
			tbl->Hashtbl.add(workid, (resolve, reflect, reject));
			Js__worker.Worker.postMessage(worker, Either.Left(Fiber__core.Comm__request(workid, in_)))
		}
	}
}

and cancel = (worker, ~tbl, ()) => {
	Js__worker.Worker.terminate(worker);
	tbl->Hashtbl.to_seq |> List.of_seq |> List.iter(((owner, v)) => {
		let (_resolve, _reflect, reject_) = v;
		reject_(Cancelled);
		tbl->Hashtbl.remove(owner)
	});
}

and onmessage = (worker, ~tbl) => { worker->Js__worker.Worker.onmessage(e => {
	let Fiber__core.Comm__reply(_, owner, res) = Js__worker.Message.data(e);
	let (resolve, reflect, reject_) = tbl->Hashtbl.find(owner);
	switch (res) {
	| Result.Ok(Fiber__core.Rep_ly(data)) =>
		tbl->Hashtbl.remove(owner);
		resolve(data)
	| Result.Ok(Fiber__core.Rep_({ async_id, await_id, app: x })) =>
		reflect(async_id, await_id, x)
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
		let (cancel, f) = k(~tbl, ~idgen, ~handletbl);
		{ fiber_id: ctrl_id, fiber_run: f, fiber_cancel: cancel }
	}

	let run_promise = (type in_, type ret, type yield, type yieldback, ~ctrl:ctrl(ret, yield, yieldback), arg, k:fiber(in_, ret, yield, yieldback)) => {
		let { fiber_id: fiber_group_id, fiber_run: k, _ } = k;
		let { ctrl_id: ctrl_group_id, _ } = ctrl;
		assert(fiber_group_id == ctrl_group_id);
		k(arg)
	}

	let run_promise2 = (~ctrl, arg1, arg2, k) => run_promise(~ctrl, (arg1, arg2), k)

	and run_promise3 = (~ctrl, arg1, arg2, arg3, k) => run_promise(~ctrl, (arg1, arg2, arg3), k)

	and run_promise4 = (~ctrl, arg1, arg2, arg3, arg4, k) => run_promise(~ctrl, (arg1, arg2, arg3, arg4), k)

	and run_promise5 = (~ctrl, arg1, arg2, arg3, arg4, arg5, k) => run_promise(~ctrl, (arg1, arg2, arg3, arg4, arg5), k)

	module Cancel {
		let force = (type in_, type ret, type yield, type yieldback, ~ctrl:ctrl(ret, yield, yieldback), k:fiber(in_, ret, yield, yieldback)) => {
			let { fiber_id: fiber_group_id, fiber_cancel: cancel, _ } = k;
			let { ctrl_id: ctrl_group_id, _ } = ctrl;
			assert(fiber_group_id == ctrl_group_id);
			cancel()
		}
	}
}

module With_ctrl0 {
	let makef = With_ctrl1.make
	and runf  = With_ctrl1.run_promise
}

let lam' = (type ret, type a, type b, ctrl:ctrl(ret, a, b), f: a => Js.promise(b)): Fiber__core.lambda(a, b) => {
	let { ctrl_lambda_data: (handletbl, yieldgen), _ } = ctrl;
	let async_id = yieldgen^;
	yieldgen := yieldgen^ + 1;
	Hashtbl.add(handletbl, async_id, f);
	Fiber__core.Lambda({ async_id: async_id })
}

let lam = (type ret, type a, type b, ctrl:ctrl(ret, a, b), f: a => b): Fiber__core.lambda(a, b) => {
	lam'(ctrl, Fetch__syntax.({ a => return@@f(a)}))
}

