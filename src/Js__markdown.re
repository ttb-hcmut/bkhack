module Unified {
	type t and file and middleware;

	[@mel.module "unified"] external make : unit => t = "unified";

	[@mel.send] external use : t => middleware => t = "use";
	[@mel.send] external parse : t => string => Js.t({ .. }) = "parse";
	[@mel.send] external stringify : t => 'a => string = "stringify";
	[@mel.send] external process : t => string => Js.promise(file) = "process";
	[@mel.send] external process' : t => string => file = "processSync";
}

module Rehype {
	[@mel.module "rehype-sanitize"] external sanitize : Unified.middleware = "default"
	[@mel.module "rehype-stringify"] external stringify : Unified.middleware = "default"
}

module Remark {
	[@mel.module "remark-parse"] external parse : Unified.middleware = "default"
	[@mel.module "remark-rehype"] external rehype : Unified.middleware = "default"
}

external string : 'a => string = "String"
