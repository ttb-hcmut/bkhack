open Ppxlib
open Ppx_comptime__topcore__evalproc
open Containers.Fun

module Ast = Ast_helper

let sanitize = {
	let f = _ => "__";
	Re.replace(~all=true, ~f) @@ Re.compile @@ Re.(alt([char('.'), char('/'), char('-')]))
}

let split_ws = {
	let ws = Re.(alt @@ [char(' '), char('\n'), char('\t')]);
	let split = Re.split_delim @@ Re.compile @@ Re.(rep1 @@ ws)
	// and strip = (Re.exec @@ Re.compile @@ Re.(seq @@ [bos, greedy(rep(ws)), group(any), greedy(rep(ws)), eos])) %> (g => Re.Group.get(g, 1));
	split
}

module Option {
	include Option
	
	let bind' = (a, b) => bind(b, a);

	let value' = (~default, o) => switch (o) {
		| Some(_) as o => o
		| None => default()
	}
}

let comptime =
Context_free.Rule.extension @@
Extension.declare("comptime", Extension.Context.structure_item, Ast_pattern.(pstr(__))) @@
(~loc, ~path) => fun | [{ pstr_loc, pstr_desc: Pstr_value(_recflag, [{ pvb_pat: { ppat_desc: u, _ } as pvb_pat, pvb_expr, pvb_attributes, pvb_loc }]) }, ..._] => {
	switch (u) {
		| Ppat_var({ txt: name, _ }) => {
			let meta = List.map (({ attr_name: { loc: _, txt: attr_name }, attr_payload, attr_loc: _ }) => (attr_name, attr_payload), pvb_attributes);
			let of_str_list = fun
				| PStr([{ pstr_desc: Pstr_eval({ pexp_desc: Pexp_constant(Pconst_string(s, _, _)), _ }, _), _ }, ..._]) => Some(s |> split_ws)
				| _ => None;
			let get_libraries_opt = Sexplib.Pre_sexp.({
				let each = fun
					| Atom(x)
					| List([Atom(x), ..._]) => Some(x)
					| _ => None
					;
				fun
				| List([Atom("libraries"), ...xs]) => Some(xs |> List.map(each) |> List.filter_map(Fun.id))
				| _ => failwith("wads")
			});
			let strats = [
				() => Containers.IO.File.read(Sys.getenv("TEST")++"/src/dune-compiler") |> Containers.Result.to_opt |> Option.bind'(Sexplib.Sexp.of_string %> get_libraries_opt),
				() => List.assoc_opt("comptime.libraries", meta) |> Option.bind'(of_str_list),
				() => List.assoc_opt("libraries", meta) |> Option.bind'(of_str_list),
			];
			let args =
				List.fold_left((acc, f) => acc |> Option.value'(~default=f), None, strats);
			let args =
				args |> Option.map(List.map(x => ["-require", x]) %> List.flatten %> (args => ["utop", ...args]) %> String.concat(" "));
			let pvb_expr = [%expr { let __name__ = [%e Ast.Exp.constant @@ Ast.Const.string @@ String.concat("__") @@ [sanitize(path), name]]; [%e pvb_expr] }];
			let pvb_expr' = Eval.expression(~process_mgr=(module Sys), ~fs=(module Containers.IO.File), ~args?, pvb_expr) |> Eval.parse(~loc);
			{ pstr_loc, pstr_desc: Pstr_value(_recflag, [{ pvb_pat, pvb_expr: pvb_expr', pvb_attributes, pvb_loc }]) }
		}
		| _ => Location.raise_errorf(~loc, "must be variable")
	}
}
| _ => Location.raise_errorf(~loc, "must be a module")

let () = {
	let rules = [comptime];
	Driver.register_transformation(~rules, "ppx_comptime")
}
