#let offset-top-1 = 2.0cm
#let offset-top-2 = 0cm
#let offset-bottom-1 = 1.6cm
#let offset-bottom-2 = 0cm

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
  set list(indent: 10pt)
  set page(
    margin: (
      inside: 3cm,
      outside: 2cm,
      top: 2cm + offset-top-1,
      bottom: 2cm + offset-bottom-1,
    )
  )
  text(font: "Times New Roman", size: 13pt, content)
}

#let cover0(title, subtitle) = {
  
  //rectangle box technologia
  place(top+left,dx:-5%,dy: -5%)[
    #rect(height: 110%, width: 110%, stroke: 5pt)
  ]
  place(top+left,dx:-5%+0.5pt,dy: -5%+0.5pt)[
    #rect(height: 110%-1pt, width: 110%-1pt, stroke: 1.5pt +white)
  ]
  
  align(center)[
    #text(size: 14pt, weight: "bold")[
    VIETNAM NATIONAL UNIVERSITY HO CHI MINH CITY#linebreak()
    HO CHI MINH CITY UNIVERSITY OF TECHNOLOGY#linebreak()
    FACULTY OF COMPUTER SCIENCE AND ENGINEERING
    ]
    
    #image("hcmut.png", width: 4cm)
  
    #text(size: 16pt, weight: "bold")[
      REPORT:#linebreak()
      CAPSTONE PROJECT HK252-DATN-328:#linebreak()
      #upper(title)#linebreak()
      SEMESTER 252 ACADEMIC YEAR 2025-2026
    ]
    
    #line(length: 80%)
  
    #text(size: 20pt, weight: "bold", subtitle)
    
    #line(length: 80%)
    
    #text(size:16pt)[
      #table(
        stroke: luma(), // stroke luma balls
        columns: (25%,25%,50%),
        [],align(left)[*Major:*],align(left)[Computer Science],
        
        [],align(left)[*Council:*],align(left)[Department of CSE],
        
        [],align(left)[*Supervisor(s):*],align(left)[Dr. Trương Tuấn Anh],
        [],[],align(left)[MS. Nguyễn Minh Tâm],
        [],[],[],
        [],align(left)[*Reviewer:*],align(left)[#place(bottom,dy:5pt)[MS. Mai Đức Trung]],
      )
    ]
    
    #table(
      stroke: luma(),
      [
        #align(bottom)[
          #stack(dir: ltr)[
            #line(length: 20%)
          ][
            #text(size:16pt)[o0o]
          ][
            #line(length: 20%)
          ]
        ]
      ]
    )
    
    #text(size:16pt)[
      #table(
        stroke: luma(), // stroke luma balls
        columns: (25%,auto,25%),
        align(right)[*Student 1:*],align(left)[Lê Nguyễn Gia Bảo],align(left)[2210216],
        align(right)[*Student 2:*],align(left)[Hồ Gia Tường],align(left)[2252887],
        align(right)[*Student 3:*],align(left)[Lê Công Minh Khang],align(left)[2252295],
      )
    ]
  
  
    
    #align(bottom)[
      #text(size: 16pt)[
        HO CHI MINH CITY, May 2026
      ]
    ]

    #pagebreak()
  ]
}

#let cover1(
  title_,
  subtitle_,
  instructor: none,
  date: datetime.today(),
  version: none,
) = {
  let bold(content) = {
    text(weight: "bold", content)
  }
  align(center)[
    #v(2cm)
    
    #image("hcmut.png", width: 2cm)
    
    #title(bold(upper[Report: Specialized Project]))
     
    #title(bold(upper(title_)))
    
    #text(subtitle_)
    
    #text([Semester 251 — Academic Year 2025-2026])

    #text([Department of Computer Science#linebreak()Ho Chi Minh University of Technology (HCMUT), VNU-HCM])

    #if instructor != none [
      #text([#bold[Instructor:] #instructor])
    ]

    #text(date.display("[month repr:long] [day], [year]"))

    #if version != none [
      #text(bold[Current version: ] + version)
    ]
  ]
}

#let cover = cover0

#let with_header(it) = {
  
  set heading(numbering: "1.")
  
  // Header and footer
  set page(
    header: context[
      #place(
        image("hcmut.png",height:1cm),
        bottom + left, dy: offset-top-2,
      )
      #place(
        [Ho Chi Minh City University of Technology\ 
        Faculty of Computer Science and Engineering],
        bottom + left, dx: 6.5%, dy: offset-top-2,
      )
      #place(
        line(start:(0%,0%),end:(100%,0%)),
        bottom + left, dy:8pt + offset-top-2,
      )
    ],
    footer: context [
      #place(line(start:(0%,-8pt + offset-bottom-2),end:(100%,-8pt + offset-bottom-2)))
      #place(dy: offset-bottom-2, [
        Capstone project report
        #h(1fr)
        Page #counter(page).display("1/1",both:true)
      ])
    ],
  )

  it

}