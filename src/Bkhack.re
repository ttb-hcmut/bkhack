module Fetch = Bkhack__fetch
module React = Bkhack__react
module Experimental = Bkhack__experimental
module Effect = Bkhack__react.Effect
module Js = {
	include Js
	module Json = {
		include Json
		open Melange__containers.Fun
		let decodeArrayExn = Option.get % decodeArray
		and decodeNumberExn = Option.get % decodeNumber
		and decodeStringExn = Option.get % decodeString
		and decodeBooleanExn = Option.get % decodeBoolean
	}
}
