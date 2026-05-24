#import "/article": *
#let (bkhack) = ([bkhack])
#title[= ML compilers]
For #bkhack, we use Melange as our main JSOO compiler. It's important to understand what went into this decision-making.\
  In ML, _JSOO_ (_JavaScript Of OCaml_) compilers are a class of compilers responsible for realizing OCaml as a target output for the browser platform. #lorem(50)\
  Js\_of\_ocaml is the most mature and popular JSOO compiler. #lorem(40) Dune multiplatform.\
  The Melange compiler is the more recent addition JSOO compiler. #lorem(20) It is easier to use, the binding to JS FFI is more ergonomic. But Dune usage is disparate and modal.

@javierchavarri-jsoo-vs-bucklescript

@javierchavarri-jsoo-bundlesize

#bibliography(title: none, "works.bib")
// vi: set nowrap:
