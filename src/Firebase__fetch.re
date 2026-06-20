module Option {
	include Option

	let list_iter = f => fun
		| [] => ()
		| xs => f(xs)
}

module Structured_query {
	open Firebase__with_strqry

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
}

module Firestore {
	let run_query = (~key, q) => Fetch__syntax.({
		Js.Console.log(q);
		Js.Console.log(q->Structured_query.conv);
		let body = Js.Obj.empty();
		body##"structuredQuery" #= q->Structured_query.conv;
		let* a = Fetch.fetchWithInit(
			"https://firestore.googleapis.com/v1/projects/bkhack-2eb8c/databases/(default)/documents:runQuery?key="++key,
			Fetch.RequestInit.make(
				~method_=Post,
				~body=Fetch.BodyInit.make(body->Js.Json.serializeExn),
				~headers=Fetch.HeadersInit.make({
					"Content-Type": "application/json",
				})
			)()
		);
		let* json = a->Fetch.Response.json;
		return(json)
	})
}

module type Data' {
	let q : Firebase__with_strqry.structured_query
}

module type Env {
	module Firebase {
		let key : string
	}
}

module type Data {
	type t
	include Data'
}

let all = (type t, module Data : Data with type t = t, module Env : Env) => {
	let open Fetch__syntax;
	let* json = Firestore.run_query(~key=Env.Firebase.key, Data.q);
	let x = json |> Js__json.decodeArrayExn |> Array.map(it => {
		let dict = it |> Js__json.decodeObjectExn;
		let document = dict->Js.Dict.get("document")->Option.get->Js__json.decodeObjectExn;
		let fields = document->Js.Dict.get("fields")->Option.get;
		fields
	}) |> Js__json.array;
	return(x)
}
