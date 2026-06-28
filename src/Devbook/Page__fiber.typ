#import "/article": *
#import "Paper.typ" as paper
#import "Vocab.typ" as o
#import "@local/diagramming:0.1.0"
#import "@preview/cetz:0.5.2"
#show: paper.doc
#title[= Sewing in-browser parallelism and more with fibers]
Since #o.bkhack is deployed to the browser, an algebra was a much
-needed abstraction for parallelization using Workers. We introduced
*`fiber`* as a library that implements structured concurrency--a concurrency
algebra for internal #o.bkhack modules. It is an extension of JavaScript
Promise equipped with _control capabilities_ i.e. to cancel and perform
group actions.\
  For its design, we want the programming interface to be not only lean
--where it should wraps over Worker as straightforwardly as possible--
but also expressive--where programming patterns can be achived as
straightforwardly logical for the human programmer as possible. Our
fiber heavily uses the concept of object algebra @extensibility-for-the-masses
in the form of a _ctrl_ (pronounced "controller") to both manage fibers
transparently and provides a dictionary of encoder-decoder functions
at call-site. Assume we're writing a small program to compute self-exponential with
interactions with a reactive-programming system. Given a staged code
$k$ defined by
#let let_(ext: none) = {
  if ext == none { $"let" #h(2pt)$ } else {
    show math.star: it => text(size: 16pt, it)
    $"let"_#ext$
  }
  h(2pt)
}
#let mkbox(inset: 0em, p) = context box(inset: inset, {
  cetz.canvas({
    import cetz.draw: *
    let p-length = measure(p)
    cetz.decorations.brace((-0.17, 0pt), (-0.17, p-length.height + 1pt))
    content((0, 0), (p-length.width, p-length.height), name: "ds", p)
  })
})
#let promise-star = text(fill: diagramming.colors.yellow-2, math.star)
$
&#let_(ext: $"Fiber".#text(fill: diagramming.colors.cream-3,"bind")$) k = (f, n) =>\ &#v(-1em)\ 
&#mkbox(
  $
  &#let_(ext: promise-star) (dot) = "Lam"."app"(n^n-2n+1, f)\ &#v(-1em)\ 
  &"return" n
  $)
$

// #[
// #set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
// ```reason
// let%Fiber.bind k = (f, n) =>
//   { let* () = Lambda.app(n*n, f)
//     return@@n }
// ```
// ]
it's possible to run $k$ as a background thread in the form of a continuation
. So,

$
&#box($
  &#let_() #math.italic("ctrl") &&= "Fiber"."create"(dot)\ &#v(-1em)\ 
  &"and" f                      &&= i => "return" "setCount"("_" => i)
$)                                               \ &#v(-1em)\ 
&#let_(ext: promise-star) italic("result") =     \ &#v(-1em)\
&#h(8pt)"Promise"."all" "Iter"."range"(1000, n =>\ &#v(-1em)\
&#h(8pt)"Fiber"."With-ctrl"."run"_2(#h(-1pt)~#h(-0.5pt)italic("ctrl")\ &#v(-1em)\
&#h(8pt)italic("ctrl")#h(-1pt)->#h(-1pt)"Fiber"."lam"(f), n, k))
$



// #[
// #set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
// ```reason
// let  ctrl = Fiber.create()
// and  f = i => return@@setCount(_ => i)
// let* result =
//   Promise.all@@Iter.range(1000, n =>
//   Fiber.With_ctrl.run2(~ctrl,
//   ctrl->Fiber.lambda(f), n, k))
// ```
// ]
\. Notice that $italic("ctrl")$'s algebra contains
at least a lambda-like $"lambda"$ which was used to wrap the effect-ful
callback $f$, and a zoo of other terms.
// #[
// #set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
// ```reason
// let%Fiber.bind k' = (_, n: int, setCount: lambda(int, unit)) : result(unit) =>
// Promise.Syntax.({
//   let open Fiber
//   Promise.Iter.range(0,~n,i => switch(i){
//     | i when i mod 100 != 0 => return(())
//     | i => 
//     let* () = setCount->Lambda.apply(i)
//     return(())
//   })
// })
// ```
// ]
// == Related works
// Unlike most solutions in the ecosystem, `fiber` offers a more opaque
// interface.
// Dune's `fiber`. The Cancel module. #lorem(10) Eio's Fiber.  #lorem(10)
== Design
  The _module layer_.\
  The _ppx layer_.\
  The _code extraction & generation layer_
#cetz.canvas({
  import cetz.draw: *
  let b-width = 1
  let b-height = 1
  let root = (anchor: (x: 0, y: 0))
  let room(o, name: none, left: none, right: none) = {
    rect(o.anchor, (o.anchor.x+b-width,o.anchor.y+b-height), name: name+"-rect")
    content(name+"-rect", name)
    if right != none {
      let newroot = (anchor: (x: o.anchor.x+1, y: o.anchor.y))
      right(newroot)
    }
  }
  room(root, name: "main", right: o => {
    room(o, name: "hall")
  })
})
#lorem(150)
#bibliography(title: none, "works.bib")
// vi: set nowrap:
