open Cmdliner

let mpath = path =>
	(cwd: Eio.Path.t(Eio.Fs.dir_ty)) => Eio.Path.(cwd / path)

let parse_string = x => (x : string)

let parse_path = x =>
	(cwd: Eio.Path.t(Eio.Fs.dir_ty)) => Eio.Path.(cwd / x)

let parse_package = (~parent_ctor, attrs, k) => Sexplib.Pre_sexp.({
	let rec assoc_atom = (key, ~type_, ls) => switch (assoc_atom_opt'(key, ~type_, ls)) {
		| None => failwith("constructor "++parent_ctor++"."++key++"is required but not found")
		| Some(x) => x
	}
	and assoc_atom_opt = (key, ~type_, ls) => assoc_atom_opt'(key, ~type_, ls)
	and assoc_atom_opt' = (key, ~type_ as parse, ls) => ls |> List.find_map(fun
		| List([Atom(k), Atom(v)]) when String.equal(k, key) => Some(parse(v))
		| List([Atom(k), List(_)]) when String.equal(k, key) => failwith("expecting constructor "++parent_ctor++"."++key++" to have atom value, got list instead")
		| _ => None
	);
	[@warning "-26"]
	let rec assoc_list = (key, ~type_, ls) => switch (assoc_list_opt'(key, ~type_, ls)) {
		| None => failwith("constructor "++parent_ctor++"."++key++"is required but not found")
		| Some(x) => x
	}
	and assoc_list_opt = (key, ~type_, ls) => assoc_list_opt'(key, ~type_, ls)
	and assoc_list_opt' = (key, ~type_ as parse, ls) => ls |> List.find_map(fun
		| List([Atom(k), ...vs]) when String.equal(k, key) => Some(List.map(fun
			| Atom(x) => parse(x)
			| _ => failwith("expecting constructor "++parent_ctor++"."++key++" list to be comprised of values, got a list instead")
		, vs))
		| List([Atom(k), Atom(v)]) when String.equal(k, key) => failwith("expecting constructor "++parent_ctor++"."++key++" to have list value, got atom instead")
		| _ => None
	)
	;
	k({
		pub name = assoc_atom("name", ~type_=parse_string, attrs);
		pub version = assoc_atom("version", ~type_=parse_string, attrs);
		pub entrypoint = assoc_atom("entrypoint_module", ~type_=parse_string, attrs);
		pub license = assoc_atom_opt("license", ~type_=parse_string, attrs);
		pub description = assoc_atom_opt("description", ~type_=parse_string, attrs);
		pub authors = assoc_list_opt("authors", ~type_=parse_string, attrs)
	})
})

let parse_stanzas = (k', acc, ls) => Sexplib.Pre_sexp.(List.fold_left((acc, x) => switch (x) {
	| List([Atom("package"), ...attrs]) => parse_package(~parent_ctor="package", attrs, o => k'#pstr_package(acc, o))
	| _ => failwith("lol")
}, acc, ls))

let prog =
Cmd.make(Cmd.info("dune_typst")) @@
Term.Syntax.({

	let+ dunefile = Term.map(mpath) @@ Arg.
	(
		required
		& pos(0, some(path), None)
		& info([], ~docv="INPUT-FILE-PATH")
	)
	and+ outfile = Term.map(mpath) @@ Arg.
	(
		required
		& pos(1, some(path), None)
		& info([], ~docv="OUTPUT-FILE-PATH")
	)
	and+ print_format = Arg.
	(
		required
		& opt(some(enum @@ [
			("toml", `toml)
		]), None)
		& info(["print"], ~docv="PRINT-FORMAT")
	)
	;

	let table_add_opt = (k, v, tbl) => switch (v) {
		| None => tbl
		| Some(v) => Toml.Types.Table.add(k, v, tbl)
	}

	open Eio

	let pstr_package = (cwd, (tbl), o) => Toml.Types.({
		let package =
			Table.empty
			|> Table.add(Table.Key.of_string("name"), TString(o#name))
			|> Table.add(Table.Key.of_string("version"), TString(o#version))
			|> Table.add(Table.Key.of_string("entrypoint"), TString(
				Path.native_exn @@
				Path.(cwd / (o#entrypoint++".typ"))
			))
			|> table_add_opt(Table.Key.of_string("license"), o#license |> Option.map(x => TString(x)))
			|> table_add_opt(Table.Key.of_string("description"), o#description |> Option.map(x => TString(x)))
			|> table_add_opt(Table.Key.of_string("authors"), o#authors |> Option.map(x => TArray(Toml.Types.NodeString(x))));
		let tbl = tbl
			|> Table.add(Table.Key.of_string("package"), TTable(package));
		(tbl)
	})

	Eio_main.run @@ env => {
	let cwd = Stdenv.cwd(env);
	let sexps = Path.load(dunefile(cwd)) |> Sexplib.Sexp.of_string_many;
	let x = parse_stanzas({ pub pstr_package = pstr_package(cwd) }, (Toml.Types.Table.empty), sexps);
	Path.save(~create=(`Or_truncate(0o700)), outfile(cwd), Toml.Printer.string_of_table(x)) }

})

let () =
	Cmd.eval(prog) |> exit
