#import "/article": *
#import "vocab.typ" as o
#let prefix_1 = "http://idea:4999/u/bkhack-book"
#let prefix_2 = "https://github.com/ttb-hcmut/bkhack/tree/main/doc"
#let prefix   = prefix_1
#place(top+left, scope: "parent", float: true)[
  #text()[```sh cat bkhack/src_devbook```]
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
