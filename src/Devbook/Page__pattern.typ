#import "/article": *
#import "@preview/cetz:0.5.2"
== Strip pattern
#title[= Design patterns]
#let calc-h(width, R) = (R*width)/calc.sqrt(width*width+calc.pow(R, 2))
#let calc-alpha(width, R) = calc.atan(width/R)
#let piece-width = 0.9;
#let piece-height = 1.8;
given a text `bkhack`, if the four middle letters are censored, the text will be displayed (enlarged) as
#figure(cetz.canvas({
  import cetz.draw: *
  import cetz.angle as angle
  let o(i, it) = "o"+repr(i)+"-"+it;
  let piece(i) = {
    rect((piece-width*i,piece-height), (piece-width*(i+1),0), fill: color.rgb("#000"), stroke: color.rgb("#000"))
  }
  let piece-line(i) = {
    let offset = 0.1
    let drawdiag() = line((piece-width*i - offset, piece-height + offset), (piece-width*(i+1) + offset, 0 - offset), stroke: 5pt+color.rgb("#fff"), name: o(i, "diag"))
    drawdiag()
  }
  let char(i, it) = {
    let offset = 0//0.3
    content((piece-width*i,piece-height - offset), (piece-width*(i+1),0), align(center + horizon, text(size: 44pt, raw(it))))
  }
  char(0, "b")
  // char(1, "k")
  // char(2, "h")
  // char(3, "a")
  // char(4, "c")
  piece(1)
  piece(2)
  piece(3)
  piece(4)
  piece-line(1)
  piece-line(2)
  piece-line(3)
  piece-line(4)
  char(5, "k")
}))
whose structure can be broken down as a sequence of (three) consecutive rectangles, each with a diagonal line, where
#figure(cetz.canvas({
  import cetz.draw: *
  import cetz.angle
  import cetz.decorations
  let piece(i, k: none) = {
    let o(i, it) = "o"+repr(i)+"-"+it;
    let left() = line((piece-width*i,piece-height), (piece-width*i,0), name: o(i, "left"))
    let right() = line((piece-width*(i+1),piece-height), (piece-width*(i+1),0), name: o(i, "right"))
    let top() = line((piece-width*i,piece-height), (piece-width*(i+1),piece-height), name: o(i, "top"))
    let bottom() = line((piece-width*i,0), (piece-width*(i+1),0), name: o(i, "bottom"))
    let drawdiag(k: none, ..style) = {
      let a = (piece-width*i,piece-height);
      let b = (piece-width*(i+1),0)
      let draw(..style) = line(a, b, stroke: 1pt, name: o(i, "diag"), ..style)
      let o = (a: a, b: b, draw: draw)
      if k != none { k(o) } else {
        draw(..style)
      }
    }
    let drawh(..style) = line((piece-width*i,0), {
      let angle = calc-alpha(piece-width, piece-height);
      let h- = calc-h(piece-width, piece-height)
      (piece-width*i + h- * calc.cos(angle), h- * calc.sin(angle))
    }, name: o(i, "h"), ..style)
    let o = (drawh: drawh, drawdiag: drawdiag, top: top, bottom: bottom, left: left, right: right)
    if k != none { k(o) } else {
      top(); bottom(); left(); right(); drawdiag()
    }
  }
  piece(0, k: o => {
    (o.top)()
    (o.bottom)()
    (o.left)()
    (o.right)()
    (o.drawdiag)(k: o => {
      let offset(pair, i) = {
        let (a, b) = pair
        (a+i, b+i+0.2)
      }
      let u = 1.2
      decorations.flat-brace(offset(o.a, -u), offset(o.b, -u), flip: true, outer-curves: 0, name: "d-hint")
      content("d-hint.content", $d$)
      (o.draw)()
    })
    (o.drawh)(stroke: (dash: "dashed"))
  })
  // decorations.flat-brace((-0.1,piece-height), (-0.1,0), outer-curves: 0, flip: true, name: "R-hint", aspect: 75%)
  // content("R-hint.content", $R$)
  content(("o0-left.start", 50%, "o0-left.end"), anchor: "east", padding: 4pt, $R$)
  decorations.flat-brace((0,-0.1), (piece-width,-0.1), outer-curves: 0, flip: true, name: "w-hint")
  content("w-hint.content", [$w = 1$])
  angle.angle("o0-left.start", "o0-left.end", "o0-diag.end", label: $alpha$, radius: 0.5)
  angle.right-angle("o0-h.end", "o0-h.start", "o0-diag.start", label: "", radius: 0.2)
  content(("o0-h.start", 50%, "o0-h.end"), angle: "o0-h.end", anchor: "south", padding: 4pt, $h$)
  piece(1, k: o => {
    (o.top)()
    (o.bottom)()
    (o.right)()
    (o.drawdiag)()
  })
  piece(2)
  piece(3)
  let bound = 99
  line((-bound, 0), (4*piece-width + bound,0), stroke: none)
}))
#lorem(100)
$ alpha = arctan(1/R) $
$ d/R = 1/h $
$ h = R/d = R/sqrt(1+R^2) $\
  where $d = sqrt(1 + R^2)$ due to Pythagoras theorem.
#lorem(100)
#lorem(100)
== BK pattern
// vi: set nowrap:
