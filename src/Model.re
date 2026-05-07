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
	module Response = {
		open Js;

		let post = json =>
			post(json) |> Promise.resolve
    
    let fetchedComment = json => 
      fetchedComment(json) |> Promise.resolve

    let fetchedComments = fetchedComments %> Promise.resolve
    
	};
};
module FetchBody = {
  include Js.Json;
  let empty = () => Js.Dict.empty()
  let (^^) = (key:string , t:Js.Json.t) => (dict:Js.dict(_)) =>{
    Js.Dict.set(dict, key, t);
    dict
  }
  let finish = (dict) => (Js.Json.object_(dict))
  let int = number % float_of_int
  let float = number
  let bool = boolean
}

// module Cool = {
//   let ballsack = () => {
//       open Posta;
//       open Js.Json;
//       empty()
//       |> "key2" ^- number @@ 69.
//       |> finish
//     }
// }
