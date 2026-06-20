#import "/article": *
#import "Vocab.typ" as o
#import "@preview/cetz:0.5.1"
#let header(it) = { text(weight: 700, it) }
#title[= CLI-oriented applications]

#lorem(30)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let window() = rect((0,0), (5,3))
    let play(x: 0, y: 0, w: 0.5, h: 1) = merge-path(scale: 0.5, {
      line((x,y), (x,y+h))
      line((x,y+h), (x+w,y+h/2))
      line((x+w,y+h/2),(x,y))
    })
    let bar() = {
      let cursor(x: 0.2) = rect((x,3-0.3), (x+0.15,3-0.50), fill: color.rgb("#000"))
      rect((0.2,2.4), (4.8,2.8), radius: 0.1)
      content((0.65,2.4), (4.8,2.8), align(horizon, [abc]))
      play(x: 0.35, y: 2.5, w: 0.2, h: 0.2)
      cursor(x: 1.25)
    }
    let dialog() = rect((0.6,0.3), (3.8,2.25))
    bar(); dialog()
  })
]
which is called a _command bar_ #fn[a.k.a. _command palette_], and there is usually an accompanying _pop-down dialog_.

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

== Command specification
#lorem(20). In some other domain, this problem is known as _argument parsing_. There is rich literature in\
  For the developers of #o.bkhack, this particular problem takes root in our experience with programming with Discord commands. #lorem(30)

// vi: set nowrap:
