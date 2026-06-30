#import "../../config.typ": config as c
#let longJohnson = state("longJohnson",())
#set page(foreground: context{ 
  if("profile" in c.keys() and c.at("profile") == "dev"){none} else {
    if(longJohnson.final().contains(counter(page).get().first())){
      box(
        height: 100%,
        width: 100%,
        fill: tiling(scale(1000%,reflow:true)[#rotate(45deg,reflow:true)[#text(fill: color.linear-rgb(0%,0%,0%,20%))[WIP]]])
      )
    }else{
      none
  }}}
)
#let lorem(length) = {
  context{
    let pagenum = counter(page).get().first()
    longJohnson.update(
        v => (pagenum,..v)
    )
    std.lorem(length)
  }
}