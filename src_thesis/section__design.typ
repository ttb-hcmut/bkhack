#import "templates/kinten-style/usecase_table.typ": *

= Design <design>

== Design goals <design-goals>

In implementing BKHack, it's useful to have design goals in mind. These design goals are mostly derived from our high-level project-wide goals, as discussed in @project-goals, to benefit them as best as possible. They also reflect the personal opinions of our development team and can be used to generally smoothen our decision-making process.

We have kept these constant considerations in mind:

1. Using UX ergonomics, how to direct users to interact with integrity? // TODO(kinten) rephrase this to be more concise
2. How to ensure great maintainability, and reconcile them with performance?
3. In architecture, be direct; or, how to minimize the amount of layering in communication?

For (1). Some examples. Page for discussion takes place after page for viewing article, ensuring that the readers must have read the article first before making decisions.

For (2), we achive by ensuring maximum reasonability and expressiveness in development (e.g. in source code). For example, most diagrams in documentation are coded in domain-specific languages. We discuss more in @technologies-final.

// TODO(kinten) cite sources for the definition of "reasonability" and "expressiveness"

We achieve by various means. We use language-integrated query (LINQ) @linq to embed database queries in frontend -- specifically, we used QueL, a SQL eDSL for OCaml using the tagless-final style of embedding @quel.

For (3), we adopt a service-oriented architecture (SOA) @what-is-soa for our system architecture where our data layer is provided by the Firebase DaaS with several built-in services for authentication.

== Architectural views

In documenting architectures for the BKHack system, we follow the Views and Beyond method @dsa2. By adopting its central advice @dsa2-sub , we've selected and drawn the diagrams in this sections which illustrate the most relevant and important characteristics of our system.

== Use cases

=== Actors

Actors that interacts with the system:
User: Signed-in students and lecturers
Admin: Users with moderation or administrative privileges

// - Identity provider: HCMUT SSO // uhhhh this does not exist in the diagram right now...

// function to generate usecase description
// Im sobbing right now the previously drawn diagram is so detatched from the UC table ToT who in the slop did this (its me)

=== Usecase diagram

==== Authentication & accounts

#figure(
  image("assets/diagrams/UML-usecase-auth&acc.svg"),
  caption: "The use case diagram of authentication & accounts"
)

#figure()[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [Usecase ID], [Name], [Primary Actor], [Goal],
    ),
    [UC01], [Sign up], [User], [Create a new user account], [UC02], [Log in], [User], [Authenticate using credentials or identity provider],
    [UC03], [Log out], [User], [Terminate authenticated session],
    [UC04], [View profile], [User], [View a user profile and activity history],
    [UC05], [Edit profile & preferences], [User], [Update profile details and notification settings],
  )
]

==== Content consumption

#figure(
  image("assets/diagrams/UML-usecase-content_consumption.svg"),
  caption: "The use case diagram of content consumption"
)

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [*Usecase ID*], [*Name*], [*Primary Actor*], [*Goal*],
    ),
    [UC06], [View article], [User], [Read an article post],
    [UC07], [Browse feed], [User], [View personalized or global content feed],
    [UC08], [Filter and search content], [User], [Find content using tags, metadata, or text search],
    [UC09], [Rate content], [User], [Upvote or downvote post, comments, pull requests, or issues],
  )
]

==== Article lifecycle

#figure(
  image("assets/diagrams/UML-usecase-article_lifecycle.svg"),
  caption: "The use case diagram of article lifecycle"
)

// TODO/DONE(kinten+khang) a header wrapper function so that text is bold

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [Usecase ID], [Name], [Primary Actor], [Goal],
    ),
    [UC10], [Create article], [User], [Create a new article post],
    [UC11], [Edit article], [User], [Modify an existing article],
    [UC12], [View revision history], [User], [Inspect past versions of an article],
    [UC13], [View diff], [User], [Compare two versions of an article],
    [UC14], [Revert article version], [User, Admin], [Restore a previous version],
    [UC15], [Change article visibility], [User, Admin], [Change article visibility to common users],
    [UC16], [Modify editorial permissions], [User, Admin], [Modify the editing rights, or role to a specific article of another user],
  )
]

==== Discussions

#figure(
  image("assets/diagrams/UML-usecase-discussions.svg"),
  caption: "The use case diagram of discussions"
)

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [*Usecase ID*], [*Name*], [*Primary Actor*], [*Goal*],
    ),
    [UC17], [Add comment], [User], [Post a comment or reply in a discussion thread],
    [UC18], [Browse discussion], [User], [Navigate threaded discussions with sorting or collapsing],
    [UC19], [Reference article section], [User], [Reference a specific section of the article in discussion],
  )
]

==== Issues

#figure(
  image("assets/diagrams/UML-usecase-issues.svg"),
  caption: "The use case diagram of issues"
)

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [Usecase ID], [Name], [Primary Actor], [Goal],
    ),
    [UC20], [Create issue], [User], [Report a problem or concern with an article],
    [UC21], [View issue], [User], [Read issue details and discussion],
    [UC22], [Close issue], [User, Admin], [Mark an issue as resolved or invalid],
  )
]

==== Pull-requests

#figure(
  image("assets/diagrams/UML-usecase-pr.svg"),
  caption: "The use case diagram of pull requests"
)

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [Usecase ID], [Name], [Primary Actor], [Goal],
    ),
    [UC23], [Create pull request], [User], [Propose changes to an article],
    [UC24], [View pull request], [User], [Inspect proposed changes and diffs],
    [UC25], [Merge pull request], [User, Admin], [Accept and apply proposed changes],
    [UC26], [Close pull request], [User, Admin], [Mark a pull request as resolved or invalid],
  )
]

==== Notes

#figure(
  image("assets/diagrams/UML-usecase-notes.svg"),
  caption: "The use case diagram of notes"
)
#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [*Usecase ID*], [*Name*], [*Primary Actor*], [Goal],
    ),
    [UC27], [Create note], [User], [Create a standalone or referenced note],
    [UC28], [Edit or delete note], [User], [Maintain personal notes],
  )
]

==== Moderation & administration

#figure(
  image("assets/diagrams/UML-usecase-mod&admin.svg"),
  caption: "The use case diagram of moderation & administration"
)

#figure(caption: [])[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: center,
    table.header(
      [Usecase ID], [Name], [Primary Actor], [Goal],
    ),
    [UC29], [Flag content], [User], [Report content for moderator review],
    [UC30], [Review /* Moderate */ content], [Admin], [Review, approve, or take action on flagged content],
    [UC31], [Manage users], [Admin], [Inspect or update user roles and permissions],
    [UC32], [Manage tags and taxonomies], [Admin], [Maintain global classification structures],
  )
]

=== Usecase description
#usecase-desc-table(
  id:[UC01],
  name:[Pull Request],
  dep:[Article],
  desc:[This use case describes how a user proposes, views, edits, and finalizes changes to an existing article through a pull request workflow. A pull request encapsulates proposed modifications, supports review via diffs and discussions, and may be approved, edited, or abandoned by its author.],
  pre:[The user is authenticated and has permission to propose changes to the target article. The target article exists and is accessible to the user.],
  seq:(
    [The user navigates to the pull requests list.],
    [The user optionally applies filters, sorting, or pagination to browse pull requests.],
    [The user selects “create pull request” and enters the pull request editor.],
    [The user edits proposed changes and may preview the rendered result.],
    [The user confirms creation, and the pull request is created and stored.],
    [The user may later view an existing pull request.],
    [The user may inspect the pull request post, associated comments, or the list of changes (diffs).],
    [The author may edit the pull request and confirm the updated version.],
    [The author may approve the pull request, concluding the process.],
  ),
  post:[A pull request is created, updated, or approved. Its state and associated discussions and diffs are persisted and become visible according to permissions.],
  except:(
    ([1],[The user cancels pull request creation, and no changes are saved.]),
    ([2],[The user lacks sufficient permissions, and the action is denied.]),
  ),
  comment:[This use case focuses on the author-side lifecycle. Administrative approval, rejection, or merging is covered in a separate moderation or merge use case.],
)
#figure(caption:[Pull request usecase description])[]
// TODO(kinten) nhờ anh tâm duyệt Use case 

// TODO(kinten) big diagram

== System architecture

The architecture of BKHack was developed with the strategic goal of minimizing communication layering while balancing expressiveness and performance. Determining the system structure requires analyzing the key requirements to identify the architectural characteristics that are most critical for the system's success, and translating those constraints into an appropriate architectural style.

=== Analysis of architectural styles

Before defining the architectural style, it is essential to identify the  characteristics that drive the system's design. For BKHack, a university-integrated social news platform centered on community-sourced knowledge and rigorous revision control, three characteristics emerge as essential for long-term effectiveness and sustainability: modularity, cost effectiveness, and integrity.

*Modularity* refers to the degree to which the software is composed of discrete, independent units. For BKHack, high modularity is crucial because the system integrates distinct functional areas, including user accounts, content posting, complex pull request/revision management, and voting/ranking,. Organizing the codebase into independent components helps support maintainability and extensibility, allowing future integrations or new features to be added without necessitating a full system redesign. Furthermore, achieving high modularity is key to meeting the non-functional requirement that the codebase be organized into modular components and that each major subsystem be implemented as an independent module,.

*Cost effectiveness* dictates that the system must remain economical in terms of development complexity, infrastructure requirements, and maintenance overhead. Given that the platform is designed for internal use within a university, and as a capstone project instead of a commercial product, it does not require the massive, high-latency scalability often associated with globally distributed applications,. Architectural decisions that prioritize simplicity and operational directness naturally keep the overall costs low, which is a necessary trade-off to ensure the system’s viability,.

*Integrity* as a sub-characteristic of security, is defined by the degree to which the software prevents unauthorized access to or modification of software or data. For BKHack, integrity is paramount for maintaining academic credibility. The core feature of the platform is its version-controlled, fact-checking revision and pull request system, which demands that all changes (merges, edits, ownership transfers) be logged for accountability (FR20) and that every edit creates a new, persistently stored version (FR4). Therefore, the architecture must guarantee data validity and consistency in all operations, especially concerning sensitive data like user credentials, which must be hashed and protected (NFR9).

To determine the most suitable architectural style for BKHack, we evaluated candidate architectures against the prioritized characteristics: Modularity, Cost Effectiveness, and Integrity. We considered the core trade-off between monolithic and distributed architectures, recognizing that while monolithic approaches offer simplicity, distributed architectures provide significant gains in performance and scalability.

The layered architecture is a monolithic style defined by organizing components into logical horizontal layers e.g. a set of presentation layer, business layer, persistence layer, and database layer. This style is fundamentally technically-partitioned, grouping components by technical role rather than domain.

Pros:
- Cost effectiveness: This style ranks highly in simplicity and low in cost, making initial development simple and suitable for prototypes.
- Testing is easier because all components run together in a single environment.
- Deployment overhead is low, as the entire system is deployed as one unit.
Cons:
- Modularity: This style scores low in modularity, maintainability, and evolvability.
- Domains are spread across technical layers, which challenges domain-driven design.
- Integrity: The system has a single point of failure, meaning a crash in one part can bring down the entire system, negatively impacting reliability.
- Maintenance is difficult since small changes require rebuilding and redeploying the whole system.

Microservices is a distributed style where each service runs in its own process, embodying high decoupling by physically modeling the logical notion of bounded context. Services are typically fine-grained.

Pros:
- Modularity: The architecture prioritizes and achieves extremely high scores across maintainability, testability, and evolvability due to its decoupled nature.
- Faults are isolated, meaning failures are contained within a single service, contributing to high fault tolerance.
- It supports parallel development, as different teams can work on separate services simultaneously.
Cons:
- Cost Effectiveness: This style ranks lowest in simplicity and highest in cost due to the complexity of system design, deployment, and the high infrastructure required to maintain and monitor multiple services.
- Integrity: Extreme decoupling in this architecture style often leads to challenges with transactional coordination across services. Unlike monolithic systems that rely on ACID guarantees, microservices typically rely on BASE transactions (eventual consistency), which sacrifices data integrity for performance and scalability.
- Network calls are required for communication, which introduces latency and increases operational complexity.

The service-oriented architecture (SOA) is a practical, distributed style recognized for its architectural flexibility, which is achieved through a distributed macro layered structure. It consists of separately deployed coarse-grained domain services and typically utilizes a centrally shared monolithic database.

Pros:
- Integrity: SOA maintains ACID transactions better than other highly distributed architectures because its coarse-grained services use regular ACID database transactions involving commits and rollbacks to ensure database integrity within a single domain service.
- Modularity: Services are domain-partitioned, resulting in good scores for maintainability, testability, and evolvability. This structure offers agility and allows future integrations without full redesign.
- Cost Effectiveness: This style avoids the high complexity and cost associated with fine-grained distributed architectures like microservices. It ranks highly in simplicity and low in cost relative to other distributed approaches.
- It offers high fault tolerance because services are separated, isolating faults to a single unit.
Cons:
- The centralized database, although beneficial for integrity, may pose partitioning challenges in the future.
- It scores lower in scalability and elasticity compared to microservices due to the coarse-grained nature of its services.
- The architecture introduces complexity in deployment compared to monolithic styles, requiring load-balancing capabilities if multiple service instances are needed.

The layered architecture fails to meet the crucial high Modularity and Maintainability goals required.

The microservices architecture achieves maximum modularity but is disqualified due to its excessive Cost and complexity, which conflicts with the goal of Cost Effectiveness for a university-integrated project. Furthermore, microservices' reliance on eventual consistency complicates the assurance of Integrity for critical versioning and transactional data.

The service-oriented architecture style provides the optimal balance required for BKHack: it achieves good modularity and excellent fault tolerance, while maintaining the crucial ACID transactions required for high integrity of the revision control system. Crucially, it accomplishes these benefits at a significantly lower cost and complexity relative to microservices, making it a viable and pragmatic choice for the current scope.

/*
=== System architecture

// TODO(kinten) nhờ cô thái minh duyệt Use case

// TODO(kinten) duyệt Class diagram

// NOTE(kinten) previous related applications have adopted XXX

// TODO(kinten) system arch: Service-oriented architecture.

Our system architecture style is present at @system-arch. It is a hybrid of multi-tier architecture and service-oriented architecture (SOA). Like multi-tier /* TODO(kinten) citation? */, our system is physically distributed into tiers, specifically the front-end tier, the business tier, and the data store tier. Like SOA /* TODO(kinten) citation? */, every component is a service, each service's interface is vendor-independently abstract.

*/

=== Conclusion

The service-oriented architecture architectural style is a logical choice for architecting the BKHack system. During the development of BKHack, we also incorporate elements from other architectural styles, resulting in a hybrid architecture. Currently, BKHack is a multi-tier service-oriented architecture, 

// TODO(hgt): narrate these diagram or something?
// The front-end
// The back-end

#figure(caption: [System architecture of BKHack])[
  #image("assets/diagrams/system-arch.svg")
] <system-arch> // TODOne(khang) turn this into code?

== Entities and relationships

#figure(
  caption: [Concept ER Diagram, in Chen's notation, for the entities and relationships in the BKHack system]
)[
  // #image("assets/diagrams/erd.svg")
  #import "assets/erd.typ": diagram as erdDiagram
#move(
  dx: 0%, 
  dy:-10%,
  erdDiagram
)
  
] // TODO(kinten+khang) help fix

== Architecture of the front-end

// TODO(kinten+hgt) talk about the fact that we use the mvc (model view controller) pattern

// TODO(kinten+hgt) illustration of the mvc data flow

#figure(
  image("assets/diagrams/UML-module_view.svg", width: 15cm),
  caption: [Module view of the front-end system]
) // TODOne(kinten+khang) rewrite

#figure(
  image("assets/diagrams/UML-sitemap.svg", width: 18cm),
  caption: [Sitemap view of the front-end system]
)

// NOTE(kinten) frontend-oriented architecture: Frontend - ~Server~ - Database


== States and interactions of the front-end
This section details the state management and user flow logic for the BKHack front-end.

#figure(caption: [State diagram for user flow during a pull request session])[
  #image("assets/diagrams/PRState.png", width: 11cm)
]

This state diagram describes the user flow and state transitions involved in a pull request session on the BKHack front-end. The interaction begins at the Pull Requests List, which serves as the primary entry point for browsing existing pull requests. Within this list, users can paginate through results and optionally apply or remove filters and sorting criteria, with pagination supported in both the filtered and unfiltered states.

From the list view, users may initiate the creation of a new pull request, transitioning into the Pull Request Edit state. This editing state internally manages two substates: an editor for composing or modifying content, and a preview for viewing the rendered result. Users can freely switch between editing and previewing before confirming creation or edits. Confirmation exits the flow, while cancellation returns the user to the pull request list.

Users may also open an existing pull request from the list, entering the Pull Request View state. This view allows navigation between the main pull request post and its associated changes, such as commits and diffs, while preserving the ability to return to the list. From this state, the author may approve the pull request, terminating the session, or transition back into the edit flow to modify the pull request before confirming the changes.

/*

== Architecture of the back-end

// TODO(kinten) also adopt MVC. Model for domain stuff and dto. View for. Controller for route handlers

== Activity and interactions

// TODO(kinten) activity diagram for pull request and resolution

// TODO(kinten) sequence diagram with `chronos`

*/

== User interface wireframing

=== Analysis

To determine the layout of BKHack, we first analyzed the specific behavioral patterns of our target demographic: HCMUT computer science students and lecturers. Survey results indicated that this audience values citation and credibility factors, often struggling with the fragmented and outdated academic discourse currently dispersed across various informal platforms.

This technical audience is accustomed to the high information density and functional efficiency found in IDEs, technical documentation, and command-line interfaces. Consequently, we determined that BKHack should not be modeled as a marketing-oriented site or a standard social media platform, but rather as an academic knowledge management and dissemination system for those who build and refine ideas.
This realization led us to reject "marketing-heavy" or "mobile-first" layouts in favor of a desktop-first, left-aligned structural approach.

Human reading patterns in technical documentation typically follow a left-to-right scanning habit; therefore, we established that all critical content must be strictly left-aligned to optimize for F-pattern scanning behavior. With these constraints, we arrived at a two-column layout system featuring a 70/30 split. 

The primary 70% area is dedicated to the main content to ensure the "current truth" of a topic remains the focal point, while the remaining 30% is occupied by a toggleable right-side sidebar for supplementary context, allowing users to process primary information before seeking technical metadata. The sidebar is toggleable for the option to minimize distractions and make use of screen real estate when it is needed.

=== Demonstration

The following prototype visualizations demonstrate this layout by stripping away all icons and text elements to showcase the underlying structural hierarchy.

==== Post feed layout prototype

#figure(  
  image("assets/bruhhack/BKHackHomeStripped.png"),
  caption: "The post feed layout of BKHack"
)

The feed is structured to maximize vertical information density, favoring a structure-first layout that mirrors a repository or a wiki rather than an endless scroll.

- Top Navigation Container: A persistent, sticky horizontal bar at the top provides global context and search access regardless of scroll depth.
- Filter and Sort Row: Situated immediately above the content, this block serves as the primary tool for narrowing the scope of information without leaving the page.
- Minimal-Gap Content List: Inspired by GitHub, the primary area consists of stacked rectangular blocks with tight vertical gaps. This reduces visual noise and allows the eye to travel through a large volume of items without interruption.
- Toggleable Right Sidebar: A dedicated block for non-essential navigation that can be collapsed to give content the full width on smaller screens.

==== Post view layout prototype

#figure(  
  image("assets/bruhhack/BKHackPostStripped.jpg"),
  caption: "The post view layout of BKHack"
)

The view page transitions to a document-centric hierarchy, mimicking a structured documentation of an open-sourced software product.
- Header Section: A prominent top block dedicated to essential identifiers to establish the subject immediately. This item is common among the containers for quick identification of the current page.
- Tabbed Navigation Bar: Directly beneath the header, a horizontal row of containers allows users to navigate the multiple aspects of a post, such as articles, discussions, and history without overwhelming the user on a single page.
- Main Body Area: A centered container with a reduced max-width compared to the feed, ensuring a comfortable line length for long form reading.
- Sidebar Metadata Blocks: Smaller containers on the right provide summary status updates and quick actions, keeping them accessible but separate from the core text.

== User interface prototyping <prototype>

// TODO(kinten+hgt) talk about user flows(like figma wireframe sequences)

=== First minimum viable product

#figure(  
  image("assets/BKHackPrototype.jpg"),
  caption: "The initial prototype of BKHack"
)

The initial stage of BKHack’s development involved a wireframe prototype built using Figma. While this environment served its purpose for design validation, the we admits that the earliest iterations were significantly flawed in their execution of the project’s core identity consisting of but not limited to:
- Sterile Aesthetic: The first version was criticized too bland in its use of colors and having neither lack of depth nor sense of hierarchy.
- Lack of Originality: Early designs looked too similar to existing platforms like its direct inspiration HackerNews and Lobste.rs. While these are clean, they did not outwardly reflect the "university CS department intranet" theme the team desired.
- UI Annoyances: Experimental features, such as extreme symbolic notation (e.g., `24c 3i 2pr` for comments and issues), were found to be "annoying to use" and potentially confusing even for initiated users. Overall, it did not deliver on our intended design.
Influence on Later Decisions: These early "failures" were instrumental in shaping the current Design System. The realization that the prototype was too derivative led the team to adopt a Terminal-UI (TUI) aesthetic—specifically inspired by modern tools like the Ghostty terminal—an existing aesthetic that not only fit are criterias, but also ties in quite well thematically.

=== React prototype
Following the initial design phase in Figma, the we developed a second prototype using React, TypeScript, and Tailwind CSS. While the Figma iteration allowed for rapid visual experimentation, the tools provided were rather restrictive in its usage. This second prototype was created to apply the lessons learned previously and decide on a more concrete design.

Despite admitted still being a rough approximation of the final product, it successfully validated several core design pillars, and further presented the design under more rigorous scrutiny.

Ultimately, while the final production application will be implemented in another framework, but this React prototype remains the primary reference for the visual and structural rules that define the BKHack experience.

// TODO(kinten) recapture these screen with GNOME's window decoration

#figure(  
  image("assets/bruhhack/main.png"),
  caption: "The post feed prototype of BKHack"
)

#figure(  
  image("assets/bruhhack/article.png"),
  caption: "The article view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/discuss.png"),
  caption: "The discussion view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/issues.png"),
  caption: "The issue view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/pr.png"),
  caption: "The pull request view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/history.png"),
  caption: "The history view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/edit.png"),
  caption: "The edit view prototype of a post in BKHack"
)

#figure(  
  image("assets/bruhhack/permissions.png"),
  caption: "The permissions view prototype of a post in BKHack"
)
// NOTE(hgt) thiết kế phân tử

// NOTE(hgt) show screens from Figma (?)

// = Foundation
// TODO(hgt) user flow incentives / guiderails
// TODO(kinten) depends if our activity diagram needs this
// Conflict resolution system