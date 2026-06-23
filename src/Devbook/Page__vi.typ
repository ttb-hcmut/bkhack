#import "/article": *
#import "Vocab.typ" as o
#import "@local/diagramming:0.1.0": colors, kbd
#import "@preview/cetz:0.5.2"
#import "@preview/finite:0.5.1": automaton
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#set cite(style: "alphanumeric")
#let header(it) = text(weight: 700, [#(it)#h(0.2em)])
#title[= Vim motion]

#lorem(50) motions. _text objects_. For example, the primary user flow of Vim, which is
#align(center, {
  let layout = (
    modecmd: (0, 1.8),
    modenormal: (0, 0),
    modevisual: (2.2, 0),
    modeinsert: (0, -2)
  )
  let labels = (
    modecmd: [cmd],
    modenormal: [nrm],
    modevisual: [vi],
    modeinsert: [ins],
  )
  let style = (
    modenormal: (stroke: colors.cream-3, fill: colors.cream-1, radius: 0.5, initial: (anchor: left, stroke: color.rgb("#000"))),
    modecmd: (stroke: colors.cream-3, fill: colors.cream-1, radius: 0.5),
    modeinsert: (stroke: colors.cream-3, fill: colors.cream-1, radius: 0.5),
    modevisual: (stroke: colors.cream-3, fill: colors.cream-1, radius: 0.5),
    modenormal-modecmd: (angle: 0deg, dist: 9pt, curve: 1),
    modenormal-modeinsert: (angle: 0deg, dist: 9pt, curve: 0.5),
    modecmd-modenormal: (angle: 0deg, curve: 0),
    modevisual-modenormal: (angle: 0deg, curve: 0),
    modeinsert-modenormal: (angle: 0deg, curve: 0.5),
  )
  let initial = "modenormal"
  let final = ("modenormal")
  let k = kbd.keys.with(style: kbd.basic)
  automaton(initial: initial, final: final, layout: layout, labels: labels, style: style, (
    modecmd: (modenormal: k(kbd.o.escape())),
    modenormal: (
      modecmd: pad(right: 12pt, $ #k[:], #k[/], #k[?] $),
      modevisual: $ #k[v], #k[V], #k(kbd.o.ctrl-[v]) $,
      modeinsert: pad(left: 28pt, k(([i],[I],[a],[A],[o],[O],[c]).reduce((acc, x) => acc + [] + x)) )),
    modevisual: (modenormal: k(kbd.o.escape())),
    modeinsert: (modenormal: k(kbd.o.escape())),
  ))
})
is exemplary of modal editing, where there is a central liminal mode.

#lorem(15) #kbd.keys(kbd.o.meta-[x]) #lorem(10) #kbd.keys[13gcc] #lorem(30)

```reason
type motion('t) =
  | Enter_mode(motion([> #normal]), 'a) : motion('a)
  | Escape(motion('t)) : motion([> #normal])
```

== User interface

#lorem(20)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let window() = rect((0,0), (6,3))
    let cursor(x: 0.2) = rect((x,3-0.2), (x+0.15,3-0.55), fill: color.rgb("#000"))
    let tt() = content((0.2,3-0.2), (6,3-0.55), align(horizon, text([abc])))
    let modeline() = {
      rect((0.2,0.7), (5.8,1.2))
      content((0.2,0.7), (5.8,1.2), pad(left: 4pt, align(horizon)[buffer-name, line-number]), stroke: none)
    }
    let cmdline() = {
      rect((0.2,0.2), (5.8,0.7))
      content((0.2,0.2), (5.8,0.7), pad(left: 4pt, align(horizon, ```-- MODE --```)))
    }
    window()
    cursor(x: 0.8)
    tt()
    modeline()
    cmdline()
  })
]

where #lorem(30)

== Syntax

#[
  #import "Grammar.typ": *

  #let motion = category[motion]

  #let verb = category[verb]

  #let noun = category[noun]

  #let mult = category[multiplier]

  #let motion_ = Prod(motion, {
    Or[ #verb #optional[ #mult ] #noun ][_Vim motion_]
  })

  #let langchain = bnf(
    motion_
  )

  #place(auto, scope: "parent", float:true)[
    #figure(caption: [Grammar for the Vim motion language], langchain)
  ]
]

== Help
Like #o.bkhack-shell @bkhack:shell-help, Vim motion is considered new knowledge. The user
is encouraged to self-study and explore the knowledge, and it is the
developer's responsibility to provide hints and directions and manuals
.

== Graphical layering

#lorem(20)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let rat = 3/2
    let ghostdiv() = {
      let pos(y) = ((1,0), (3+1,(3/rat)+y))
      rect((1.8,(3/rat)-0.55), (1.8+0.15,(3/rat)-0.2), fill: color.rgb("#000"))
      content((1.2,(3/rat)-0.55), (1.4,(3/rat)-0.2), fill: color.rgb("#000"), text(fill: colors.light-3)[abc])
      rect(..pos(0))
      content(..pos(-1.7), [ghost div])
    }
    let textarea() = {
      let pos(y) = ((0,0.5), (3,(3/rat)+0.5+y))
      rect((0.8,(3/rat)+0.5-0.55), (0.8, (3/rat)+0.5-0.2))
      content((0.2,(3/rat)+0.5-0.55), (0.2, (3/rat)+0.5-0.2), [abc])
      rect(..pos(0))
      content(..pos(-1.7), [textarea])
    }
    let arrow() = {
      line((2.7, 0.8), (3.8, 0.2), mark: (end: ">"))
    }
    ghostdiv(); arrow(); textarea(); 
  })
]

We utilize what we call _ghost divs_ #fn[also known as _display divs_ in some old code]

_twinning_

== Implementation

#header[The basic editor]. This is our first implementation

#header[The markdown editor].

#header[The vim editor].

#bibliography(title: none, "works.bib")

// vi: set nowrap:
