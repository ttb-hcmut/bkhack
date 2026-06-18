open Eio

let main = (~outdir, `typst_compile(bin, args)) => Eio_main.run @@ env => {
	let cwd = Stdenv.cwd(env) and process_mgr = Stdenv.process_mgr(env);
	Fiber.List.iter(entry => {
		let name = Filename.basename(entry) |> Filename.remove_extension;
		let entry' = Path.(cwd / entry);
		let output' = Path.(outdir(cwd) / (name++".pdf"));
		Process.run(process_mgr, [bin, Path.native_exn(entry'), Path.native_exn(output')]);
	}, args);
}

open Cmdliner
open Term.Syntax

let main__ = Cmd.v(Cmd.info("typst", ~doc="")) @@ {
  let+ outdir = Arg.(required & opt((some(string)), None) &
    info(["output", "o"], ~doc=" Output directory. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
	and+ cmd = Arg.(value & pos_all(string, []) & info([], ~docv="haha"))
		|> Term.map([@warning "-8"] fun | [bin, ...args] => `typst_compile(bin, args));
	main(~outdir, cmd)
};

/** autorun except in toplevel / interactive mode */
let () =
  if (Sys.interactive^) () else
  exit @@ Cmd.eval @@ main__
