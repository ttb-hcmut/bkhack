type message('a);

module World() {
	type global('a, 'b);
	external global : global('a, 'b) = "globalThis";
	[@mel.set] external onMessage_: global('a, 'b) => (message('a) => unit) => unit = "onmessage";
	let onMessage = (k: message('a) => unit) => onMessage_(global, k);
	external postMessage: 'b => unit = "postMessage"
}

type worker('a, 'b) and worker_param and import_meta and import_meta_url;

[@mel.new] external create : worker_param => worker('a, 'b) = "Worker";

module Url {
	[@mel.new] external create : (string, import_meta_url) => worker_param = "URL";
}

module Message {
	[@mel.get] external data : message('a) => 'a = "data"
}

module Worker {
	[@mel.set] external onmessage : worker('a, 'b) => (message('b) => unit) => unit = "onmessage"
	[@mel.set] external onerror : worker('a, 'b) => ('exn => unit) => unit = "onerror"
	[@mel.send] external postMessage : worker('a, 'b) => 'a => unit = "postMessage";
	[@mel.send] external terminate : worker('a, 'b) => unit = "terminate";
}

[@mel.scope ("import", "meta")] external import_meta_url : import_meta_url = "url";
