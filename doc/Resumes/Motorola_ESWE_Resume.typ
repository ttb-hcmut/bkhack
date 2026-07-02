#import "/article": *
#import "@local/basic-resume:0.1.0": *
#import "@local/diagramming:0.1.0"
#let header(it) = { text(weight: 700, [#it.]) }
#let name = "Le Nguyen Gia Bao"
#let location = "Ho Chi Minh City, VN"
#let email = "gb.ng.25.work@gmail.com"
#let github = "github.com/kinten108101"
#let linkedin = "linkedin.com/in/baole108101"
#let phone = "+84 (903) 066324"
#let personal-site = "baorepo.web.app/~kinten"
#let (fsharp) = ([F\#])
#let csharp = [C\#]
#set page(margin: (top: 1.5cm, bottom: 1.5cm, left: 2cm, right: 2cm))
#let swollen-heading = it => if it.level == 1 {
  set text(size: 0.85em); it
} else if it.level == 2 {
  let c = it.body; text(style: "italic", weight: "regular", size: 12pt, [#c])
} else { it }
#let swollen = it => {
  set heading(numbering: "1.")
  show heading: swollen-heading
  it
}
#let head = {
  let role(it) = text(style: "italic", it)
  let name(it) = text(it)
  (role: role, name: name)
}
#place(top, scope: "parent", float: true)[
  = #(head.name)[Lê Nguyễn Gia Bảo] #(head.role)[Embedded software engineer]
  +84903066324 | kinten108101\@protonmail.com | #linkedin | #github | #personal-site
]
#show: swollen
Learning compiler engineering, embedded programming, and topics in software
engineering.\
  Design object-oriented #fsharp software for data processing and networking of external embedded firmwares (@unity-peripherals). Interacting with Linux drivers in user space. #lorem(30)\
  Design an advanced, highly-abstract, dependency-injected system for remote programming of firmware. #lorem(30)\
  I write architecture documents (@bkhack). This is most prominent in my thesis. #lorem(30)
= Skills
 - #header[Programming languages] OCaml, Reason, #fsharp, #csharp, Elixir, C++, C, Python
 - #header[Natural languages] English (8.0 IELTS, 1540 SAT)
 - #header[Techonologies] Linux, Vim, Emacs
 - #header[Design patterns & programming paradigms] #lorem(20)
 - #header[#lorem(2)] #lorem(20)
= Education
#edu(
  institution: "Ho Chi Minh University of Technology (HCMUT)",
  location: "Ho Chi Minh City, VN",
  dates: dates-helper(start-date: "Aug 2022", end-date: "November 2026"),
  degree: "Bachelor's of Computer Science",
)
 - Relevant Coursework: Data Structures and Algorithms (DSA), Software Engineering, Software Architecture, OOP Programming, Discrete Mathematics, Database Systems, Computer Networking
= Projects & experiences <projects>
#let kind(it) = text(weight: "bold", it)
  #[== 1 Unity Peripherals <unity-peripherals>] #kind[personal project] This is a Unity package for writing and deploying Arduino code from Unity. It is written in #fsharp, utilizing a mix of .NET modules and self-written implementations.\
  #[== 2 Arduino Joy <arduinojoy>] #kind[personal project] This is a driver program written in OCaml. It is a personal project.\
  #[== 3 `bkhack` <bkhack>] #kind[3-person group thesis project] This was my thesis and is an ongoing project: a computer-science-oriented social news website with a home-built full-stack framework. #lorem(60)
#bibliography(title: none, "works.yml")
// vi: set nowrap:
