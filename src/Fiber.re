type fiber('in_, 'ret) =
	{ fiber_id: int, fiber_run: fiber'('in_, 'ret) }

and fiber'('in_, 'ret) = 'in_ => Js.promise('ret)

and continuation('in_, 'ret) = (
	~tbl:Hashtbl.t(int, (Js.Fn.arity1('ret => unit), Js.Fn.arity1(exn => unit))),
	~idgen:ref(int)
) => fiber'('in_, 'ret)

and ctrl('ret) = 
	{ ctrl_id: int, ctrl_gen: unit =>
		(
			Hashtbl.t(int, (Js.Fn.arity1('ret => unit), Js.Fn.arity1(exn => unit))),
			ref(int)
		)};

let rec of_worker =
	(mkworker: unit => Js__worker.worker(
		Fiber__core.comm('in_, 'ret, [ `requested ]),
		Fiber__core.comm('in_, 'ret, [ `replied ]),
	)) : continuation('in_, 'ret) => {
	(~tbl, ~idgen) => {
		let worker = mkworker() |> onmessage(~tbl) |> onerror;
		worker->submit(~idgen, ~tbl)
	}
}

and submit = (worker, ~idgen, ~tbl) =>
	in_ => {
		let id = idgen^; idgen := id + 1;
		Js.Promise.make @@ (~resolve, ~reject) =>
		{ tbl->Hashtbl.add(id, (resolve, reject));
			Js__worker.Worker.postMessage(worker, Fiber__core.Comm__request(id, in_))
		}
	}

and onmessage = (worker, ~tbl) => { worker->Js__worker.Worker.onmessage(e => {
	open { [@mel.send] external call1 : Js.Fn.arity1('a => 'b) => 'this => 'a => 'b = "call"; };
	let Fiber__core.Comm__reply(_, owner, res) = Js__worker.Message.data(e);
	let (resolve, reject_) = tbl->Hashtbl.find(owner);
	switch (res) {
	| Result.Ok(data) => resolve->call1(Js.null, data)
	| Result.Error(e) => reject_->call1(Js.null, e)
	}
}); worker }

and onerror = worker => { worker->Js__worker.Worker.onerror(e => {
	Js.Console.error2("fiber: uncaught internal tbl error", e)
}); worker };

module Ctrl {
	let idgen = ref(5);

	let create = () : ctrl(_) => {
		let id = idgen^
		and f = () => { let tbl = Hashtbl.create(4) and idgen = ref(0); (tbl, idgen) };
		idgen := id + 1;
		{ ctrl_id: id, ctrl_gen: f }
	}
}

module With_ctrl1 {
	let make = (~ctrl:ctrl('ret), k: continuation('in_, 'ret)) : fiber('in_, 'ret) => {
		let { ctrl_id, ctrl_gen: ctrl } = ctrl;
		let (tbl, idgen) = ctrl();
		{ fiber_id: ctrl_id, fiber_run: k(~tbl, ~idgen) }
	}

	let run_promise = (type in_, type ret, ~ctrl:ctrl(ret), arg:in_, k: fiber(in_, ret)) => {
		let { fiber_id: fiber_group_id, fiber_run: k } = k;
		let { ctrl_id: ctrl_group_id, _ } = ctrl;
		assert(fiber_group_id == ctrl_group_id);
		k(arg)
	}

}

module With_ctrl0 {
	let makef = With_ctrl1.make
	let runf  = With_ctrl1.run_promise
}
