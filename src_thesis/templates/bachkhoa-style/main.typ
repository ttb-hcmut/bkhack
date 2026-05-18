

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
  text(font: "New Computer Modern", size: 12pt, content)
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
      SPECIALIZED PROJECT:#linebreak()
      #upper(title)#linebreak()
      SEMESTER 251 ACADEMIC YEAR 2025-2026
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
        [],[],align(left)[Cn. Nguyễn Minh Tâm],
        [],[],[],
        [],align(left)[*Reviewer:*],align(left)[#place(bottom,dy:5pt)[`....................`]],
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
        HO CHI MINH CITY, October 2025
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