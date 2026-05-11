open Melange__containers.Fun

module Post = {
	type t =
		{ author: string
		, message: string
		}
};
module FetchedComment = {
  type t = 
  { id: int
  , text: string
  , user_rating: int
  , rating: int
  , timestamp: string
  , post_vers: int 
  , author_name: string
  , author_id: int
  , author_role: int
  }
}
module FetchedAuth = {
  type t = 
  { user_id: int
  , name: string 
  }
}
module Decode = {
	open Melange_json;

	let post = json => {
		open Post;
		Of_json.
		{ author: json |> field("author", string)
		, message: json |> field("message", string)
		};
	};
  let fetchedComment = json => {
    open FetchedComment;
    Of_json.
    { id: json          |> field("id", int)
    , text: json        |> field("text", string)
    , user_rating: json |> field("user_rating", int)
    , rating: json      |> field("rating", int)
    , timestamp: json   |> field("timestamp", string)
    , post_vers: json   |> field("post_vers", int ) 
    , author_name: json |> field("author_name", string)
    , author_id: json   |> field("author_id", int)
    , author_role: json |> field("author_role", int)
    }
  }
  let fetchedComments = json => {
    json |> Of_json.array(fetchedComment)
  }
  let fetchedAuth = json => {
    open FetchedAuth;
    Of_json.
    { user_id :json |> field("user_id", int)
    , name    :json |> field("name", string)
    }}
	module Response = {
		open Js;

		let post = json =>
			post(json) |> Promise.resolve
    
    let fetchedComment = json => 
      fetchedComment(json) |> Promise.resolve

    let fetchedComments = fetchedComments %> Promise.resolve

    let fetchedAuth = fetchedAuth %> Promise.resolve
    
	};
};
