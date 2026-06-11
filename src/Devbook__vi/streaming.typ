#import "/article": *
#import "./shell-parse.typ"
#let (bkhack, Bkhack) = ([bkhack], [bkhack])
#set text(lang: "vi")
#title[= Lập trình luồng]
#show heading: it => {
  if it.level == 1 {
    set text(size: 0.85em)
    it
  } else if it.level == 2 {
    set text(size: 0.75em)
    it
  } else {
    it
  }
}
Trong hệ #bkhack, #lorem(50)

khái niệm trừu tượng mới. Ví dụ, ta xét lệnh
#align(center)[```sh feed | split -c 10 ```]
trong đó ```sh split```\
  Mục tiêu là giới thiệu, giảng dạy người dùng sinh viên về khái niệm lập trình luồng (stream programming).
= Chính tả
Mục tiêu là giới thiệu, giảng dạy người dùng sinh viên về khái niệm tương tác vỏ-nhân.
== Thuật phân giải
Đôi khi, nhà phát triển có nhu cầu phân giải vỏ ngữ từ một nguồn văn bản. @gr
#place(auto, float: true, scope: "parent")[
  #figure(caption: [Ngữ pháp vỏ ngữ bkhack], shell-parse.langchain) <gr>
]

// vi: set nowrap:
