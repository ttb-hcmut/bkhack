#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: ellipse, parallelogram, diamond, hexagon, brace
/// Add an Entity node to the diagram
/// 
/// ```example
/// #e((0,0),<User>,[Site User])
/// ```
///
/// - pos (array): Coordinates of the Entity node
/// - name (label): Label used in place of coordinates for identification in other functions
/// - title (content): Content displayed in the Entity node
/// -> 
#let e(pos,name,title) = {
  node(pos,name: name, title, shape: rect)
}
/// Adds an Attribute node to the diagram
/// 
/// ```example
/// #f((0,0),<timestamp>,[date_created])
/// ```
///
/// - pos (array): Coordinates of the Attribute node
/// - name (label): Label used in place of coordinates for identification other functions
/// - title (content): Content displayed in the Attribute node
/// - parent (label,array): The node this Attribute belongs to
/// -> 
#let f(pos,name,title,parent) = {
  node(pos,name: name, title, shape: ellipse)
  edge(parent, name, "-")
}
/// Adds an Key Attribute node to the diagram
/// 
/// ```example
/// #f((0,0),<timestamp>,[date_created])
/// ```
///
/// - pos (array): Coordinates of the Attribute node
/// - name (label): Label used in place of coordinates for identification other functions
/// - title (content): Content displayed in the Attribute node
/// - parent (label,array): The node this Attribute belongs to
/// -> 
#let k(pos,name,title,parent) = {
  node(pos,name: name, underline(title), shape: ellipse)
  edge(parent, name, "-")
}
/// Adds an Relationship node to the diagram
/// 
/// ```example
/// #r((0,0),<works_at>,[Works at],(<User>,"N","="),(<Company>,"1","-"))
/// ```
///
/// - pos (array): Coordinates of the Relationship node
/// - name (label): Label used in place of coordinates for identification other functions
/// - title (content): Content displayed in the Relationship node
/// - _ (array): One side of the relationship, in the format of an array (node, "1" | "N" , "-" | "=" )
/// - _ (array): The other side of the relationship, in the format of array (node, "1" | "N" , "-" | "=" ). If the two nodes are the same, then the edge connecting them with the Relationship node will be curved
/// -> 
#let r(pos,name,title,(p1,t1,f1),(p2,t2,f2)) = {
  node(pos,name: name, title, shape: diamond)
  edge(name, p1, f1, label:t1, label-pos:0.3, bend: if(p1==p2){-10deg}else{0deg})
  edge(name, p2, f2, label:t2, label-pos:0.1, bend: if(p1==p2){10deg}else{0deg})
}

