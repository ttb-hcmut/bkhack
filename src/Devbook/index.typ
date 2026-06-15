#import "/article": *
#import "@local/diagramming:0.1.0"
#import "vocab.typ" as o
#let prefix_1 = "http://idea:4999/u/bkhack-book"
#let prefix_2 = "https://github.com/ttb-hcmut/bkhack/tree/main/doc"
#let prefix   = prefix_1
#diagramming.paper.single_page(() => [
  warning: content is WIP
])
#place(top+left, scope: "parent", float: true)[
  #text()[```sh cat bkhack-book```]
  #v(-12pt)
  = #o.bkhack developer handbook

  #v(140pt)


  #pad(left: -100pt)[
    #rotate(30deg)[
      #square(width: 600pt, height: 600pt)
    ]
  ]
]


// vi: set nowrap:
