#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: ellipse, parallelogram, diamond, hexagon, brace

#let c = (orange, red, green, blue).map(x => x.lighten(50%))

#let e(pos,name,title) = {
  node(pos,name: name, title, shape: rect)
}

#let entity = e

// Fields of a thing
#let f(pos,name,title,parent) = {
  node(pos,name: name, title, shape: ellipse)
  edge(parent, name, "-")
}

#let field = f

#let k(pos,name,title,parent) = {
  node(pos,name: name, underline(title), shape: ellipse)
  edge(parent, name, "-")
}

#let key = k

#let r(pos,name,title,(p1,t1,f1),(p2,t2,f2)) = {
  node(pos,name: name, title, shape: diamond)
  edge(name, p1, f1, label:t1, label-pos:0.3, bend: if(p1==p2){-10deg}else{0deg})
  edge(name, p2, f2, label:t2, label-pos:0.1, bend: if(p1==p2){10deg}else{0deg})
}

#let relationship = r

// vi: set nowrap:
