open Quel
include Quel_sql.GenSQL

type obs('a) = Firebase__with_strqry.structured_query
let to_str : Quel_sql.GenSQL.sql_query => obs('a) = Quel_sql.GenSQL.({
	let rec to_query = fun
		| SUnionAll([x]) => to_comp(x)
		| SUnionAll(_) => failwith("to_query: union all not supported")
	and to_comp = (SSelect(s,t,e,limit)) => {
		let x =
		{ ...Firebase__with_strqry.qry_empty,
			qry_select: to_select(s),
			qry_from: to_from(t),
			qry_where: to_where'(e) };
		limit |> Option.map(
			((count, offset)) => { ...x, qry_limit : Some(count), qry_offset: Some(offset) }
		) |> Option.value(~default=x)
	}
	and to_select = fun
		| SList(cols) => Some({ Firebase__with_strqry.proj_fields: cols |> List.map({ ((e, _)) => { Firebase__with_strqry.fldrf_field_path: (e|>exp_to_field_path) }  }) })
		| SAll(_) => None
	and exp_to_field_path = fun
		| SProj(x, l) => x++"."++l
		| _ => failwith("cannot convert expression to field path")
	and to_from = (SFrom(ts)) => ts |> List.map({ ((t, _)) => { Firebase__with_strqry.colsel_collection_id: t, colsel_all_descendants: true } })
	and to_where' = fun
		| SBool(true) => None
		| x => Some(to_where(x))
	and to_where = fun
		| SBinOp("=", e1, e2) => Firebase__with_strqry.Flt_field_filter({ fieldflt_field: Some(exp_to_field(e1)), fieldflt_op: `op_eq, fieldflt_value: Some(exp_to_value(e2)) })
		| SBinOp("AND", e1, e2) => Firebase__with_strqry.Flt_composite_filter({ compflt_op: `op_and, compflt_filters: [to_where'(e1), to_where'(e2)] |> List.filter_map(Fun.id) })
		| SBinOp("OR", e1, e2) => Firebase__with_strqry.Flt_composite_filter({ compflt_op: `op_or, compflt_filters: [to_where'(e1), to_where'(e2)] |> List.filter_map(Fun.id) })
		| e => failwith("to_where: unknown '"++(e|>Js.Json.serializeExn)++"'")
	and exp_to_field = fun
		| SProj(x, l) => { Firebase__with_strqry.fldrf_field_path: x++"."++l }
		| _ => failwith("exp_to_field: unknown")
	and exp_to_value = fun
		| SInt(n) => Firebase__with_strqry.Val_integer(n)
		| _ => failwith("exp_to_value: unknown");
	to_query
})
let observe = x : obs(_) => to_str @@ Quel_sql.GenSQL.to_sql(x((), 0))

type user and post and pr and pr_status = [ `Open | `Closed | `Merged ];


let user = (id, name) => record @@ ("user_id" %: id) %* (row1 ("name" %: name))
let post = (id, title, creator, text) => record @@ ("post_id" %: id) %* (row1 ("post_title" %: title) %* ("creator_id" %: creator) %* ("post_text" %: text))
and pr = (id, post_id, contributor, title, description, status, tags, created) => record @@ ("pr_id" %: id) %* ("post_id" %: post_id) %* ("contributor_id" %: contributor) %* (row1 ("title" %: title) %* ("description" %: description) %* ("status" %: status) %* ("tags" %: tags) %* ("date_created_utc" %: created));

/** {1 projections} */

module User = {
	let id = r => r %. "user_id"
	and name = r => r %. "name";
};

module Post = {
	let id = r => r %. "post_id"
	and title = r => r %. "post_title"
	and creator = r => r %. "creator_id"
	and text = r => r %. "post_text"
};

module Pull_request = {
	let id = r => r %. "pr_id"
	and post = r => r %. "post_id"
	and contributor = r => r %. "contributor_id"
	and title = r => r %. "title"
	and description = r => r %. "description"
	and status = r => r %. "status"
	and tags = r => r %. "tags"
	and date_created_utc = r => r %. "date_created_utc";
};

/** {1 data sources} */

let users = () => [] and posts = () => [] and prs = () => []
