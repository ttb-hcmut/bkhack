module View = {
	type t =
		| Article
		| Discussion
		| Pullrequest
		| Log
		| Edit

	let uu = [
		( Article, "article" ),
		( Discussion, "discussions" ),
		( Pullrequest, "pullrequests" ),
		( Log, "log" ),
		( Edit, "edit")
	]

	let uu' = uu |> List.map(((k, v)) => (v, k))

	let to_string = k => List.assoc(k, uu)

	let of_string = k => List.assoc(k, uu')
}
