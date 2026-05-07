open Melange__containers.Fun
include Js.Json

let empty = () => Js.Dict.empty()

let (^^) = (key:string , t:Js.Json.t) => (dict:Js.dict(_)) =>{
	Js.Dict.set(dict, key, t);
	dict
}

let finish = (dict) => (Js.Json.object_(dict))

let int = number % float_of_int

let float = number

let bool = boolean
