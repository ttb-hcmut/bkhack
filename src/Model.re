open Melange__containers.Fun

module FetchedPost = {
	type t =
		{ post_id     : int
    , owner_name  : string
    , owner_id    : int
    , title       : string
    , body        : string
		}
};
module PostListItem = {
	type t =
		{
      post_id    : int
    , owner_id   : int
    , owner_name : string
    , title      : string
    , version    : int
    , verified   : bool
    , created    : string
    , updated    : string
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

  let fetchedPost = json => {
    open FetchedPost;
		Of_json.
		{ post_id    : json |> field("post_id"   , int)
    , owner_name : json |> field("owner_name", string)
    , owner_id   : json |> field("owner_id"  , int)
    , title      : json |> field("title"     , string)
    , body       : json |> field("body"      , string)
    }
  }

	let postListItem = json => {
		open PostListItem;
		Of_json.
		{ post_id    : json |> field("post_id"   , int)
    , owner_id   : json |> field("owner_id"  , int)
    , owner_name : json |> field("owner_name", string)
    , title      : json |> field("title"     , string)
    , version    : json |> field("version"   , int)
    , verified   : json |> field("verified"  , bool)
    , created    : json |> field("created"   , string)
    , updated    : json |> field("updated"   , string)
		};
	};
  let postListItems = json => {
    json |> Of_json.array(postListItem)
  }
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

    let fetchedPost = fetchedPost %> Promise.resolve

    let postListItem = postListItem %> Promise.resolve

		let postListItems = postListItems %> Promise.resolve
    
    let fetchedComment = fetchedComment %> Promise.resolve

    let fetchedComments = fetchedComments %> Promise.resolve

    let fetchedAuth = fetchedAuth %> Promise.resolve
    
	};
};
