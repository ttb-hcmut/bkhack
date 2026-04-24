open Quel;
open Quel_sym;

module type S = {
  include SymanticsL;
  type user and pr;

  /** {1 Input / output records} */

	let user : repr(int) => repr(string) => repr(user);
	let pr : repr(string) => repr(string) => repr(string) => repr(pr);

	/** {1 Projections} */

	module User : {
		let id : repr(user) => repr(int);
		let name : repr(user) => repr(string);
	};

	module Pull_request : {
		let id : repr(pr) => repr(string);
		let post_id : repr(pr) => repr(string);
		let title : repr(pr) => repr(string);
	};

	/** {1 Data sources} */

	let users : unit => list(user) let prs : unit => list(pr);
};

module GenSQL = GenSQL;
module Fetch = Exprm__fetch;
