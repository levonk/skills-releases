---
type: Practice
title: Blog Writing Process
description: Normative practices for the engineering blog writing process — capturing ideas, getting to a working draft, optimizing the draft for target readers, getting feedback before publication, and the final pre-publication checklist. Covers the full lifecycle from idea to published post.
tags: [technical-writing, engineering-blogs, blog-writing, drafting, revision, feedback, publishing]
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

# Blog Writing Process

The writing process turns a topic into a published post. The process has four
phases: capture, draft, optimize, and ship. Each phase has a specific goal.
Skipping a phase produces a weaker post.

For topic selection and the characteristics of compelling posts, see
[Engineering Blog Fundamentals](engineering-blog-fundamentals.md). For the
patterns that shape different types of posts, see
[Engineering Blog Patterns](engineering-blog-patterns.md).

## Phase 1: Capture Ideas

### Keep an Idea Backlog

Ideas arrive at inconvenient times — during debugging, in code review, at the
end of a long investigation. Capture them before they fade.

- Keep a running list (a markdown file, a note app, a git repo).
- Write enough to remember the idea later: the problem, the resolution, and
  why it was interesting.
- Tag ideas by pattern (Bug Hunt, How We Built It, Lessons Learned, etc.) so
  you can find them when you are ready to write.

### Capture While the Context Is Fresh

The best time to start a draft is immediately after the work is done. The
context is fresh — you remember the dead ends, the tools, the aha moment. A
post written weeks later loses the details that make it compelling.

If you cannot write the full post now, write the outline. Capture:
- The problem (one paragraph)
- The key steps (bullet list)
- The resolution (one paragraph)
- The takeaway (one sentence)

### Do Not Wait for Perfection

A common barrier to writing is the belief that the post must be a masterpiece.
It does not. The goal is to share what you learned. A published post that is
80% perfect helps more people than a perfect post that lives in your drafts
folder forever.

## Phase 2: Draft

### Write the Outline First

Before writing prose, write the outline. The outline is the skeleton — it
ensures the post has a narrative arc before you invest in sentences.

A typical outline:
1. **Hook** — the problem, the question, or the surprising result
2. **Background** — what the reader needs to know to follow the story
3. **Investigation or build** — the main body, step by step
4. **Resolution** — the fix, the result, or the answer
5. **Takeaway** — what the reader should do with this knowledge

### Write Quickly, Revise Later

Get the first draft down without editing. The goal of the first draft is to
exist. Switching between writing and editing slows both.

- Write from the outline.
- Do not stop to look up references — mark them with `[TODO: link]` and keep
  going.
- Do not rewrite sentences — mark them with `[TODO: rephrase]` and keep going.
- Aim for completion, not quality.

### Include the Dead Ends

The failed attempts are the most educational part of a technical post. They
teach the reader what does not work and why. A post that jumps straight to the
solution deprives the reader of the investigation.

Include:
- Tools you tried that did not help
- Hypotheses that turned out wrong
- Red herrings that wasted time
- The moment the breakthrough happened

### Write for Your Target Reader

Know who you are writing for. The target reader determines the level of
background, the depth of technical detail, and the tone.

- **Peer engineers**: same level, same domain. Skip basic explanations. Go deep
  on the interesting parts.
- **Broader developer audience**: different domain, varying levels. Provide
  background. Explain jargon. Use analogies.
- **Non-engineering stakeholders**: leadership, product, DevRel. Focus on
  outcomes and impact. Keep code snippets short or move them to an appendix.

## Phase 3: Optimize the Draft

### Read It Aloud

Reading aloud catches awkward sentences, run-on constructions, and missing
transitions. If you stumble while reading a sentence, the reader will stumble
too. Rewrite it.

### Apply the Clarity Rules

Run the draft through the
[Simplified Technical English](simplified-technical-english.md) self-check:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice?
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?

For the full writing rules, see the [Detailed Guide](detailed-guide.md).

### Check the Narrative Arc

After the first revision, check the structure:

- Does the hook grab attention in the first paragraph?
- Does each section follow logically from the previous one?
- Does the resolution pay off the hook?
- Is there a clear takeaway at the end?

If any answer is "no," restructure before polishing sentences.

### Cut Ruthlessly

The second draft is the first draft with everything unnecessary removed.

- Cut paragraphs that do not advance the story.
- Cut sentences that repeat what the previous sentence said.
- Cut adjectives and adverbs that carry no information.
- Cut code snippets that duplicate what the prose already explains.

If cutting a section does not break the narrative, cut it.

### Strengthen the Title

The title determines whether the post gets read. A good title is specific,
honest, and intriguing.

**Weak titles:**
> Some Thoughts on Caching
> A Deep Dive Into Our Architecture
> Performance Update

**Strong titles:**
> How a Single Line of Code Made a 24-core Server Slower Than a Laptop
> Why Is My Rust Build So Slow?
> Hunting a NUMA Performance Bug

Strong titles make a concrete claim, ask a specific question, or promise a
specific story. They are not clickbait — the post delivers on the promise.

### Add Visuals

Visuals break up text and communicate what prose cannot:

- **Architecture diagrams** — show system structure
- **Flame graphs** — show performance bottlenecks
- **Screenshots** — show tool output, error messages, or UI states
- **Charts** — show benchmark results or trends over time
- **Code snippets** — show the relevant code, not the entire file

Every visual should have a caption that explains what to look for.

## Phase 4: Get Feedback

### Choose Reviewers Deliberately

Different reviewers catch different problems:

- **A domain expert** — checks technical accuracy and catches errors
- **A non-domain engineer** — checks clarity and identifies jargon
- **A writer or editor** — checks structure, flow, and prose quality
- **A potential reader** — checks whether the post delivers value

One reviewer from each category is ideal. If you cannot get all four, prioritize
the domain expert and the non-domain engineer.

### Ask Specific Questions

Do not ask "what do you think?" — you will get vague responses. Ask specific
questions:

- "Is the explanation of the NUMA issue clear to someone who has not seen
  our codebase?"
- "Did you find the dead ends useful, or should I cut them?"
- "Is the title accurate, or does it overpromise?"
- "Does the conclusion deliver on the hook?"

### Handle Feedback Without Losing Your Voice

Feedback improves the post, but not every suggestion should be applied. When a
reviewer suggests a change:

1. **Understand the problem behind the suggestion.** "Move this section earlier"
   usually means "I was confused because I lacked context." Fix the confusion,
   not necessarily by moving the section.
2. **Apply changes that fix real problems.** Technical errors, unclear
   explanations, missing context — these are clear fixes.
3. **Decline changes that dilute your voice.** If a suggestion makes the post
   sound like a corporate press release, it is the wrong suggestion for an
   engineering blog.
4. **Thank the reviewer either way.** They spent time on your work.

## Phase 5: Ship

### Final Checklist

Before publishing, run this checklist:

- [ ] Title is specific, honest, and intriguing
- [ ] First paragraph hooks the reader
- [ ] Every section advances the narrative
- [ ] Technical claims are verified
- [ ] Code snippets are tested and correct
- [ ] Visuals have captions
- [ ] Acronyms are defined on first use
- [ ] Links work (no 404s)
- [ ] Conclusion delivers a clear takeaway
- [ ] The post has been read aloud at least once
- [ ] At least one reviewer has provided feedback

### Publishing Platforms

Choose a platform based on your goals:

- **Company engineering blog** — best for reach, SEO, and credibility. The
  company promotes the post. The downside: editorial review may take weeks.
- **Personal blog** — best for ownership and creative control. You own the
  content and the URL. The downside: you do all the promotion.
- **Medium / Dev.to / Hashnode** — best for built-in audience and easy
  publishing. The downside: you do not own the platform, and algorithm changes
  can affect reach.
- **Cross-posting** — publish on your personal blog first, then cross-post to
  Medium or Dev.to with a canonical link back to your original. This preserves
  SEO while expanding reach.

### Timing

Publish when your target audience is online. For developer audiences:
- Tuesday through Thursday mornings (US time) tend to perform well
- Avoid Friday afternoons and weekends for technical posts
- If targeting Hacker News, submit in the morning US time on a weekday

These are guidelines, not rules. The quality of the post matters more than the
publishing time.

## AI Assistance: Uses and Limits

Generative AI can help with the writing process, but it has specific limits.

### Where AI Helps

- **Brainstorming topics** — feed your idea backlog and ask for pattern matches
- **Outlining** — generate a draft outline from your notes
- **Prose polishing** — tighten sentences, fix grammar, suggest alternatives
- **Generating titles** — produce multiple candidates to choose from
- **Translating** — help non-native English speakers with phrasing

### Where AI Does Not Help

- **Technical accuracy** — AI can hallucinate technical details. Verify every
  claim, code snippet, and benchmark number yourself.
- **Authentic voice** — AI produces generic prose. Your voice — the way you
  explain things, your humor, your perspective — is what makes the post yours.
- **The story** — AI does not know what dead ends you hit, what tools you
  tried, or what the aha moment felt like. The story comes from your
  experience.
- **Opinion** — AI hedging ("on the other hand", "it depends") dilutes strong
  takes. If you have an opinion, write it yourself.

### Rule of Thumb

Use AI as a writing assistant, not a writing replacement. If the AI wrote more
than 30% of the final prose, the post is not yours — and readers will notice.

## Quick Self-Check

Before publishing, check:

- [ ] Did you capture the idea while the context was fresh?
- [ ] Does the draft follow the outline (hook → background → body →
      resolution → takeaway)?
- [ ] Did you include the dead ends and failed attempts?
- [ ] Did you apply the clarity rules from the Detailed Guide?
- [ ] Did you cut everything that does not advance the narrative?
- [ ] Is the title specific, honest, and intriguing?
- [ ] Did at least one reviewer provide feedback?
- [ ] Are all code snippets tested and all links verified?
- [ ] If you used AI, is the final prose authentically yours?

## Cross-References

- Fundamentals and topic selection: [Engineering Blog Fundamentals](engineering-blog-fundamentals.md)
- Blog post patterns: [Engineering Blog Patterns](engineering-blog-patterns.md)
- Promotion and expansion: [Blog Promotion and Expansion](blog-promotion-and-expansion.md)
- Core prose clarity rules: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Bundle index: [index.md](index.md)
