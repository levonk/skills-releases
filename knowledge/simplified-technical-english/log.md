# Directory Update Log

## 2026-08-27

* **Ingest**: Added *Writing For Developers: Blogs That Get Read* by Piotr
  Sarna and Cynthia Dunlop
  (<https://github.com/scynthiadunlop/WritingForDevelopersBook>) as a source.
  The book covers engineering blog writing — topic selection, the writing
  process, seven blog post patterns, and promotion/expansion. Three public
  excerpts (About the Book, Why Write Engineering Blogs, The Bug Hunt
  Pattern) provided direct content; the remaining six patterns were
  researched from public engineering blogs and the writethat.blog newsletter.
  Per the Normative Stance rule, wrote all new content as normative practices
  with the book in `sources:` frontmatter only — no "the book says" framing
  in the body.
* **Ingest**: Added the writethat.blog newsletter
  (<https://writethatblog.substack.com/>) as a source. The newsletter
  publishes writing tips from expert bloggers and monthly blog post picks;
  it was used to research the six patterns not covered by the public
  excerpts.
* **Creation**: Authored 4 new concept pages covering engineering blog
  writing:
  - [engineering-blog-fundamentals.md](engineering-blog-fundamentals.md) —
    why write engineering blogs (understanding your code, peer review,
    personal brand, career development, staying current, write-once-share-
    everywhere), topic selection, and characteristics of compelling posts
    (narrative arc, technical depth without gatekeeping, honesty about
    failures, concrete examples, satisfying conclusions)
  - [blog-writing-process.md](blog-writing-process.md) — the full lifecycle
    from idea to published post: capture (idea backlog, capture while fresh,
    do not wait for perfection), draft (outline first, write quickly, include
    dead ends, write for target reader), optimize (read aloud, apply clarity
    rules, check narrative arc, cut ruthlessly, strengthen title, add
    visuals), get feedback (choose reviewers deliberately, ask specific
    questions, handle feedback without losing your voice), ship (final
    checklist, publishing platforms, timing), and AI assistance uses/limits
  - [engineering-blog-patterns.md](engineering-blog-patterns.md) — the seven
    canonical patterns with purpose, characteristics, dos, don'ts, and 3-4
    real-world examples each: Bug Hunt (detective story), Rewrote It in X
    (migration with quantified results), How We Built It (impressive
    achievement), Lessons Learned (postmortem/retrospective), Thoughts on
    Trends (opinionated takes), Non-Markety Product (product embedded in
    educational content), Benchmarks and Test Results (performance
    comparisons with methodology)
  - [blog-promotion-and-expansion.md](blog-promotion-and-expansion.md) —
    promoting posts (share your own, let the publisher promote, engage with
    comments, submit to aggregators), squeezing more value (update over time,
    cross-reference in other work, turn one post into a series, repurpose the
    content), from blog post to conference talk (adapt don't read, structure,
    slide design, practice), and from blog post to book (considerations,
    blog posts as foundation, the virtuous cycle)
* **Update**: Restructured [index.md](index.md) into two sections —
  "STE100-Inspired Clarity and Mechanics" (the original 7 pages) and
  "Engineering Blog Writing" (the 4 new pages). Updated
  [overview.md](overview.md) concepts table with the same two-section
  structure and added engineering blog posts to the Scope section. Bumped
  `date.knowledge-basis` and `date.last-used` to 2026-08-27 on the overview.

## 2026-08-26

* **Ingest**: Added the Proxmox VE Technical Writing Style Guide
  (<https://pve.proxmox.com/wiki/Technical_Writing_Style_Guide>) as a source.
  Extracted the generally-applicable technical writing guidance (filtered out
  Proxmox-specific content: brand names, product abbreviations, the "Industry
  Related Terms" section, and the Proxmox-specific "data is singular" choice).
  Per the Normative Stance rule, wrote all new content as normative practices
  with the Proxmox guide in `sources:` frontmatter only — no "Proxmox says"
  framing in the body.
* **Creation**: Authored 4 new concept pages covering style and mechanics that
  the STE100-inspired core did not cover:
  - [punctuation.md](punctuation.md) — Oxford commas, comma placement rules,
    semicolons for independent clauses, hyphens for compound modifiers, em
    dashes, slashes
  - [capitalization.md](capitalization.md) — title-style vs sentence-style
    headlines, basic capitalization rules, a/an by vowel sound
  - [procedures-and-lists.md](procedures-and-lists.md) — front-loading
    important information, procedure structure (intro sentence, single-step,
    sub-step numbering with letters and Roman numerals), list formatting,
    transitions
  - [word-choice.md](word-choice.md) — slang/jargon/idioms, contractions,
    abbreviations (avoid approx./etc.), e.g./i.e. → "for example"/"that is",
    acronym nuances (don't define if used once, commonly-known OK), US/UK
    English consistency, gender-neutral pronouns, tested examples
* **Update**: Folded Proxmox-derived nuances into existing detailed-guide.md
  rules: Rule 1 (introduce synonyms on first use for searchability), Rule 8
  (don't define acronyms used only once; commonly-known acronyms need no
  definition), Rule 10 (single-step procedures use bullets, sub-step numbering,
  combine related actions, list style consistency, term-and-definition
  bolding). Added cross-references from detailed-guide.md to the 4 new pages.
* **Update**: Added "Beyond Clarity: Style and Mechanics" section to
  [simplified-technical-english.md](simplified-technical-english.md) with
  cross-references to the 4 new companion pages. Updated
  [overview.md](overview.md) concepts table and [index.md](index.md) to list
  the new pages. Bumped `date.knowledge-basis` and `date.last-used` to
  2026-08-26 on all touched pages.

## 2026-07-26

* **Initialization**: Created the `simplified-technical-english` knowledge
  bundle to give the STE100-inspired guidelines a canonical, publicly-reachable
  home on `skills-releases`. Previously the detailed guide lived only at
  `includes/ste100-detailed-guide.md.tmpl`, which was not part of the knowledge
  bundle system that consumer projects discover.
* **Creation**: Authored 2 concept pages:
  - [simplified-technical-english.md](simplified-technical-english.md) — the core guidelines (active voice, short sentences, one-word-one-meaning, imperative mood, approved modifiers, acronym definitions, quick self-check)
  - [detailed-guide.md](detailed-guide.md) — full 10 writing rules, approved-words guidance, 3 before/after examples, 10-step self-check protocol
* **Creation**: Established [overview.md](overview.md) synthesis and this
  [index.md](index.md) directory listing.
* **Migration**: Moved the detailed-guide content from
  `src/current/includes/ste100-detailed-guide.md.tmpl` into
  [detailed-guide.md](detailed-guide.md) (with OKF v0.2 frontmatter). Removed
  the include file — the bundle is now the single source of truth for the full
  guide. The build-time include
  `ste100-simplified-technical-english.md.tmpl` remains in `includes/` as the
  gist that gets inlined into skills and other bundles; it links to this
  bundle's published URL for the full detail.
