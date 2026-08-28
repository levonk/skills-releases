---
type: Practice
title: Blog Promotion and Expansion
description: Normative practices for promoting engineering blog posts and expanding beyond blogging — social media sharing, squeezing more value from each post, turning a blog into a conference talk, and considerations for becoming a book author. Covers the post-publication lifecycle.
tags: [technical-writing, engineering-blogs, promotion, social-media, conference-talks, book-writing, expansion]
date:
  created: "2026-08-27"
  knowledge-basis: "2026-08-27"
  last-used: "2026-08-27"
sources:
  - id: writing-for-developers
    resource: "https://github.com/scynthiadunlop/WritingForDevelopersBook"
    title: "Writing For Developers: Blogs That Get Read by Piotr Sarna and Cynthia Dunlop"
  - id: writethat-blog
    resource: "https://writethatblog.substack.com/"
    title: "Write That Blog — newsletter with writing tips from expert bloggers"
---

# Blog Promotion and Expansion

Writing the post is half the work. The other half is getting it read and
squeezing more value from it over time. This page covers promotion, reuse,
and the path from blog post to conference talk to book.

For the writing process, see [Blog Writing Process](blog-writing-process.md).
For the patterns that shape different types of posts, see
[Engineering Blog Patterns](engineering-blog-patterns.md).

## Promotion

### Share Your Own Post

Publishing a post does not guarantee readers. Promote it — but promote it
without sounding like a marketing department.

**Do:**
- Share the post on the platforms where your audience lives (X, LinkedIn,
  Hacker News, Reddit, relevant Discord or Slack communities)
- Write a custom message for each platform — do not cross-post the same text
  everywhere
- Lead with the hook or the key takeaway, not with "I wrote a blog post"
- Share at the time your audience is online (see
  [Blog Writing Process](blog-writing-process.md) — Timing)

**Don't:**
- Don't share the same link five times in one day across platforms with
  identical copy
- Don't beg for upvotes on Hacker News or Reddit — the platforms detect this
  and the community resents it
- Don't promote a post you know is weak — wait until it is ready

### Let the Publisher Promote

If you publish on a company engineering blog, the company's marketing or DevRel
team will likely promote the post. Coordinate with them:

- Share your social handles so they can tag you
- Provide a suggested tweet or LinkedIn post (they may use it or write their
  own)
- Ask about the promotion schedule — some companies queue posts for specific
  days

### Engage With Comments

Comments are where the peer review happens (see
[Engineering Blog Fundamentals](engineering-blog-fundamentals.md) — Free Peer
Review). Engage with them:

- **Respond to genuine questions.** A thoughtful answer builds your reputation.
- **Acknowledge corrections publicly.** "You are right, I got this wrong.
  I have updated the post." This builds more trust than ignoring the comment.
- **Update the post when a comment reveals an error.** Add an errata note or
  fix the text inline with a note.
- **Filter the vitriol.** Not every comment deserves a response. Do not feed
  trolls.

### Submit to Aggregators

Aggregators (Hacker News, Reddit /r/programming, Lobsters) drive significant
traffic when a post lands. Each has its own culture:

- **Hacker News** — values technical depth, originality, and honesty. Submit
  in the morning US time. Do not ask friends to upvote — the algorithm
  detects coordinated voting.
- **Lobsters** — values technical depth and invites. Smaller, more technical
  audience. Less noise, fewer trolls.
- **Reddit /r/programming** — values broad appeal and discussion. Read the
  subreddit rules before posting — some prohibit self-promotion.

Submit once. Do not resubmit if it does not take off.

## Squeezing More Value From Each Post

### Update the Post Over Time

A blog post is not frozen at publication. Update it when:

- **The technology changes.** A new version of the tool, a deprecated API, or
  a changed default invalidates part of the post. Add an update note at the
  top and fix the body.
- **You learn more.** A reader's comment or a subsequent experience gives you
  new insight. Add it.
- **You find an error.** Fix it immediately and note the correction.

Updated posts stay relevant longer and continue to attract readers through
search.

### Cross-Reference in Other Work

Link to the post from:

- **Code comments and commit messages** — "See [blog post] for the full
  investigation" instead of re-explaining
- **Design documents and RFCs** — reference the post as background
- **Code review comments** — link to the post when the same question arises
- **Onboarding docs** — point new hires at posts that explain the system
- **Future blog posts** — "In [previous post], we covered X. This post covers
  Y."

This is the "write once, share everywhere" principle from
[Engineering Blog Fundamentals](engineering-blog-fundamentals.md).

### Turn One Post Into a Series

If a post covers a large topic, consider splitting it into a series:

- **Part 1: The Problem** — the bug, the performance issue, or the challenge
- **Part 2: The Investigation** — the tools, the dead ends, the breakthrough
- **Part 3: The Solution** — the fix, the architecture, or the result
- **Part 4: The Takeaways** — lessons learned and recommendations

A series keeps each post digestible and gives readers a reason to return. Link
the parts together with "previous" and "next" references at the top of each
post.

### Repurpose the Content

The research and writing in a blog post can fuel other formats:

- **A conference talk** — see below
- **A workshop or webinar** — expand the post into a hands-on session
- **A newsletter issue** — summarize the post for a newsletter audience
- **A video** — record a screen capture walking through the post's code or
  investigation
- **A chapter in a book** — see below

Repurposing is not duplication. Each format adapts the content to its medium.
A talk is not a blog post read aloud; a video is not a talk recorded.

## From Blog Post to Conference Talk

### Why Turn a Post Into a Talk

A successful blog post often leads to conference invitations. Turning a post
into a talk extends its reach to a new audience and establishes you as a
speaker. Talks also lead to networking, career opportunities, and invitations
to future events.

### Adapt, Don't Read

The biggest mistake first-time speakers make is reading their blog post from
slides. A talk is a different medium:

- **A blog post is read at the reader's pace.** They can re-read, skip, and
  reference. A talk is real-time — the audience cannot rewind.
- **A blog post can be long.** A talk has a fixed time slot (15, 30, or 45
  minutes).
- **A blog post relies on text and code.** A talk relies on visuals, voice,
  and presence.

### Structure the Talk

A typical conference talk structure:

1. **Hook (2-3 minutes)** — the problem, the surprising result, or the
   question. Grab attention immediately.
2. **Background (3-5 minutes)** — what the audience needs to know to follow
   the talk. Keep it short.
3. **Main body (15-30 minutes)** — the investigation or build, told as a
   story. Use visuals, not walls of text.
4. **Resolution (3-5 minutes)** — the fix, the result, or the answer.
5. **Takeaway (2-3 minutes)** — what the audience should do with this
   knowledge. End strong.

### Slide Design

- **One idea per slide.** Do not cram a paragraph onto a slide.
- **Visuals over text.** Diagrams, charts, screenshots, and code snippets
  (short ones) communicate more than bullet lists.
- **Large fonts.** The audience in the back row must read the slide.
- **No more than 6 bullets per slide.** If you need more, split the slide.
- **Show code, do not read it.** Highlight the relevant line. The audience
  cannot read a 20-line code block on a slide.

### Practice

Practice the talk out loud, with a timer, at least three times before the
event. Practice with the slides. Practice in front of a colleague if possible.

- **If you run over time in practice, cut content.** Do not plan to talk
  faster.
- **If you run under time, add depth to the main body.** Do not pad with
  unrelated material.
- **Memorize the first 60 seconds.** This gets you through the most nervous
  part. The rest flows from the slides and your preparation.

## From Blog Post to Book

### Considerations Before Writing a Book

A book is a multi-month to multi-year commitment. Before deciding to write
one, consider:

- **Do you have enough material?** A book needs more than a collection of blog
  posts. You need a coherent thesis and enough depth to fill 200-400 pages.
- **Do you have the time?** Writing a book while working full-time means
  early mornings, evenings, and weekends for months. Be honest about your
  capacity.
- **Do you have a publisher or self-publishing plan?** Traditional publishers
  (Manning, O'Reilly, Apress) provide editorial support, distribution, and an
  advance. Self-publishing provides creative control and higher royalties but
  requires you to handle editing, design, and marketing.
- **Is the market ready?** A book on a technology that is still evolving
  rapidly may be outdated before it is published. A book on a stable practice
  or a timeless principle ages better.

### Blog Posts as a Foundation

Blog posts can serve as the foundation for a book:

- **Test the thesis.** Write blog posts on the key ideas. Reader engagement
  tells you which ideas resonate.
- **Build an audience.** A blog readership becomes a book readership. Publishers
  look for authors with existing platforms.
- **Refine the structure.** The response to a series of posts can shape the
  book's table of contents.
- **Recycle the research.** The investigation, examples, and code from blog
  posts feed directly into book chapters.

Do not publish a book that is just a collection of blog posts stitched
together. A book needs a narrative arc, a coherent structure, and new content
that ties the chapters together. Use the blog posts as raw material, then
rewrite and expand for the book medium.

### The Virtuous Cycle

Writing, engineering, and speaking feed each other in a virtuous cycle: strong
writing skills increase your impact as an engineer, which leads to more
interesting engineering experiences, which leads to more interesting blog
posts, which further increase your impact. Blogging, speaking, and book
writing feed each other:

- Blog posts lead to talk invitations
- Talks lead to networking and new engineering opportunities
- New engineering experiences lead to new blog posts
- A body of blog posts and talks can lead to a book
- A book leads to more talk invitations and a larger audience

Each step compounds. The key is to start — write the first post, give the
first talk, and let the cycle build.

## Quick Self-Check

Before promoting a post, check:

- [ ] Have you shared the post on the platforms where your audience lives?
- [ ] Did you write a custom message for each platform?
- [ ] Did you engage with comments and corrections?
- [ ] Did you submit to relevant aggregators (once, without asking for
      upvotes)?

Before turning a post into a talk, check:

- [ ] Did you adapt the content for the talk medium (not read the post)?
- [ ] Does the talk follow the hook-background-body-resolution-takeaway
      structure?
- [ ] Are slides visual, not text walls?
- [ ] Have you practiced out loud with a timer at least three times?

Before deciding to write a book, check:

- [ ] Do you have enough material for a coherent thesis across 200-400 pages?
- [ ] Do you have the time for a multi-month commitment?
- [ ] Do you have a publisher or self-publishing plan?
- [ ] Have you tested the thesis through blog posts and reader engagement?

## Cross-References

- Fundamentals and topic selection: [Engineering Blog Fundamentals](engineering-blog-fundamentals.md)
- Writing process: [Blog Writing Process](blog-writing-process.md)
- Blog post patterns: [Engineering Blog Patterns](engineering-blog-patterns.md)
- Core prose clarity rules: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Bundle index: [index.md](index.md)
