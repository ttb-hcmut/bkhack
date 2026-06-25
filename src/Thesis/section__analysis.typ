= Analysis <analysis>

== Related systems — state of the arts

// NOTE(kinten) compare technicalities

At Bach Khoa, the LMS system provides a forum discussion feature where, per course, lecturer and course owners can create forums, and students and course participants can create threads and submit posts into these threads whose topics are the scope of the current containing course.

Outside of Bach Khoa, there are social news websites oriented towards computer science, such as Hacker News @hacker-news, and Lobsters @lobsters. However, these do not tailor to the university's specific ecosystem and community conventions.

=== Hacker News

#figure(  
  image("assets/hackernews-logo.png"),
  caption: "Hacker News Logo. Source: http://news.ycombinator.com"
)

#figure(  
  image("assets/hackernews-item.png"),
  caption: "Hacker News Item. Source: window capture at https://news.ycombinator.com/item?id=27334065"
)
/*
// Description

Hacker News, launched in 2007 by Paul Graham and operated by Y Combinator, is a minimalist link aggregation and discussion platform centered on technology, startups, and computer science. Content visibility is determined through a voting system.

// Analysis.

Strengths: Highly relevant to computer science and technology; lightweight UI/UX; effective popularity ranking system based on community votes.

Weaknesses: Broad global audience with no specific focus on university communities; includes sections irrelevant to HCMUT (e.g., startup hiring); moderation policies oriented toward industry rather than academia

*/

Hacker News, operated by Y Combinator, serves as a lightweight, text-oriented community for sharing and discussing technology-related topics @hacker-news.

Hacker News's voting-based system naturally promotes popular or timely information, which helps highlight trending developments in computing and research. Yet this same mechanism emphasizes immediacy over persistence: posts lose visibility as new content arrives, and older discussions, even when still relevant, fade from attention. As a result, while the platform excels at capturing current discourse, it offers no structured means to preserve or revisit evolving technical understanding — a limitation when reliability and academic continuity are desired.


// pros: great for highlight trending topics
// cons: posts lose visibility fast
// fix: PR system encourage maintenance of old posts
=== Lobsters

#figure(  
  image(width: 1.5cm, "assets/lobsters-logo.svg"),
  caption: "Lobsters Logo. Source: https://github.com/lobsters/lobsters/tree/master/app/assets/images"
)

#figure(  
  image("assets/lobsters-item.png"),
  caption: "Lobsters Item. Source: window capture at https://lobste.rs/s/izp0oj/terra_low_level_counterpart_lua#c_fthxci"
)

/*
// Description

// Analysis.

Strengths: Strong emphasis on technical content; rich tagging and categorization system; smaller-scale community similar to the intended scope of BKHack.

Weaknesses: Moderation is heavily manual, requiring dedicated oversight; designed for a global technical community, not tailored to academic institutions or student contexts

*/

Lobsters, launched in 2012 by Joshua Stein, is a link aggregation and discussion site similar to Hacker News, but with a stronger focus on technical topics and community curation @lobsters. It features a robust tagging system and supports a smaller, tight-knit community.

Lobsters provides a more tightly moderated environment for technical discussion, emphasizing depth and accuracy within a smaller community. Its tagging system improves organization and helps participants focus on specialized areas of computing. Still, the community’s small scale and relative obscurity limit both visibility and diversity of perspectives. Like many social discussion systems, its content stream is chronological and transient, making earlier exchanges difficult to trace once new discussions dominate. Despite stronger curation compared to larger platforms, information there still risks becoming stale or contextually detached as technologies progress.


// pros: environment for technical discussion, emphasizing depth and accuracy
// cons: Very tight moderation leading to very small, closed community, lacks perspective
// little moderation and using issues and other features to fix misinformation

// TODO(kinten) === Lambda The Ultimate

// TODO(kinten) another inspiration is Steam Underground, but it's not very legal isn't it

=== HCMUT LMS course-based forums

#figure(
 image("assets/lms-item.png"), 
 caption: [A discussion forum thread on HCMUT LMS. Source: window capture at https://lms.hcmut.edu.vn/mod/forum/view.php?id=500327]
)

The Learning Management System at HCMUT (HCMUT LMS) provides optional course-specific discussion forums where lecturers and students can exchange questions, explanations, and course materials.

HCMUT LMS integration within the academic infrastructure ensures that discussions are relevant to course objectives and directly connected to ongoing instruction. However, such forums may not be provided, and once a course concludes, access to its forum content typically ends, leaving valuable insights inaccessible to future students. Because conversations are confined to individual courses without interconnection or global indexing, information quickly becomes outdated or redundant, and institutional memory of technical discussion is lost over time.

// pros: integrated with the uni
// cons: some information/forum discussion is lost once the class ends, info becomes outdated
// no class no end, so posts and discussions lasts forever


=== Reddit

#figure(
  image("assets/reddit-logo.svg", width: 3cm),
  caption: [Reddit Logo. Source: https://redditbrand.lingoapp.com/a/Reddit-Logo-Wordmark-OrangeRed-Ye1vjW?asset_token=a-o7nPpp4qchR8xJmiWfZh7CaBCdzEjJPGMNUlYE8Dw&v=41]
)

#figure(
  image("assets/reddit-item-1.png"),
  caption: [A discussion thread in a Reddit group discussing the programming language OCaml. Source: window capture at https://www.reddit.com/r/ocaml/comments/4ngcb7/the_o_in_ocaml/]
)

Reddit is one of the largest online community platforms, hosting numerous sub-communities (subreddits) across diverse domains @reddit. Its familiar interface and interaction mechanisms make it widely accessible and easy to use.

// Reddit hosts a vast range of communities across nearly every subject, including computer science and academia.

Reddit's subreddit model encourages topic segregation, while familiar interaction patterns make engagement simple. However, the platform prioritizes breadth and user activity rather than long-term knowledge retention. Threads surface and sink according to short-term interest, and technical discussions often become buried under social noise. Since moderation and quality standards vary widely across communities, accuracy and context depend heavily on individual contributors. Information is therefore prone to obsolescence, and the lack of institutional framing limits academic applicability.


/*
=== Our system

BKHack builds upon the lessons of these systems by combining academic focus with sustained information reliability. It is designed to aggregate technical discourse within the university while preventing the loss or decay of valuable knowledge over time. Unlike social networks where discussions quickly fade, or course forums where data expires with the semester, BKHack aims to keep academic conversation current, traceable, and accessible. By situating discussion within an institutional and community-driven framework, it addresses the fragmentation and obsolescence that characterize existing platforms, ensuring that computer science knowledge remains both alive and verifiable within HCMUT’s academic ecosystem.
*/

/*

Reddit is one of the largest online community platforms, hosting numerous sub-communities (subreddits) across diverse domains. Its familiar interface and interaction mechanisms make it widely accessible and easy to use.

For its strengths, Reddit is a highly scalable system; flexible community-building features; familiar UX patterns that ease adoption. It has sub-communities to separate by discussion topic, a tagging system for further specificity.

However, Reddit as a system is too broad and unfocused, with communities across all possible topics; moderation and governance vary widely by community; no alignment with HCMUT’s academic and cultural context. Lack of advanced functionality for a technical audience like regex, (short navigation philosophy: not having to go through too many menus, functions hidden under context menus, having to go through in-betweens), etc. Not making efficient use of UI/screen space, too much fluff

*/

/*
// Description
Reddit has a tagging system within its communities to separate content posted
// Analysis
We might want BK news to have such tagging system to curate a personalized stream of knowledge and news relevant to the user
// NOTE(kinten) The cons are outside of HCMUT
Reddit has a focus on building communities around different topics, where as our platform will only be focusing on Tech and Computer Science

*/

=== Facebook pages and groups
/*
// Description

Many HCMUT students rely on Facebook groups and pages for course-related updates, informal discussions, and information sharing. These groups are community-driven, with varying levels of moderation and content organization.

// Analysis

Strengths: High adoption rate among students; real-time updates; familiarity of interface.

Weaknesses: Content is unstructured and easily lost in timelines; limited search and categorization tools; heavy reliance on third-party platform outside university control; lacks academic focus.
*/
#figure(  
  image("assets/f_logo_RGB-Blue_1024-3274466492.png", width: 2cm),
  caption: "Facebook Logo. Source: https://facebook.com"
)

#figure(  
  image("assets/facebook.png"),
  caption: "A Facebook community for HCMUT Students. Source: window capture at https://www.facebook.com/groups/hcmut.k22"
) // TODO(kinten) screenshot style

Among HCMUT students, Facebook groups remain one of the most commonly used tools for coordination, peer support, and information sharing. They benefit from high participation rates and instant notifications, allowing quick dissemination of updates or advice. Yet their structure is entirely social: posts appear chronologically and are rapidly displaced by newer content, leaving older discussions nearly unrecoverable. Search functions are limited, and without formal categorization or validation mechanisms, important information can become outdated or lost in casual conversation. Furthermore, as these groups exist outside university oversight, data persistence and academic reliability cannot be guaranteed.

=== X (formerly Twitter)
#figure(  
  image("assets/x-social-media-black-icon-2425700883.png", width: 1.5cm),
  caption: "X (formerly Twitter) Logo. Source: http://x.com"
)
#figure(  
  image("assets/twitter.png"),
  caption: "An X (formerly Twitter) page with community note. Source: window capture at https://x.com/Diddy/status/1732457807255847165",
) // TODO(kinten) screenshot style
/*
// Description
Twitter is a social media where users can post their thoughts, media, or news about anything in the world.
On twitter there is a community driven form of fact checking called Community Notes, where contributors can leave notes of context, correction or sources of information, and if it gains enough approval from a wide range of contributors it will be attached under the original post

// Analysis

Strengths: Helps with fighting misinformation by the power of the community

Weaknesses: It lacks a bit of elegance by the need to append fixes and correction to the post, and does not promote having the notes change over time in response to new context or information.
*/

X (formerly Twitter) is a social media where users can post their thoughts, media, or news about anything in the world @twitter

X’s Community Notes feature introduces a collaborative approach to context correction, allowing users to append clarifications or sources to existing posts. This approach effectively mitigates misinformation by letting the community annotate content collectively. However, the added notes remain static once approved; they supplement rather than update the original post. Over time, even corrected content may become misleading as the surrounding context evolves. While the feature demonstrates the value of community-driven accountability, it does not ensure sustained relevance of information — a critical factor in technical and academic discourse.


=== Wiki.gg

/*
// Description

Wiki.gg is a community ran wikipedia for information about specific games. As it is ran by the community, when new information is available, the information page can be edited to include the latest information, and is kept track of by a revisions page containing all the previous edits and versions of a page
*/

#figure(  
  image("assets/wikigg.jpg", width: 5cm),
  caption: "wiki.gg Logo. Source: https://wiki.gg"
)
#figure(  
  image("assets/wikigg.png"),
  caption: "A community wiki made in wiki.gg. Source: window capture at https://deadcells.wiki.gg/"
) // TODO(kinten) description

// TODO(kinten) maybe a separate screenshot showing history revisions page

Wiki.gg is a community-run wikipedia primarily used for maintaining detailed documentation of media from various communities @wikigg.

Its structure supports continual content improvement and consistent referencing, helping to preserve the accuracy of technical material. However, its design emphasizes static documentation rather than active discussion. As a result, updates depend on contributor initiative rather than real-time dialogue, and information can lag behind current understanding. Although it succeeds in maintaining structured knowledge, it does not address the social dynamics of discussion or the need to contextualize information as it ages.

=== Conclusion
// Similarities: These are all platforms that are hubs of information, each with their own strengths:
// - HackerNews: a link aggregation tech news site that allows users to discuss and be directed to the articles.
// - Lobsters: a similar link aggregation site that focus on the more technical side of IT and a rich tagging system and caters to a small dedicated community.
// - Reddit: A well known and beginner friendly site consisting of forums for a wide range of communities.
// - Facebook pages and groups: Widely used by everyone and is often the go-to event planning while still being a social media site.
// - Twitter's community notes: Community driven fact-checking and source linking.
// - Wiki.gg's editorial features: Allows posts to be corrected and change in the presence of new information.

// We think that these features would be something that would help us achieve our goal of creating the perfect tech and CS information and discussion site.

All of these platforms act as centers for sharing and discussing information, each with its own strengths and focus areas:

- HCMUT LMS is a system integrated with HCMUT's ecosystem and a university's academic context;
- Hacker News is a technology-focused link aggregation site where users share and discuss articles related to startups, programming, and industry news;
- Lobsters is a similar link-sharing platform that focuses more on the technical side of computing with a detailed tagging system;
- Reddit is a well-known and beginner-friendly platform built around topic-based communities (subreddits), allowing discussion across a wide range of interests;
- Facebook pages and groups are popular across many audiences, Facebook combines social networking with tools for event planning and community building;
- X (formerly Twitter)’s community noting is a community-based feature that helps fact-check posts and add reliable context with linked sources;
- Wiki.gg has editorial features that allow collaborative editing so users can update or correct content as new information becomes available.

Together, these platforms demonstrate different ways of building community-driven spaces for information sharing and discussion. Their individual strengths—such as open conversation, collaboration, and shared moderation will guide our own approach to creating an effective platform to serve the HCMUT students and lecturers.

// pros: 
// cons: outside of HCMUT

// NOTE(kinten) should we include internationalization (i18n)

// NOTE(kinten) The pros are inside of HCMUT, high topic relevance

// NOTE(kinten) The cons are only available for participants of the course and within the duration of the course.

// TODO(kinten): use cetz to draw 4 graphs

== Functional requirements analysis // TODO(kinten): break into smaller!

The functional requirements for BKHack are systematically derived from the project’s core mission to transition from fragmented, informal academic dialogue toward a centralized, traceable, and evolving body of knowledge.

#figure()[
  #table(
    columns: 2,
    align: left,
    stroke: black,
    table.header(
      [*ID*],
      [*Description*]
    ),
    [FR1],
    [The system supports multiple content types, including articles, discussions, issues, pull requests, revision history entries, and notes.],
    [FR2],
    [All content types support creation, viewing, editing, and deletion according to user permissions.],
    [FR3],
    [All content lists—posts, notes, issues, pull requests, revision histories, users, and feeds—support rich filtering, searching, sorting, and collapsing.],
    [FR4],
    [Article posts maintain complete version history, recording all edits, administrative actions, ownership transfers, and reverts.],
    [FR5],
    [Users can view diffs between any two article versions.],
    [FR6],
    [Posts allow inspecting and updating editorial permissions.],
    [FR7],
    [Users may create issues associated with any article post.],
    [FR8],
    [Users may create pull requests proposing changes to any article post.],
    [FR9],
    [Each issue and pull request includes its own discussion thread.],
    [FR10],
    [Pull requests present structured change information, including diffs, comments, and status.],
  )
]

#figure()[
  #table(
    columns: 2,
    align: left,
    stroke: black,
    table.header(
      [*ID*],
      [*Description*]
    ),
    [FR11],
    [Authorized users may approve, reject, or modify-and-merge pull requests.],
    [FR12],
    [The system tracks relationships among issues, pull requests, and article versions.],
    [FR13],
    [Articles, issues, and pull requests support threaded discussions.],
    [FR14], 
    [Discussion threads inherit global filtering, sorting, and collapsing capabilities.],
    [FR15],
    [Discussions may reference specific versions, sections, or lines of content.],
    [FR16],
    [Users can upvote or downvote comments in discussions, issues, and pull requests.],
    [FR17],
    [All comments are annotated with the article version that existed at the time of posting.],
    [FR18],
    [Users may create lightweight notes, either standalone or referencing other content.],
    [FR19],
    [Notes support creation, editing, searching, sorting, filtering, tagging, and deletion.],
    [FR20],
    [The system provides account creation, authentication, and session management.],
    [FR21],
    [Each user has a profile containing authored content, activity history, contributions, and statistics.],
    [FR22],
    [Users have role-based permissions controlling editing, moderation, and administrative access.],
    [FR23],
    [Users may configure personal preferences, profile details, and notification settings.],
    [FR24],
    [Users may subscribe to content or authors to receive updates.],
    [FR25],
    [The system generates a personalized feed based on subscriptions, activity, and ranking.],
    [FR26],
    [Users can filter and sort feed items using tags, metadata, or relevance criteria.],
    [FR27],
    [Administrators can manage users, posts, tags, and system-wide settings and access analytics.],
    [FR28],
    [Administrators can inspect platform metrics such as growth, activity distribution, and moderation statistics.],
    [FR29],
    [Administrators may review and update global taxonomies, including categories, tags, and classifications.],
    [FR30],
    [Administrators can audit posts, issues, pull requests, and user histories.],
    [FR31],
    [Administrators oversee ownership transfers and moderation outcomes.], 
  )
]
  
== Non-functional requirements analysis

=== Performance

The system needs to perform well under reasonable load

#figure(
table(
columns: 2,
align: left,
stroke: black,
table.header(
[ID],[Description]
),
[NFR1],
// testicle
[The system should handle at least *30* concurrent users during normal operation without noticeable slowdown.],
[NFR2],
// testicle
[Average server-side response time for common actions (viewing articles, loading discussions, submitting comments) should remain under 400 ms on campus-hosted infrastructure.],
[NFR3],
// testicle
[Full page load time should not exceed *3* seconds on a standard broadband connection.],
[NFR4],
[Background processes (indexing, feed generation, notifications, analytics) must not increase foreground request latency by more than 20% under load.],
),
caption: [NFR for system performance]
)

=== Reliability and availability
The system must preserve data integrity across edits, revisions, and moderation actions.

#figure(
table(
columns: 2,
align: left,
stroke: black,
table.header(
[ID],[Description]
),
[NFR5],
[The system should maintain at least 97% uptime during the evaluation period, excluding scheduled maintenance.],
[NFR6],
// testicle
[Article versions, issues, pull requests, and comments must be durably persisted; no committed revision may be lost after acknowledgment.],
[NFR7],
[Automated database backups must occur at least once daily and be retained for 7 days, including revision histories and audit logs.],
[NFR8],
[Failure of auxiliary subsystems (analytics, notifications, moderation tools) must not prevent core read/write operations on articles and discussions.],
),
caption:[NFR for system reliability]
)

=== Security
The system must protect user accounts, content integrity, and moderation workflows.

#figure(
table(
columns: 2,
align: left,
stroke: black,
table.header(
[ID],[Description]
),
[NFR9],
// testicle
[User credentials must be stored using industry-standard password hashing with salting; sensitive data must never be stored in plain text.],
[NFR10],
[The system must be demonstrably resistant to common web attacks through manual or scripted testing, including:],
[ ~ ~ ~ NFR10.1],
[SQL Injection],
[ ~ ~ ~ NFR10.2],
[Cross-Site Scripting (XSS)],
[ ~ ~ ~ NFR10.3],
[Cross-Site Request Forgery (CSRF)],
[NFR11],
[Authentication sessions must expire after 20 minutes of inactivity and require re-authentication for sensitive actions (merging, moderation, administration).],
[NFR12],
[All data transmission must use HTTPS in deployment environments that support it.],
),
caption: [NFR for system security]
)

=== Usability and accessibility
The interface should support complex interactions without overwhelming users.

#figure(
table(
columns: 2,
align: left,
stroke: black,
table.header(
[ID], [Description]
),
[NFR13],
[The user interface must remain usable and fully functional on both desktop and mobile screen sizes.],
[NFR14],
[Core actions (reading articles, navigating versions, participating in discussions, creating issues or pull requests) should be discoverable within three interactions from primary entry points.],
[NFR15],
[The system must provide clear and immediate feedback for all user actions, including edits, submissions, approvals, rejections, and errors.],
[NFR16],
[Text layout and color contrast must meet basic accessibility guidelines to ensure readability of long-form and technical content.],
),
caption: [NFR for system usability]
)

=== Maintainability and extensibility
The system should accommodate evolving academic and collaborative workflows.

#figure(
table(
columns: 2,
align: left,
stroke:black,
table.header(
[ID],[Description]
),
[NFR17],
[The codebase must be structured into modular components reflecting major concerns (content, revisions, discussions, authentication, moderation, feeds).],
[NFR18],
[Each major module must be independently testable with clear interfaces and minimal coupling.],
[NFR19],
[At least 60% automated test coverage is expected for core business logic, including revision tracking and permission enforcement.],
[NFR20],
[The architecture must support future extension of content types, workflows, or ranking algorithms without requiring fundamental redesign.],
),
caption: [NFR for system maintainability]
)

=== Documentation and developer experience
The project should be understandable and sustainable for future contributors.

#figure(
table(
columns: 2,
align: left,
stroke:black,
table.header(
[ID],[Description]
),
[NFR21],
[The project must include comprehensive developer documentation, including:],
[ ~ ~ ~ NFR21.1],
[A setup guide for local development and deployment],
[ ~ ~ ~ NFR21.2],
[Documentation of core modules, data models, and APIs],
[ ~ ~ ~ NFR21.3],
[Inline comments for non-trivial logic, particularly revision handling and permission checks],
[NFR24],
[Version control practices must follow a defined workflow, including meaningful commits and review where applicable.],
),
caption: [NFR for developer experience]
)

=== Ethical and community standards
The platform must support transparent, respectful academic collaboration.

#figure(
table(
columns: 2,
align: left,
stroke:black,
table.header(
[ID],[Description]
),
[NFR25],
[A clear code of conduct and moderation policy must be publicly accessible to all users.],
[NFR26],
[User data handling must comply with university privacy policies and ethical research guidelines.],
[NFR27],
[Testing and development activities must not expose or rely on real student data without explicit consent.],
),
caption:[NFR for ethics]
)
