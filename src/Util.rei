/** [parseQueryParams(search)] will parse the search term / query
		section of the URI into a {Js.dict}
	
	- When using [ReasonReact], [search] can be obtained via
		[ReasonReactRouter.useUrl().search];
	- When using [Js], search can be obtained via
 */
let parseQueryParams : string => Js.dict(string)

let parseQueryParams' : string => list((string, string))

let stringQueryParams' : list((string, string)) => string

module List : {
	let replace_assoc' : 'k => 'v => list(('k, 'v)) => list(('k, 'v))
}

let utcToRelative : string => string