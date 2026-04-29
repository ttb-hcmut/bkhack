open Quel;
include Quel_sql.GenSQL;

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
