include (module type of Fetch);

module Syntax : {
  let ( >>= ): (Js.promise('a), 'a => Js.promise('b)) => Js.promise('b);
  let ( >!= ):
    (Js.promise('a), Js.Promise.error => Js.promise('a)) => Js.promise('a);
  let return: 'a => Js.promise('a);
  let ( let* ): (Js.promise('a), 'a => Js.promise('b)) => Js.promise('b);
};
