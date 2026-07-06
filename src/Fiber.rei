/**

{1 Introduction}

Fiber is

 */

/**
	[fiber] is

	@see </devbook/fiber.pdf> the fiber paper for conceptual overview
 */
type fiber('in_, 'ret, 'yield, 'yieldback)

and continuation('in_, 'ret, 'yield, 'yieldback)

and ctrl('ret, 'yield, 'yieldback);

let of_worker : 'in_ 'ret 'yield 'yieldback. (
	unit => Js__worker.worker(
		Either.t(
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `requested ]),
			Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `set ])
		),
		Fiber__core.comm('in_, 'ret, 'yield, 'yieldback, [ `replied ]),
	)
) => continuation('in_, 'ret, 'yield, 'yieldback)

exception Cancelled

module Ctrl {
	let create : unit => ctrl('ret, 'yield, 'yieldback)
}

module With_ctrl0 {
	let makef : (~ctrl:ctrl('ret, 'yield, 'yieldback), continuation('in_, 'ret, 'yield, 'yieldback)) => fiber('in_, 'ret, 'yield, 'yieldback)
	let runf  : 'in_ 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_, fiber('in_, 'ret, 'yield, 'yieldback)) => Js.promise('ret)
}

module With_ctrl1 {
	let make : (~ctrl:ctrl('ret, 'yield, 'yieldback), continuation('in_, 'ret, 'yield, 'yieldback)) => fiber('in_, 'ret, 'yield, 'yieldback)
	let run_promise : 'in_ 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_, fiber('in_, 'ret, 'yield, 'yieldback)) => Js.promise('ret)
	let run_promise2 : 'in_1 'in_2 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_1, 'in_2, fiber(('in_1, 'in_2), 'ret, 'yield, 'yieldback)) => Js.promise('ret)
	let run_promise3 : 'in_1 'in_2 'in_3 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_1, 'in_2, 'in_3, fiber(('in_1, 'in_2, 'in_3), 'ret, 'yield, 'yieldback)) => Js.promise('ret)
	let run_promise4 : 'in_1 'in_2 'in_3 'in_4 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_1, 'in_2, 'in_3, 'in_4, fiber(('in_1, 'in_2, 'in_3, 'in_4), 'ret, 'yield, 'yieldback)) => Js.promise('ret)
	let run_promise5 : 'in_1 'in_2 'in_3 'in_4 'in_5 'ret 'yield 'yieldback. (~ctrl:ctrl('ret, 'yield, 'yieldback), 'in_1, 'in_2, 'in_3, 'in_4, 'in_5, fiber(('in_1, 'in_2, 'in_3, 'in_4, 'in_5), 'ret, 'yield, 'yieldback)) => Js.promise('ret)

	module Cancel {
		let force : (~ctrl:ctrl('ret, 'yield, 'yieldback), fiber('in_, 'ret, 'yield, 'yieldback)) => unit
	}
}

/** [ctrl->Fiber.lam(f)] creates a lambda term, a cross-world function
	implementing callback-based inversion of control.

	{2 Example usage}

	{[
	let run = () => {
		let k = Fiber.With_ctrl1.make(~ctrl, k);
		let* u = Fiber.(With_ctrl1.run_promise2(~ctrl,
			ctrl->lam(i => setCount(_ => i)), interval, k));
		return(u)
	}
	]} */
let lam : 'ret 'a 'b. (ctrl('ret, 'a, 'b), 'a => 'b) => Fiber__core.lambda('a, 'b)

let lam' : 'ret 'a 'b. (ctrl('ret, 'a, 'b), 'a => Js.promise('b)) => Fiber__core.lambda('a, 'b)
