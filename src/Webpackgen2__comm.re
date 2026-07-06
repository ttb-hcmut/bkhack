open Eio

// 1. Model the protocol packet as type
type packet  = { packet_entries : list(entry) }
and  entry   = { entry_modname : string, entry_jsfile : cwd(Path.t(Fs.dir_ty)) }
and  cwd('a) = Path.t(Fs.dir_ty) => 'a

// 2. Construct lenses based on the type above--encodes and decoders
let packet = packet_entries => { packet_entries: packet_entries }
and packet_entries = p => p.packet_entries
and entry = (entry_modname, entry_jsfile) => { entry_modname, entry_jsfile }
and entry_modname = e => e.entry_modname and entry_jsfile = e => e.entry_jsfile;

let get_ok' = fun
| Ok(x) => x
| Error(msg) => failwith(msg)

let jsont = (~enc_cwd=?, ()) => Jsont.({
	let a = Base.map(~kind="eio.path", ~dec=((_, s) => cwd => Eio.Path.(cwd / s)), ~enc=?(enc_cwd |> Option.map(cwd => f => Eio.Path.native_exn @@ f(cwd))), ());
	let path = a |> Base.string;
	Object.map(~kind="packet", packet)
	|> Object.mem("entries", list(
		Object.map(~kind="entry", entry)
		|> Object.mem("modname", string, ~enc=entry_modname)
		|> Object.mem("jsfile", path, ~enc=entry_jsfile)
		|> Object.finish
	), ~enc=packet_entries)
	|> Object.finish
})

let path_equal = (~cwd, a1, a2) =>
	String.equal(
		Path.native_exn(a1(cwd)),
		Path.native_exn(a2(cwd))
	)

let equal = (~cwd, p1, p2) => {
	List.equal((t1, t2) => {
		String.equal(t1.entry_modname, t2.entry_modname) && path_equal(~cwd, t1.entry_jsfile, t2.entry_jsfile)
	}, p1.packet_entries, p2.packet_entries)
}

module Buf_read {
	open Containers.Fun
	open Eio.Buf_read

	let packet = line |> map(Jsont_bytesrw.decode_string(jsont()) %> get_ok')
}

module Buf_write {
	open Eio.Buf_write

	let packet = (t, ~cwd, pak) => pak |> Jsont_bytesrw.encode_string(jsont(~enc_cwd=cwd, ())) |> get_ok' |> string(t)
}

module type Buildlib {
	module Path {
		let symlink':
			(~sw: Switch.t, ~procm: Resource.t(Process.mgr_ty([> `Generic])), ~link_to: Path.t(Fs.dir_ty), Path.t(Fs.dir_ty)) => unit
	}
}

let compile_js_daemon = (module Build : Buildlib, ~procm, ~fs, ~net, `raw(dist_dir), ls) => {
	let server = Path.(fs / Sys.getenv("DUNE_BUILD_DIR") / ".webpacking" / "in");
	let to_client = sw => Net.connect(~sw, net, `Unix (Path.native_exn @@ server));
	let ls' = ls |> List.map( ((k, _)) => k++".js" ) |> List.cons("misc");
	Switch.run @@ sw => {
	Fiber.fork(~sw, () =>
		Eio.Buf_write.with_flow(to_client(sw), to_client =>
		Buf_write.packet(to_client, ~cwd=fs, packet(ls |> List.map(
			((k, v)) => entry(k, (cwd => Path.(cwd / "_build" / "default" / "src" / Path.native_exn(v)) ))
		)))));
	Fiber.List.iter(k =>
		Switch.run @@ sw => {
		Path.mkdirs(~exists_ok=true, ~perm=0o700, Path.(
			fs / Filename.dirname(Path.native_exn(Path.(dist_dir / k)))));
		Build.Path.symlink'(~procm, ~sw,
			~link_to=Path.(fs / Sys.getenv("DUNE_BUILD_DIR") / ".webpacking" / "out" / k),
			Path.(dist_dir / k))
	}, ls')
	}
}
