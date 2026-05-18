
= Overview <overview>

/*

The rationale for developing a dedicated platform arises from the need to consolidate these scattered discussions into a system that is structured, accessible, and integrated with existing university infrastructure. Such a centralized space would not only facilitate the dissemination of technological updates but also enable students and lecturers to engage in meaningful dialogue and knowledge-sharing.

The significance of BKHack lies in its role as a community-driven social news platform focused on computer science. By adopting the proven models of established forums and discussion boards, the platform will provide threaded conversations, curated content, and efficient navigation. Fully integrated with the existing systems of Bach Khoa University, it will serve as a reliable and sustainable foundation for peer learning, collaborative problem-solving, and constructive debate.

The urgency of such a project is underscored by the rapid pace of advancements in computer science. Without timely and structured access to knowledge, students may face barriers in keeping up with new trends, research, and technologies. Establishing BKHack ensures that the academic community remains informed, engaged, and prepared to meet the challenges of both coursework and professional practice.

In terms of importance, BHack represents more than a technical platform: it is a step towards building a long-term academic ecosystem that promotes inclusivity, collaboration, and intellectual growth. By laying the groundwork now, this specialized project also establishes the basis for the future capstone thesis, where its design and implementation can be fully realized and evaluated.

In HCMUT, there is no dedicated central platform for discussions on computer science. Academic exchanges are scattered across many formal and informal channels such as social media groups, private chats, and external forums. It is difficult and time-intensive to procure and aggregate information.

*/

// == Problem and necessity

// NOTE(kinten) Currently, HCMUT lacks a specialized central platform for discussing computer science topics. Conversations are fragmented across various social media groups, private chats, and forums, making it difficult for students to disseminate or discover technological developments and engage in collaborative learning without significant insider access.

// NOTE(kinten) BKHack will be the one-stop-shop for curated content regarding Computer Science, fully integrated with the existing BK systems. It is a community-driven social news platform modeled after established forums and boards, allowing threaded discussion of the latest topics as well as efficient navigation. Our end goal is to foster a space for peer-learning, collaboration, and constructive debate.

== Context // NOTE(kinten) aka. Problem statement

/*

Within the academic environment of Ho Chi Minh City University of Technology (HCMUT), there is currently no dedicated platform designed specifically for computer science discourse. Academic exchanges are dispersed across informal and external channels such as social media groups, private chats, and public forums. This dispersion creates fragmented information flow, where valuable insights, resources, and discussions are buried under noise or confined to isolated communities. As a result, students and lecturers alike face significant difficulty in procuring, aggregating, and verifying information relevant to their studies or research interests.

Beyond dispersion, another emerging challenge is information reliability over time. Many discussions — especially those involving technologies, frameworks, or research topics — quickly become outdated, disproven, or replaced by better knowledge. Yet on existing platforms, such content persists indefinitely without correction or context. Readers must sift through multiple addenda, clarifications, or contradictory follow-ups across separate threads to reconstruct the “current truth.” This not only wastes effort but also erodes academic credibility and engagement.

In response to these issues, BKHack is conceived as a centralized, university-integrated platform for intellectual discussion, procurement, and curation of computer science knowledge. It combines the community interactivity of social platforms with the structural rigor of version-controlled systems. Through organized threads, revision histories, and contributor accountability, BKHack aims to transform fragmented dialogue into a living, traceable, and evolving body of academic discussion — ensuring that each topic remains accessible, contextualized, and academically sound.

*/

Within the academic environment of Ho Chi Minh City University of Technology (HCMUT), we as students of the university feel that there is no dedicated platform for academic computer science discourse. Academic exchanges currently lack aggregation - they are dispersed across informal and external channels such as social media groups, private chats, and public forums. A potential effect of this dispersion is that it may fragment information flow, where valuable insights, resources, and discussions are buried under noise or confined to isolated communities. Students and lecturers alike face significant difficulty in procuring, aggregating, and verifying information relevant to their studies or research interests.

Beyond dispersion, another emerging challenge is information reliability over time. Many discussions, particularly those meant to be educational or regarding recent developments, quickly become outdated, disproven, or replaced by better knowledge. As Computer Science majors, we have often searched for technical solutions on discussion and social news platforms on the internet and were often faced with outdated information. On existing platforms, such content persists indefinitely without correction or context. Readers must sift through multiple addenda, clarifications, or contradictory follow-ups across separate threads to reconstruct the “current truth”. This is not only a waste of effort but it also erodes academic credibility and engagement.

== Survey

We have done an informal questionaire-based survey in HCMUT, where we ask students and lecturers at the site of HCMUT a few questions about their social news experience in general:

1. "What content are you interested in the most?"
2. "How do you usually discover topics you'd explored in-depth (rabbit holes/deep dives)?"
3. "What makes a piece of news or information credible to you?"
4. "What is the most important aspect of a community platform?"

We found that there's a small albeit relevant interest in an educational, research-focused social news website in HCMUT. There are certain expectations as to how knowledge and news content should be treated. For example, according to @qq3, citation factors considerably in a content's credibility. These results should influence requirement analysis and design of the system in later sections.

// TODO(kinten) apply techniques from the book "Visual display of quantitative information" when displaying these result charts, bachkhoa-style.

// TODO(kinten) ..make two versions for bachkhoa-style and kinten-style, responsive adapt

/*

#cetz.canvas({
  import cetz.draw: *
  let transparent = rgb(0,0,0,0)

  group({
    arc((rel: (0, 0)), start: 90deg, stop: -60deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,100))
    arc((rel: (0, 0)), start: 300deg, stop: 250deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,50))
    arc((rel: (0, 0)), start: 250deg, stop: 90deg, mode: "PIE", radius: 1.2cm, stroke: rgb(0,0,0,0), fill: rgb(100,100,255,100))
  })
  
  move-to((4, 0))
  
  group({
    arc((rel: (0, 0)), start: 90deg, stop: -60deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,100))
    arc((rel: (0, 0)), start: 300deg, stop: 250deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,50))
    arc((rel: (0, 0)), start: 250deg, stop: 90deg, mode: "PIE", radius: 1.2cm, stroke: rgb(0,0,0,0), fill: rgb(100,100,255,100))
  })
  
  move-to((0, -4))
  
  group({
    arc((rel: (0, 0)), start: 90deg, stop: -60deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,100))
    arc((rel: (0, 0)), start: 300deg, stop: 250deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,50))
    arc((rel: (0, 0)), start: 250deg, stop: 90deg, mode: "PIE", radius: 1.2cm, stroke: rgb(0,0,0,0), fill: rgb(100,100,255,100))
  })
  
  move-to((4, -4))
  
  group({
    arc((rel: (0, 0)), start: 90deg, stop: -60deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,100))
    arc((rel: (0, 0)), start: 300deg, stop: 250deg, mode: "PIE", radius: 1.2cm, stroke: transparent, fill: rgb(50,50,255,50))
    arc((rel: (0, 0)), start: 250deg, stop: 90deg, mode: "PIE", radius: 1.2cm, stroke: rgb(0,0,0,0), fill: rgb(100,100,255,100))
  })
})

*/

#figure(
  image("assets/survey/Q1.svg", width: 10cm),
  caption: [Responses to question 1 of the questoinaire, "what content are you interested in the most?"]
) <qq1>

#figure(
  image("assets/survey/Q2.svg", width: 10cm),
  caption: [Responses to question 2 of the questoinaire, "how do you usually discover topics you'd explored in-depth (rabbit holes/deep dives)?"]
) <qq2>

#figure(
  image("assets/survey/Q3.svg", width: 10cm),
  caption: [Responses to question 3 of the questionnaire, "what makes a piece of news or information credible to you?"]
) <qq3>

#figure(
  image("assets/survey/Q4.svg", width: 10cm),
  caption: [Responses to question 4 of the questoinaire, "what is the most important aspect of a community platform?"]
) <qq4>

== Solution

In response to these issues, BKHack is conceived as a centralized, university-integrated platform for /* intellectual */ the procurement, discussion, and curation of computer science knowledge. For the goal of ensuring aggregation and reliability, we propose a novel revision - pull request system for interacting with discussions, inspired by existing systems found in platforms like Wiki.gg and /* NOTE(kinten) I hate writing "X" as name of a website */ X (formerly Twitter)/*NOTE(HGT) are we seriously gonna use twitter as a source?*/. It combines the community interactivity of social platforms with the structural rigor of version-controlled systems. Through organized threads, revision histories, and contributor accountability, BKHack aims to transform fragmented dialogue into a living, traceable, and evolving body of academic discussion — ensuring that each topic remains accessible, contextualized, and academically sound.

/*

// == Necessity // Urgency/ Rational

The necessity of BKHack lies in addressing two intertwined problems: the decentralization of academic discourse and the lack of mechanisms for maintaining information integrity. In the field of computer science, where technologies evolve rapidly, knowledge becomes obsolete at an exceptional pace. Without structured systems to manage versioning and context, misinformation and redundancy proliferate, making learning less efficient and collaboration less reliable.

Existing social media or discussion platforms prioritize immediacy over accuracy. They lack academic curation, editorial workflows, and traceability — features essential for building a trustworthy repository of shared knowledge. Consequently, the absence of a centralized and structured communication space leaves students dependent on unverified sources or scattered communities, limiting opportunities for meaningful engagement and cross-disciplinary insight.

BKHack seeks to bridge this gap by integrating discussion, revision, and moderation into a single cohesive system. Posts are treated as evolving artifacts that can be improved, reviewed, and verified through transparent collaboration. This design not only promotes information accuracy but also encourages responsible academic participation — where contributions are attributable, revisions are accountable, and outdated content is clearly contextualized rather than lost or duplicated.

In short, BKHack represents both a technological and educational necessity. It provides the foundation for a sustainable academic communication ecosystem — one that aligns with the university’s digital transformation goals, enhances the accessibility of academic dialogue, and prepares students for professional practices of collaborative software development and open research.

*/

== Goals <project-goals>

The goal of this capstone project is to develop BKHack, a social news website focusing on computer science in HCMUT. This website should achieve the following effects on the community:

- It should provide a trustworthy platform for sharing and discussing news about tech and CS
- It should be an outlet for others to discover and learn about your own personal projects
- It should encourage the pursuit of truth via a community-sourced, fact-checking revision — pull request system.

// Become the central hub for discovering everything tech related, from new technologies, tech competitions, //(third item on the list)

// develop the website BKHack, a social news website focusing on Computer Science for HCMUT students.

// BKHack uniquely provides a revision system where users can see history of changes of a post. Readers can suggest changes to post through an organized pull-request system.

== Scope

The development of BKHack concerns skills in web application development and the hosting of an always-online internet service.

The stakeholders of BKHack should be all students and lecturers of HCMUT who are interested in computer science discussion. The maintenance of BKHack may also concern system adminstrators of staff of HCMUT.

/*
// dont laugh there is a method to the madness
// lgtm
//what
In this project, we will be building a web social news platform
//who
for all students and lecturers in HCMUT
//why
who need a reliable source of and place to share computer science news and knowledge
//how
by posting news of their own or share news from a third party source
*/

== Structure

For this semester, we focus on the design of our system, specifications, and other high-level details; these will be the bulk of the content of this report. As for implementation, we only discuss briefly some details, as well as providing a timeline for working in the future.

// TODO(kinten) these reference labels should show their heading name as well

In @overview, we provide a high-level overview of this project — its context, goals, and scope.

In @design, we analyze related systems to highlight their advantages and disadvantages as foundation, and from there we propose a design for our system BKHack.

In @realization, we present and discuss our implementation progress of our system BKHack.

In @timeline, we provide a concrete list of tasks of implementation and its assignment.

In @conclusion we discuss what we've achieved in this project, our shortcomings and future work.
