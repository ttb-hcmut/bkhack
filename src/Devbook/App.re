open Eio

let snake_to_burger = {
	let f = _ => "-";
	Re.replace(~f, ~all=true) @@ Re.compile @@ Re.(char('_'))
}

let strip_prefix = {
	let f = g => Re.Group.get(g, 1) |> snake_to_burger;
	Re.replace(~f) @@ Re.compile @@ Re.(seq([ bos, str("Page"), str("__"), group(any |> rep1), eos ]))
}

let main = (~outdir, ~package_path, ~article_at_root, `typst_compile(bin, args)) => Eio_main.run @@ env => {
	let cwd = Stdenv.cwd(env) and process_mgr = Stdenv.process_mgr(env);
	Fiber.List.iter(entry => {
		let name = Filename.basename(entry) |> Filename.remove_extension;
		let entry' = cwd => Path.(cwd / entry);
		let output' = Path.(outdir(cwd) / (strip_prefix(name)++".pdf"));
		Typst_compile.Lib_io.with_processed_file(~cwd, ~article_at_root, entry') @@ entry' =>
		Process.run(process_mgr, bin @ ["--package-path", Path.native_exn(package_path(cwd)), Path.native_exn(entry'), Path.native_exn(output')]);
	}, args);
}

open Cmdliner
open Term.Syntax

let main__ = Cmd.v(Cmd.info("typst", ~doc="")) @@ {
  let+ outdir = Arg.(required & opt((some(string)), None) &
    info(["output", "o"], ~doc=" Output directory. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
  and+ package_path = Arg.(required & opt((some(string)), None) &
    info(["package-path"], ~doc=" Package directory. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
	and+ article_at_root = Arg.(required & opt((some(bool)), None) & info(["article-at-root"]))
	and+ cmd = Arg.(value & pos_all(string, []) & info([], ~docv="haha"))
		|> Term.map([@warning "-8"] fun | ["typst", "compile", ...args] => `typst_compile(["typst", "compile"], args) | [bin, ...args] => `typst_compile([bin], args));
	main(~outdir, ~package_path, ~article_at_root, cmd)
};

/** autorun except in toplevel / interactive mode */
let () =
  if (Sys.interactive^) () else
  exit @@ Cmd.eval @@ main__
