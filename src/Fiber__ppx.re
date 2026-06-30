open Ppxlib
open Ppx_comptime__topcore__unparse

module A = Ast_helper

let sanitize = {
	let f = _ => "__";
	Re.replace(~all=true, ~f) @@ Re.compile @@ Re.(alt([char('.'), char('/'), char('-')]))
}

module Location {
	let raise_errorf = Location.raise_errorf

	let raise_error = (~loc, s) => {
		Location.raise_errorf(~loc, "ppxfiber: %s", s)
	}
}

let is_in_build = {
	let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), any |> rep]));
	Re.execp @@ pat
}

let cont =
Context_free.Rule.extension @@
Extension.declare("Fiber.bind", Extension.Context.structure_item, Ast_pattern.(pstr(__))) @@
(~loc, ~path) => fun | [{ pstr_loc, pstr_desc: Pstr_value(_recflag, [{ pvb_pat: { ppat_desc: u, _ } as pvb_pat, pvb_expr, pvb_attributes, pvb_loc } as kkk]) }, ..._] => {
	let intype = pvb_attributes |> List.find_map(fun
		| { attr_name: { txt: "in_", _ }, attr_payload : PTyp(intype), _ } => Some(intype)
		| _ => None
	)
	let rettype = pvb_attributes |> List.find_map(fun
		| { attr_name: { txt: "ret", _ }, attr_payload : PTyp(rettype), _ } => Some(rettype)
		| _ => None
	)
	switch (u) {
	| Ppat_var({ txt: name, _ }) => {
		switch (pvb_expr.pexp_desc) {
		| Pexp_fun(Nolabel, None, { ppat_desc: Ppat_construct({ txt: Lident("()"), loc }, None), _ }, pvb_expr) =>
			let name = "Fiberlet__"++sanitize(path)++"__"++name;
			let worker_expr = [%expr {
				open Js__worker
				open Melange__containers.Fun
				[@warning "-73"]
				open World()
				let promiser = Hashtbl.create(0);
				onMessage(Message.data %> req => {
					switch (req) {
						| Either.Right(Fiber__core.Comm__set(promiser_id, promiser_val)) =>
							let (resolve, _reject) = promiser->Hashtbl.find(promiser_id);
							resolve(promiser_val)
						| Either.Left(Fiber__core.Comm__request(owner, param) as req) =>
							module Lam {
								[@warning "-32"]
								let app = (v: 'a, f: Fiber__core.lambda('a, 'b)) : Js.promise('b) => {
									let Lambda({ await_id }) = f;
									Js.Promise.make @@ (~resolve, ~reject) => {
										open {
											[@mel.send] external call1 : Js.Fn.arity1('a => 'b) => 'this => 'a => 'b = "call";
											let resolve = data => resolve->call1(Js.null, data)
											and reject  = e    => reject->call1(Js.null, e);
										};
										promiser->Hashtbl.add(await_id, (resolve, reject));
										let res = Result.ok @@ Fiber__core.Rep_(await_id, v);
										postMessage(Fiber__core.Comm__reply(req, owner, res))
									}
								}
							};
							let k = [%e pvb_expr];
							ignore(
								k(param)
								|> Js.Promise.catch(e => {
									let e = Js.Exn.anyToExnInternal(e);
									let res = Result.error @@ e;
									postMessage(Fiber__core.Comm__reply(req, owner, res));
									Js.Promise.reject(e)
								})
								|> Js.Promise.then_(x => {
									let res = Result.ok @@ Fiber__core.Rep_ly(x);
									postMessage(Fiber__core.Comm__reply(req, owner, res));
									Js.Promise.resolve()
								})
							);
					}
				})
			}];
			let str = Unparse.expression(worker_expr);
			let str = "("++str++");;";
			let str_rule = Printf.sprintf({|
				(rule
				 (deps %%{project_root}/%s)
				 (target %s.ml)
				 (action (run
					cp /tmp/%%{target} %%{target}
					)))
			|}, path, name);
			if (is_in_build(Sys.getcwd())) {
				Containers.IO.File.write_exn("/tmp/"++name++".ml", str);
				try (Sys.mkdir("/tmp/ppxfiber.services", 0o700)) { | _ => () };
				Containers.IO.File.write_exn("/tmp/ppxfiber.services/"++name++".dune", str_rule);
			}
			let pvb_expr' = {
				let intype = Option.value(intype, ~default=A.Typ.any())
				and rettype = Option.value(rettype, ~default=A.Typ.any());
				[%expr
					(
						Fiber.of_worker(() => {
						let module_ = name => Js__worker.Url.create(name, Js__worker.import_meta_url);
						[%e A.Exp.constant @@ A.Const.string @@ (name++".js")]->module_->Js__worker.create
						})
						: Fiber.continuation([%t intype], [%t rettype], _, _)
					)
				]
			};
			[@warning "-23"]
			{ pstr_loc, pstr_desc: Pstr_value(_recflag, [{ ...kkk, pvb_pat, pvb_expr: pvb_expr', pvb_attributes, pvb_loc }]) }
		| _ => Location.raise_error(~loc, "must be a unit-init function declaration")
		}
	}
	| _ => Location.raise_error(~loc, "let-binding LHS must be variable pattern")
	}
}
| _ => Location.raise_error(~loc, "must be a let-binding (module support is TBA)")


let () = {
	Driver.register_transformation(~rules=[cont], "ppxfiber")
}
