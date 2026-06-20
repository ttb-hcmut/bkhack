#import "Diagramming__colors.typ" as colors
#import "Diagramming__kbd_common.typ" as o

/// This function returns a keyboard key element
///
/// ```example
/// #key([Ctrl])
/// #key("Alt")
/// ```
/// 
/// - c (string,content): The label of the key
#let key(c) = {
  text(font: "Liberation Serif", c)
  if style == "fancy" {
    box(
      box(c, stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff")),
      stroke: colors.cream-2 + 1pt, radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: colors.cream-2
    )
  } else if style == "flat" {
    box(c, stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff"))
  } else if style == "basic" {
    box(
      box(c, radius: 2pt, inset: (left:0pt,right:0pt), outset: (top:2pt,bottom:2pt), fill: none),
      radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: none
    )
  }
}

#let fancy(c) = {
    box(stroke: colors.cream-2 + 1pt, radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: colors.cream-2,
      box(stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff"), c))
}

#let flat(c) = {
    box(stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff"), c)
}

#let basic(c) = {
    box(radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: none,
      box(radius: 2pt, inset: (left:0pt,right:0pt), outset: (top:2pt,bottom:2pt), fill: none, c))
}

/// This function returns a Combination of keyboard key elements and typed commands
///
/// ```example
/// #keys(meta-[x],cmd("package-refresh-contents"),ret())
/// ```
/// 
/// - k (string,content): The label of the key combos where string arguments are displayed as plain text and content is displayed as keyboard key element
/// - style ((content => content) = flat): Something
#let keys(style: flat, ..k) = {
  let cs = for c in k.pos() {
    if type(c) == content { text(font: "Liberation Serif", c) }
    else { text(c) }
  }
  style(cs)
}

// vi: set nowrap:
