#import "../../config.typ": config as c
#let wippingit() = {[#square(size: 100000pt,fill: tiling(scale(1000%,reflow:true)[#rotate(45deg,reflow:true)[#text(fill: color.linear-rgb(0%,0%,0%,20%))[WIP]]]))]}
#let longJohnson = state("longJohnson",0)
// #weirdDict.update(v => (,))
#let lorem(length) = {
[
    #context {
      let current_page = counter(page).get().first()
      if("profile" in c.keys() and c.at("profile") == "dev"){
        []
      } else {
      if(longJohnson.get() != current_page) {
          longJohnson.update(v=>current_page)
          place(center, dx:-50%, dy:-50% ,
          wippingit())
          []
      }
    }
  }
  #std.lorem(length)
  ]
}