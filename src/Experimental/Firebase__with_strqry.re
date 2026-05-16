type field_ref = { fldrf_field_path: string } and cursor and find_nearest and value = | Val_integer(int);

/** @reference {https://firebase.google.com/docs/firestore/reference/rest/v1/StructuredQuery} */
type structured_query =
{ qry_select: option(projection),
	qry_from: list(collection_selector),
	qry_where: option(filter),
	qry_order_by: list(order),
	qry_start_at: option(cursor),
	qry_end_at: option(cursor),
	qry_offset: option(int),
	qry_limit: option(int),
	qry_find_nearest: option(find_nearest) }

and projection =
{ proj_fields : list(field_ref) }

and collection_selector =
{ colsel_collection_id : string,
	colsel_all_descendants : bool }

and filter =
	| Flt_composite_filter(composite_filter)
	| Flt_field_filter(field_filter)
	| Flt_unary_filter(unary_filter)

and composite_filter =
{ compflt_op: compflt_operator
, compflt_filters: list(filter)
}

and compflt_operator =
	[ `op_unspecified
	| `op_and
	| `op_or
	]

and field_filter =
{ fieldflt_field: option(field_ref)
, fieldflt_op: fieldflt_operator
, fieldflt_value: option(value)
}

and fieldflt_operator =
	[ `op_unspecified
	| `op_lt
	| `op_le
	| `op_gt
	| `op_ge
	| `op_eq
	| `op_ne
	| `op_arr_contains
	| `op_in
	| `op_arr_contains_any
	| `op_ni
	]

and unary_filter =
	{ unflt_op: unflt_operator
	, unflt_field : field_ref
	}

and unflt_operator =
	[ `op_unspecified
	| `op_is_nan
	| `op_is_null
	| `op_is_not_nan
	| `op_is_not_null
	]

and order =
{ order_field : field_ref
, order_direction : order_direction
}

and order_direction =
	[ `dir_unspecified
	| `dir_ascending
	| `dir_descending
	]

let qry_empty = {
	qry_select: None,
	qry_from: [],
	qry_where: None,
	qry_order_by: [],
	qry_start_at: None,
	qry_end_at: None,
	qry_offset: None,
	qry_limit: None,
	qry_find_nearest: None
}

module Option {
	include Option

	let list_iter = f => fun
		| [] => ()
		| xs => f(xs)
}

let conv_field_ref = t => {
	let o = Js.Obj.empty();
	o##"fieldPath" #= t.fldrf_field_path;
	o
}

let conv = t => {
	let o = Js.Obj.empty();
	t.qry_select |> Option.iter(select => {
		o##"select" #= Js.Obj.empty();
		o##"select"##"fields" #= (Array.map(conv_field_ref) @@ Array.of_list @@ select.proj_fields)
	});
	t.qry_from |> Option.list_iter(from_ => {
		o##"from" #= (
			from_ |> Array.of_list |> Array.map(tbl => {
				let o = Js.Obj.empty();
				o##"collectionId" #= tbl.colsel_collection_id;
				o##"allDescendants" #= tbl.colsel_all_descendants;
				o
			})
		)
	});
	t.qry_limit |> Option.iter(limit => { o##"limit" #= limit });
	t.qry_offset |> Option.iter(offset => { o##"offset" #= offset });
	o
}
