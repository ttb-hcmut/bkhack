open Quel;
open Quel_sym;

[@alert development("Free querying of data is not fit for production environment.")]
module type S = {
  include SymanticsL';
  type user and post and pr and pr_status = [ `Open | `Closed | `Merged ];

  /** {1 Input / output records} */

	let user : repr(int) => repr(string) => repr(user);
	let post : repr(int) => repr(string) => repr(int) => repr(string) => repr(post);
	let pr : repr(int) => repr(int) => repr(int) => repr(string) => repr(string) => repr(pr_status) => repr(list(string)) => repr(string) => repr(pr);

	/** {1 Projections} */

	module User : {
		let id : repr(user) => repr(int);
		let name : repr(user) => repr(string);
	};

	module Post : {
		let id : repr(post) => repr(int);
		let title : repr(post) => repr(string);
		let creator : repr(post) => repr(int);
		let text : repr(post) => repr(string);
	};

	module Pull_request : {
		let id : repr(pr) => repr(int);
		let post : repr(pr) => repr(int);
		let contributor : repr(pr) => repr(int);
		let title : repr(pr) => repr(string);
		let description : repr(pr) => repr(string);
		let status : repr(pr) => repr(pr_status);
		let tags : repr(pr) => repr(list(string));
		let date_created_utc : repr(pr) => repr(string);
	};

	/** {1 Data sources} */

	let users : unit => list(user);
	let posts : unit => list(post);
	let prs : unit => list(pr);
};

