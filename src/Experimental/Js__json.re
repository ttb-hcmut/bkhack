include Js.Json
open Melange__containers.Fun
let decodeArrayExn = Option.get % decodeArray
and decodeNumberExn = Option.get % decodeNumber
and decodeStringExn = Option.get % decodeString
and decodeBooleanExn = Option.get % decodeBoolean
and decodeObjectExn = Option.get % decodeObject

