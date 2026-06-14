#let signing(content) = {
  align(right, text(style: "italic", content))
}

#let title(content) = {
  text(weight: "bold", size: 2em, content)
}

#let subtitle(content) = {
  text(weight: "medium", size: 1.5em, content)
}

#let doc(content) = {
  set page(columns: 2)
  content
}

#let cover(title_, subtitle_) = {
  [
    #title(title_)
    
    #subtitle(subtitle_)
    
    #pagebreak()
  ]
}

#let with_header(it) = {
  set heading(numbering: "1.")
  it
}