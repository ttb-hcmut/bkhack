open Quel;
include Quel_sql.GenSQL;

type user and post and pr;

let user = (id, name) => record @@ ("user_id" %: id) %* (row1 ("name" %: name))
let post = (id, title, creator) => record @@ ("post_id" %: id) %* (row1 ("post_title" %: title) %* ("creator_id" %: creator))
and pr = (id, post_id, contributor, title, description) => record @@ ("pr_id" %: id) %* ("post_id" %: post_id) %* ("contributor_id" %: contributor) %* (row1 ("title" %: title) %* ("description" %: description));

/** {1 projections} */

module User = {
	let id = r => r %. "user_id"
	and name = r => r %. "name";
};

module Post = {
	let id = r => r %. "post_id"
	and title = r => r %. "post_title"
	and creator = r => r %. "creator_id"
};

module Pull_request = {
	let id = r => r %. "pr_id"
	and post = r => r %. "post_id"
	and contributor = r => r %. "contributor_id"
	and title = r => r %. "title"
	and description = r => r %. "description";
};

/** {1 data sources} */

let users = () => [] and posts = () => [] and prs = () => []
