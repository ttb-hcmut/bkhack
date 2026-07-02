open Ppxlib

let () = {
	let rules = [Ppx_comptime_core.comptime];
	Driver.register_transformation(~rules, "ppx_comptime");
	Driver.standalone()
}
