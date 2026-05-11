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
    
    let toRelative = (utc:string) =>{
      let fixed = utc
      |> Js.Date.fromString  
      |> Js.Date.valueOf
      let current = Js.Date.now() 
      let seconds = int_of_float(current -. fixed) / 1000
      let minutes = seconds / 60
      let hours   = minutes / 60
      let days    = hours / 24
      let weeks   = days / 7
      let months  = days / 31
      let years   = days / 360
      if        (seconds < 60)  { string_of_int(seconds)  ++ "s ago"
      } else if (minutes < 60)  { string_of_int(minutes)  ++ "\' ago"
      } else if (hours < 24)    { string_of_int(hours)    ++ "h ago"
      } else if (days < 7)      { string_of_int(days)     ++ "d ago"
      } else if (weeks < 4)     { string_of_int(weeks)    ++ "w ago"
      } else if (months < 12)   { string_of_int(months)   ++ "m ago"
      } else                    { string_of_int(years)    ++ "y ago"
      }
    }
	}
}

type document_api;
external document_api : document_api = "document";
external document_title_set : document_api => string => unit = "title"

module Document = {
	let title_set = document_title_set(document_api);
}
