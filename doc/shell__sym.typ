#import "@preview/curryst:0.6.0": rule, prooftree, rule-set

#let app(a, b, c) = { a(b(c)) }

#let rule_0(..a, b) = {
  [
    #prooftree(rule(..a, b))
  ]
}

#let nil = rule_0(
  name: [Zero],
  $ "nil" () : "Program" T $
)

#let cons = rule_0(
  name: [Cons],
  $ x : "Cmd" T $, $ x' : "Program" T $,
  $ "||"(x, x') : "Program" T $
)

#let program = rule_0(
  name: [Substitute],
  $ t : "Program" A $,
  $ "$%"(t) : "Cmd" A $
)

#let v = [
  #columns(2)[
    #nil #colbreak() #cons
  ]
  #columns(2)[
    #program #colbreak() 
  $
  prooftree(
    rule(
      name: "Observe",
      t : "Program" A,
      "obs"(t) : A
    )
  )
  $
  ]


]

// vi: set nowrap:
