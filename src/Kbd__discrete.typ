#import "Colors.typ"

#let key(c) = {
  box(
    box(c, stroke: colors.cream-2 + 1pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: colors.cream-1),
    stroke: colors.cream-2 + 1pt, radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: colors.cream-2
  )
}

#let keys(..k) = {
  let c = {
    for c in k.pos() {
      if type(c) == content [
        #key(c)
      ] else [
        #text(c)
      ]
    }
  }
  box(
    c
    , radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:4pt,bottom:5pt), fill: rgb("#EEEEEE")
  )
}

// vi: set nowrap:
