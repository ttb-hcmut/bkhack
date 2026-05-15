#import "/article": *
#let (bkhack, Bkhack) = ([bkhack], [bkhack])
#title[= Parsing techniques]
== Parser generator
When using parser generator, there is an emphasis on decomposition and
reusability. By decomposition, I mean that the parsing process is split
into two: the _lexing_ stage (a.k.a. character grouping) and the _parsing
_ stage; a more detailed pipeline can be found in Phan Thi Tuoi's compilation
@giao-trinh-trinh-bien-dich. By reusability, I mean that we interpret
the parsing process in terms of intermediate forms (e.g. the abstract
syntax tree), so that the parsing process is simply a multiple of
transformation steps, and each step can be branching checkpoint to
produce other kinds of outputs.
== Hand-written parser
== Fused parser
== PPX-based parser
where PPX stands for _preprocessing extension_.
#pagebreak()
From another dimension, it's important to grasp the _parsing model_.
#lorem(50)
== Parsing using regular expression
== Parsing using parser combinators
== Parsing in the #bkhack shell implementation
== Reference
#bibliography("./works.bib", title: none)
