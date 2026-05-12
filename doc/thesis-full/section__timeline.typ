#import "@preview/gantty:0.5.1"

= Timeline <timeline>

== Tasks

We adopt the work-assignment-style diagram @documenting-sa for listing out the tasks that can be done. When available, we group tasks into modules of work. These modules should closely resemble the use case items as seen in @design.

#figure(caption: [Phase one])[
  #table(
    columns: (3cm, 1fr, 3cm),
    table.header([*Module*], [*Task*], [*Developer*]),
    table.cell(rowspan: 3)[Auth. & acc.],
      [Sign up & Log in], [Bao],
      [View account info], [Khang],
      [Edit preferences], [Tuong],
    table.cell(rowspan: 3)[Content consumption],
      [View article], [Bao],
      [List articles, filter feed, search], [Khang],
      [Rate], [Tuong],
    table.cell(rowspan: 3)[Article lifecycle],
      [Article view, create, edit], [Bao],
      [History, diff, log], [Khang],
      [Configure article and permissions], [Tuong],
  )
]

#figure(caption: [Phase two])[
  #table(
    columns: (3cm, 1fr, 3cm),
    table.header([*Module*], [*Task*], [*Developer*]),
    table.cell(rowspan: 3)[Discussion],
      [Create and reply comments], [Bao],
      [Filter and search comments], [Khang],
      [Article referencing], [Tuong],
    table.cell(rowspan: 3)[Issues],
      [Create issue], [Bao],
      [View issue, comments], [Khang],
      [Close issue], [Tuong],
    table.cell(rowspan: 3)[Pull requests],
      [Create issue], [Bao],
      [View pull requests and comments], [Khang],
      [Merge, close pull request], [Tuong],
  )
]

#figure(caption: [Phase three])[
  #table(
    columns: (3cm, 1fr, 3cm),
    table.header([*Module*], [*Task*], [*Developer*]),
    table.cell(rowspan: 3)[Notes],
      [Create Note], [Bao],
      [Edit Note], [Khang],
      [Delete Note], [Tuong],
    table.cell(rowspan: 3)[Moderation],
      [Flag and review content], [Bao],
      [Manage Users], [Khang],
      [Manage tags], [Tuong],
  )
]

#figure(caption: [Cross-cutting])[
  #table(
    columns: (1fr, 3cm),
    table.header([*Task*], [*Developer*]),
      [Inline and Document-based Documentation], [Bao],
      [Inline Unit Tests], [Khang],
      [Build Pipeline], [Tuong],
      [Functional Testing], [Khang],
      [Service Testing], [Bao]
  )
]

== Scheduling

#gantty.gantt(yaml("timeline-1.yml"))
#gantty.gantt(yaml("timeline-2.yml"))
#gantty.gantt(yaml("timeline-3.yml"))
#gantty.gantt(yaml("timeline-4.yml"))