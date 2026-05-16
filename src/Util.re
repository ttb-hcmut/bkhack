let parseQueryParams = (search: string) => {
	Js.String.split(~sep="&", search)
	|> Js.Array.reduce(~init = [], ~f = (acc, pair) => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0)  ;
			let value = Js.Array.unsafe_get(parts, 1);
			List.cons((key, value), acc)
		} else { acc }
	})
	|> Js.Dict.fromList
};

let parseQueryParams' = (search: string) => {
	Js.String.split(~sep="&", search)
	|> Js.Array.reduce(~init = [], ~f = (acc, pair) => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0)  ;
			let value = Js.Array.unsafe_get(parts, 1);
			List.cons((key, value), acc)
		} else { acc }
	})
};

let stringQueryParams' = dict => {
	dict |> List.map( ((k, v)) => k++"="++v ) |> String.concat("&")
}

module List = {
	let replace_assoc' = (k, v, dict) =>
		switch (List.assoc_opt(k, dict)) {
			| Some(u) when (v == u) => dict
			| Some(_) => dict |> List.remove_assoc(k) |> xs => xs @ [(k, v)]
			| None => dict @ [(k, v)]
		}
}
let utcToRelative = (utc:string) =>{
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