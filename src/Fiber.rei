type fiber('in_, 'ret);

let of_worker : 'in_ 'ret. (
	unit => Js__worker.worker(
		Fiber__core.comm('in_, 'ret, [ `requested ]),
		Fiber__core.comm('in_, 'ret, [ `replied ]),
	)
) => unit => fiber('in_, 'ret)

let fork_promise : 'in_ 'ret. 'in_ => fiber('in_, 'ret) => Js.promise('ret)
