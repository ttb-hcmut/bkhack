type global;

external global : global = "globalThis";

[@mel.set] external onMessage: global => ('a => 'b) => unit = "onmessage";

external postMessage: 'a => unit = "postMessage"

type worker and worker_param and import_meta and import_meta_url and message;

[@mel.new] external create : worker_param => worker = "Worker";

module Url {
	[@mel.new] external create : (string, import_meta_url) => worker_param = "URL";
}

module Message {
	[@mel.get] external data : message => 'a = "data"
}

module Worker {
	[@mel.set] external onmessage : worker => (message => unit) => unit = "onmessage"
	[@mel.set] external onerror : worker => ('exn => unit) => unit = "onerror"
	[@mel.send] external postMessage : worker => 'a => unit = "postMessage";
}

[@mel.scope "import"] external import_meta : import_meta = "meta";

[@mel.get] external import_meta_url : import_meta => import_meta_url = "url";
