module Window : {

	/** The [Location] interface represents the location (URL) of the object it is linked to. Changes done on it are reflected on the object it relates to. Both the Document and Window interface have such a linked Location, accessible via Document.location and Window.location respectively. */
	module Location : {
		/** [Location.href_set url] navigates to the provided URL. If
				you want redirection, use [Location.replace]. The difference
				from setting the href property value is that when using the
		    [Location.replace] method, after navigating to the given
		    URL, the current page will not be saved in session history
		    — meaning the user won't be able to use the back button to
		    navigate to it. */
		let href_set : string => 'a
	}

	external add_event_listener : string => (React.Event.Keyboard.t => unit) => unit = "window.addEventListener"
	external remove_event_listener : string => (React.Event.Keyboard.t => unit) => unit = "window.removeEventListener"
}

/** [Date] objects represent a single moment in time in a platform-independent format. Date objects encapsulate an integral number that represents milliseconds since the midnight at the beginning of January 1, 1970, UTC (the epoch). */
module Date : {
	type t;
	let of_now : unit => t
	let of_iso_string : string => t
	let get_time : t => int
	let to_date_string : t => string
	module Utc : {
		let date : t => int
		let month : t => int
		let full_year : t => int
	}
}

module Document : {
	let title_set : string => unit
	let query_selector : string => Js.nullable(Js.t(_))
	let query_selector_all : string => Js.array_like(Js.t(_))
	// let cookie : string => Js.array_like(Js.t(_))
}
