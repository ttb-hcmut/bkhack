open Cmdliner
open Term.Syntax

let path' = {
	let parser = s => Ok(cwd => Eio.Path.(cwd / s))
	and pp : Arg.printer(_) = (ppf, s) => Fmt.nop(ppf, { ignore(s) })
  and completion = Arg.Completion.complete_paths;
	Arg.Conv.make(~docv="PATH", ~parser, ~completion, ~pp, ())
};

open Eio

module Chan {
	open Stream
	open Webpackgen2__comm
	module Buf_read = Webpackgen2__comm.Buf_read

	let create = c : t(packet) => create(c)

	let take = c : packet => take(c)

	// let add = (chan, s) => add(chan, s |> Jsont_bytesrw.decode_string(jsont()) |> Result.get_ok)
	let add = (chan : t(packet), s) => add(chan, s)

}

open Eio

let listen_at = (~net, ~cwd, ~chan, in_) =>
	Switch.run @@ sw => {
	Path.mkdirs(~exists_ok=true, ~perm=0o700, Path.(cwd / Filename.dirname(Path.native_exn(in_(cwd)))));
	let in_' = Net.listen(net,
		~sw, ~reuse_addr=false, ~backlog=5,
		`Unix(Path.native_exn @@ in_(cwd)))
	and on_error = x => traceln({|error: %a|}, Fmt.exn, x);
	Net.run_server(~on_error, in_') @@ (flow, _addr) => {
	let from_client = Buf_read.of_flow(flow, ~max_size=1_000_000);
	let a = Chan.Buf_read.packet(from_client);
	Chan.add(chan, a);
	// Eio.Buf_write.with_flow(flow, to_client => {
	// 	Eio.Buf_write.string(to_client, " \n");
	// });
	}}

exception Jump(Webpackgen2__comm.packet)

let main' = (~in_, ~out) =>
	Eio_main.run @@ env =>
	Switch.run @@ sw => {
	let spec = Chan.create(1);
	Fiber.fork_daemon(~sw, () => listen_at(
		~net=env#net, ~cwd=Stdenv.fs(env), ~chan=spec, in_));
	let last_spec = ref(None);
	let f = (~cwd, ~last_spec) => {
		let v = Chan.take(spec);
		Option.iter(last_spec' => {
			if (Webpackgen2__comm.equal(~cwd, last_spec', v)) () else {
				last_spec := Some(v);
				raise(Jump(v));
			}
		}, last_spec^);
		v
	};
	let rec aux = pak =>
		try (
		Switch.run(sw => {
			Fiber.fork(~sw, () => {
				Path.rmtree(~missing_ok=true, out(Stdenv.fs(env)));
				Buildlib.Build.compile_jsfile'(
					~procm=env#process_mgr, ~clock=env#clock,
					~watch=true, ~optimization=`Development,
					~cwd=Stdenv.fs(env), `raw(out(Stdenv.fs(env))),
					pak.Webpackgen2__comm.packet_entries |> List.map(
						it => (it.Webpackgen2__comm.entry_modname, it.entry_jsfile(Stdenv.fs(env)))
					))});
			f(~cwd=Stdenv.fs(env), ~last_spec)
		})
		) { | Jump(v) => v }
		|> aux;
	Path.rmtree(~missing_ok=true, out(Stdenv.fs(env)));
	let o = Chan.take(spec);
	last_spec := Some(o);
	aux(o)
	};

let main =
	Cmd.make(Cmd.info("webpackgen2")) @@ Arg.({
	let path' = info => required & opt(some(path'), None) & info;
	let+ in_ = path' & info(["in", "i"], ~docv="IN_", ~doc={|
		_where should the $DOCV comm be. |})
	and+ out = path' & info(["out", "o"], ~docv="OUT",
		~doc={| _where should the $DOCV outcomm be. |})
	main'(~in_, ~out)})

let () = {
	if (Sys.interactive^) () else exit @@
	exit @@ Cmd.eval @@ main }
