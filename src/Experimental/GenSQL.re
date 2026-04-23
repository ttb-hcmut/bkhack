open Quel;
include Quel_sql.GenSQL;

type user and pr;

let user = (id, name) => record @@ ("user_id" %: id) %* (row1 ("name" %: name))
and pr = (id, post_id, title) => record @@ ("pr_id" %: id) %* ("post_id" %: post_id) %* (row1 ("title" %: title));

/** {1 projections} */

module User = {
	let id = r => r %. "user_id"
	and name = r => r %. "name";
};

module Pull_request = {
	let id = r => r %. "pr_id"
	and post_id = r => r %. "post_id"
	and title = r => r %. "title";
};

/** {1 data sources} */

let users = () => [] and prs = () => []
