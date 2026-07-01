include Fetch__syntax

[@mel.send] external call1 : Js.Fn.arity1('a => 'b) => 'this => 'a => 'b = "call"

module Lam {
	let app = (ctrl, app: 'a, f: Fiber__core.lambda('a, 'b)) : Js.promise('b) => {
		let (owner, req, awaitgen, promiser, postMessage) = ctrl;
		let Lambda({ async_id }) = f;
		let await_id = awaitgen^;
		awaitgen := awaitgen^ + 1;
		Js.Promise.make((~resolve, ~reject) => {
			let resolve = data => resolve->call1(Js.null, data)
			and reject  = e    => reject->call1(Js.null, e);
			promiser->Hashtbl.add(await_id, (resolve, reject));
			let res = Result.ok @@ Fiber__core.Rep_({ async_id, await_id, app });
			postMessage(Fiber__core.Comm__reply(req, owner, res))
		})
		|> Js.Promise.then_(x => {
			promiser->Hashtbl.remove(await_id);
			Js.Promise.resolve(x)
		})
		|> Js.Promise.catch(e => {
			promiser->Hashtbl.remove(await_id);
			Js.Promise.reject(Js.Exn.anyToExnInternal(e))
		})
	}
}
