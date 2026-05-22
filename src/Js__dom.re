type window_location_api;
[@mel.scope "window"] external window_location_api : window_location_api = "location";
[@mel.set] external window_location_href_set : window_location_api => string => 'a = "href";

module Window = {
	module Location = {
		let href_set = window_location_href_set(window_location_api);
	}
	external add_event_listener : string => (React.Event.Keyboard.t => unit) => unit = "window.addEventListener"
	external remove_event_listener : string => (React.Event.Keyboard.t => unit) => unit = "window.removeEventListener"
}

module Date = {
	type t;
	[@mel.new]  external of_now : unit => t = "Date";
	[@mel.new]  external of_iso_string : string => t = "Date";
	[@mel.send] external get_time : t => int = "getTime";
	[@mel.send] external to_date_string : t => string = "toDateString";
	module Utc = {
		[@mel.send] external date : t => int = "getUTCDate";
		[@mel.send] external month : t => int = "getUTCMonth";
		[@mel.send] external full_year : t => int = "getUTCFullYear";
	}
}

type document_api;
external document_api : document_api = "document";
[@mel.set] external document_title_set : document_api => string => unit = "title"

module Document = {
	let title_set = document_title_set(document_api);
	[@mel.scope "document"] external query_selector : string => Js.nullable(Js.t(_)) = "querySelector";
	[@mel.scope "document"] external query_selector_all : string => Js.array_like(Js.t(_)) = "querySelectorAll";
}
