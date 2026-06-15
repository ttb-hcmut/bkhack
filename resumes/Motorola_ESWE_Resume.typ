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
Learning compiler engineering and topics in software engineering.\
  Design OO #fsharp software for data processing and networking of external embedded firmwares. #lorem(30)\
  Design an advanced, highly-abstract, dependency-injected system for remote programming of firmware. #lorem(30)\
  I write architecture documents. This is most prominent in my thesis. #lorem(30)\
  Interacting with Linux drivers in user space. #lorem(30)
== Skills
 - #header[Programming languages] OCaml, Reason, Elixir, C++, C, Python
 - #header[Natural languages] English (8.0 IELTS, 1540 SAT)
 - #header[#lorem(2)] #lorem(20)
 - #header[#lorem(2)] #lorem(20)
 - #header[#lorem(2)] #lorem(20)
== Education
#edu(
  institution: "Ho Chi Minh University of Technology (HCMUT)",
  location: "Ho Chi Minh City, VN",
  dates: dates-helper(start-date: "Aug 2022", end-date: "November 2026"),
  degree: "Bachelor's of Computer Science",
)
 - Relevant Coursework: Data Structures and Algorithms (DSA), Software Engineering, Software Architecture, OOP Programming, Discrete Mathematics, Database Systems, Computer Networking
== Projects & experiences <projects>
 - _Unity Peripherals_ #lorem(60)
 - _Unity.FSharp.Formatting_ #lorem(30)
 - _`bkhack`_ #lorem(60)
== Further reading
This resume is available at
#align(center)[
  #let u = "https://baorepo.web.app/~kinten/3ea81"
  #link(u, u)
]
which contains #lorem(20)
#bibliography(title: none, "works.yml")
// vi: set nowrap:
