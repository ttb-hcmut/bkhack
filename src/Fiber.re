type fiber('in_, 'ret) = 'in_ => Js.promise('ret);

let rec of_worker =
	(mkworker: unit => Js__worker.worker(
		Fiber__core.comm('in_, 'ret, [ `requested ]),
		Fiber__core.comm('in_, 'ret, [ `replied ]),
	)) => {
	() : fiber('in_, 'ret) =>
	{ let tbl = Hashtbl.create(4) and idgen = ref(5)
		let worker = mkworker() |> onmessage(~tbl) |> onerror;
		worker->submit(~idgen, ~tbl) }
}

and submit = (worker, ~idgen, ~tbl, in_) => {
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

let fork_promise = (type in_, type ret, arg:'in_, k: fiber('in_, 'ret)) => {
	k(arg)
}
