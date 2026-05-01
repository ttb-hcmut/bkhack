type test and app and firestore and firestore_collection and firesql;

type ref_;

module Lowlevel = {
	[@mel.module "@firebase/firestore"] external firestore : test = "default";
	module App = {
		module Config = {
			type t =
			{ apiKey: string
			, authDomain: string
			, projectId: string
			, storageBucket: string
			, messagingSenderId: string
			, appId: string
			}
		}
		[@mel.module "@firebase/app"] external init : Config.t => app = "initializeApp";
	}

	module Firestore = {
		[@mel.module "@firebase/firestore"] external get : app => firestore = "getFirestore";
		[@mel.module "@firebase/firestore"] external collection : firestore => string => firestore_collection = "collection";
		module Document(E : { type spec }) = {
			[@mel.module "@firebase/firestore"] external add_doc : firestore_collection => E.spec => Js.promise(ref_) = "addDoc";
			[@mel.get] external id : ref_ => string = "id";
		}
	};

	module FireSQL = {
		[@mel.module "firesql"] [@mel.new] external make : test => firesql = "FireSQL";
	}
};

[@mel.send] external firesql_query : (firesql, string) => Js.promise(list(Js.dict(string))) = "query";

let test = init => Lowlevel.({
	let app = App.init(init);
	let db = Firestore.get(app);
	let module X = { [@warning "-69"] type spec = { name : string } };
	let module Users = Firestore.Document(X);
	Fetch__syntax.({
		let* docRef = Firestore.collection(db, "users") -> Users.add_doc({ name: "ok" });
		Js.Console.log(Users.id(docRef));
		return()
	})
})
