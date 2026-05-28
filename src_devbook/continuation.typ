#import "/article": *
#set cite(style: "alphanumeric")
#title[= Continuation and safety]
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
// == Motivation
Forced authentication redirection
```reason 
if (!auth.check()) {
  auth.forceAuth(); }
else {
  setVote((--));
  ...
}
```
Conditionally perform effects
```reason
switch (pType,result){
| ("post",None) => ()
| ("post",r) =>
  Js.Promise.resolve(r)
  >= Model.Decode.Response
    .fetchedComments
  >= ...
}
```

== Continuation-passing style
All of above are examples of _continuation_ @csipl-chap6-cont @csipl-chap7-cps and how they're implicitly tracked. #lorem(50) This can be reified using the concept of _CPS_ (_continuation-passing style_), where #lorem(30)
== Monad for continuation-passing style
```reason
result |> Option.iter @@ r =>
Js.Promise.resolve(r)
>= Model.Decode.Response
  .fetchedComments
>= ...
```
where ```reason Option``` is 
== Literature
Bonsai @bonsai-github is a library for general-purpose reactive programming and with a focus on reactive user interface. It belongs to the same category of reactive-programming libraries like Reason React. One of the central design points of Bonsai is that it has an applicative programming interface. This applicative enforces the concept of incremental computation--through ```ocaml 't Computation.t```--and _generalized side effects_--through ```ocaml 't Effect.t```--which can mean an async operation (```ocaml 't Lwt.t```) or #lorem(10). And users have to use specific let-bindings to write with these applicatives. This applicative-based design is very strict. Therefore, a consequence is that developers require a learning curve to use this library.

#bibliography(title: none, "works.bib")
// vi: set nowrap:
