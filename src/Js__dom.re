type window_location_api;
[@mel.scope "window"] external window_location_api : window_location_api = "location";
[@mel.set] external window_location_href_set : window_location_api => string => unit = "href";
module Window = {
	module Location = {
		let href_set = window_location_href_set(window_location_api);
	}
}
module Date = {
	type t;
	[@mel.new] external of_iso_string : string => t = "Date";
	[@mel.send] external get_time : t => int = "getTime"
}
