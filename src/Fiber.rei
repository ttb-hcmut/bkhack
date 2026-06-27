type fiber('in_, 'ret) and continuation('in_, 'ret) and ctrl('ret);

let of_worker : 'in_ 'ret. (
	unit => Js__worker.worker(
		Fiber__core.comm('in_, 'ret, [ `requested ]),
		Fiber__core.comm('in_, 'ret, [ `replied ]),
	)
) => continuation('in_, 'ret)

module Ctrl {
	let create : unit => ctrl('ret)
}

module With_ctrl0 {
	let makef : (~ctrl:ctrl('ret), continuation('in_, 'ret)) => fiber('in_, 'ret)
	let runf  : 'in_ 'ret. (~ctrl:ctrl('ret), 'in_, fiber('in_, 'ret)) => Js.promise('ret)
}

module With_ctrl1 {
	let make : (~ctrl:ctrl('ret), continuation('in_, 'ret)) => fiber('in_, 'ret)
	let run_promise : 'in_ 'ret. (~ctrl:ctrl('ret), 'in_, fiber('in_, 'ret)) => Js.promise('ret)
}

// module Cancel {
// 	let propagate : (~ctrl:ctrl('ret), fiber('in_, 'ret)) => Js.promise(unit)
// }
//
// module Syntax {
// 	
// }
