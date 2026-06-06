#import "/article": *
#import "@preview/cetz:0.5.1"
#let header(it) = { text(weight: 700, it) }
#title[= CLI-oriented applications]

#lorem(30)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let window() = rect((0,0), (5,3))
    let bar() = rect((0.2,2.4), (4.8,2.8), radius: 0.1)
    window(); bar()
  })
]

#lorem(30)

== Literature

// #header[Replit] is #lorem(50)

// #header[GitHub] has a search #lorem(50)

// #header[Fly.io] is #lorem(50)

// wireframe
// https://github.com/stefanjudis/awesome-command-palette

== Languages

// Custom command language
// sh
// PowerShell

// vi: set nowrap:
