#import "/article": *
#import "@preview/fletcher:0.5.8"
#lorem(50)

#figure(fletcher.diagram(spacing: (-0.5em,2em), {
  import fletcher: *
  let activity(..args) = {
    node(..args, stroke: 1pt, shape: shapes.rect)
  }
  let initial(..args) = {
    node(..args, stroke: 1pt, shape: shapes.circle)
  }
  let final(..args) = {
    node(..args, stroke: 1pt, shape: shapes.circle)
  }
  let decision(..args) = {
    node(..args, stroke: 1pt, shape: shapes.diamond)
  }
  decision((0,0), `withJwt`, name: <root>)
  activity((1,-2), [Fetch\ with token], name: <fetch-with-token>)
  activity((0,-1), [Force auth], name: <force-auth>)
  edge(<root.east>, "-|>", <fetch-with-token.south>, bend: -45deg)
  initial((-1,1), [Fetch], name: <fetch>)
  edge("u,r", "-|>")
  activity((-1,-2), [Not auth], name: <not-auth>)
  edge("-|>")
  activity((-1,-1.3), [Login], name: <login>)
  edge((-1,-1.3), (-1,0), "-|>", dash: "dashed", bend: -15deg, label: [get server token], label-side: center)
  activity((0,-2), [Invalidation], name: <invalidation>)
  edge(<invalidation.south>, "-|>", <login.east>, bend: 35deg)
  edge(<root.north>, "-|>", <force-auth.south>, bend: -15deg)
  edge(<force-auth.west>, "-|>", <login.east>, bend: -15deg)
  final((1,-3), $k$, name: <k>)
  edge(<fetch-with-token.north>, "-|>", dash: "dashed", <k.south>)
  decision((0,-3), [token is invalid], name: <token-invalid>)
  edge(<token-invalid.south>, "-|>", <invalidation.north>)
}))

#lorem(100)
#lorem(100)
#lorem(100)
#lorem(100)
// vi: set nowrap:
