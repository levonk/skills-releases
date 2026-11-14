# Directory Update Log

## 2026-11-13

* **Ingest**: Added the STE80 Humanizer
  (<https://github.com/Dodaios/ste80-humanizer>, MIT) as a source. The
  project operationalizes Andrej Karpathy's "80% of the way to ASD-STE100"
  suggestion (<https://x.com/karpathy/status/2105819303471976479>) as a
  two-pass rewrite: Pass 1 removes the 26 AI tells from the
  blader/humanizer catalog (<https://github.com/blader/humanizer>, MIT),
  itself derived from Wikipedia's "Signs of AI writing"
  (<https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing>); Pass 2
  rebuilds sentence structure with STE discipline relaxed to ~80%. Per the
  Normative Stance rule, all content was written as normative practices
  with the sources in `sources:` frontmatter only.
* **Creation**: Authored [ste80-rewrite-method.md](ste80-rewrite-method.md)
  — the two-pass de-AI rewrite method. Covers the rationale for two passes
  (de-telling alone leaves structural AI habits; STE alone leaves chatbot
  habits), severity triage (act-on-one-sighting vs weak-alone tells vs
  deliberate craft), light/standard/strict modes with output shapes, the
  80%-vs-strict calibration table, the fact-inventory rewrite workflow,
  fidelity rules (keep every fact at its strength, keep identifiers exact,
  add nothing, flag contradictions, never touch code/URLs), the
  when-not-to-act list (quotes, letters, pre-late-2022 text, fiction and
  brand voice, legal text, code, other languages, writer's sample
  overrides), Pass 2 structure rules beyond the detailed guide
  (condition-first, warnings-first, simple tenses, verbs-not-nouns, -ing
  chains, honest modals, noun stacks, paragraph discipline, information
  ordering, simple connectors, STE word-count conventions, strict-mode
  extras), a grouped plain-word substitution table, and heuristic linting
  guidance (what a regex linter can and cannot measure — it flags places
  to look, not an AI detector or compliance check).
* **Update**: Expanded [ai-writing-tells.md](ai-writing-tells.md) with the
  delta tells and the severity model from the new source. New tells:
  arguing with no one, fake-depth sayings, sales language, stacked
  qualifiers *(weak alone)*, hyphenated pairs after the noun *(weak
  alone)*, decorative headings, one-line closers, writing about the
  document instead of its subject, re-explaining what the reader knows,
  chatbot residue, knowledge-limit disclaimers and guesses, and heading
  repeated in the first sentence (new "Chatbot Residue and Draft
  Leftovers" section). Extended existing entries: negative parallelism
  (contrast split across two sentences, clipped negative tail), staged
  run-ups (folded into "Let's Break This Down"), vague attributions
  (named-outlet "featured in" lists), grandiose stakes (stock send-off
  phrases and boilerplate sections), short punchy fragments (ALL-CAPS and
  period-separated emphasis). Added the three-tier Severity Triage section
  and marked weak-alone entries. Added the new tells to the Quick
  Self-Check.
* **Update**: Added "Warnings and Cautions Come Before the Step" to
  [procedures-and-lists.md](procedures-and-lists.md) — the WARNING
  (injury/death) / CAUTION (equipment, data, money) / NOTE (information
  only) signal-word pattern with placement before the step it protects.
  Added the check to the Quick Self-Check.
* **Update**: Folded the STE word-count conventions into
  [detailed-guide.md](detailed-guide.md) Rule 2 (numbers with units,
  identifiers, quoted strings, proper nouns, hyphenated words, and
  parenthesized text each count as one word; a colon at the end of a list
  introduction ends the sentence) and added a pointer to the 80%
  calibration in "When to Relax the Rules".
* **Update**: Added a "Strict-STE Mode: No Semicolons" note to
  [punctuation.md](punctuation.md) — reconciles the bundle's
  semicolons-between-independent-clauses rule with strict STE's
  no-semicolon stance (apply the stricter stance only when deliberately
  writing STE-style text). Applied the same reconciliation for
  contractions in both directions: a "Strict-STE mode" note in
  [word-choice.md](word-choice.md) and a matching note under the
  calibration table in
  [ste80-rewrite-method.md](ste80-rewrite-method.md).
* **Update**: Added a plain-word swaps pointer to
  [word-choice.md](word-choice.md) cross-references and an "AI Tells and
  the Rewrite Method" section to
  [simplified-technical-english.md](simplified-technical-english.md).
* **Update**: Added a rewrite-method pointer to the build-time include
  [ste100-simplified-technical-english.md.tmpl](https://github.com/levonk/skills-releases/blob/main/includes/ste100-simplified-technical-english.md.tmpl).
  Renamed the "AI Writing Tells" section to "AI Writing Tells and
  Rewrites" in [index.md](index.md) and
  [overview.md](overview.md). Bumped `date.knowledge-basis` and
  `date.last-used` to 2026-11-13 on all touched pages.

## 2026-09-08

* **Creation**: Authored
  [ai-writing-tells.md](ai-writing-tells.md) — a catalog of AI-specific
  writing patterns to avoid in technical prose and content. Covers word choice
  tells (magic adverbs, "delve", "tapestry", "serves as"), sentence structure
  tells (negative parallelism, "Not X. Not Y. Just Z.", anaphora abuse,
  tricolon abuse), paragraph structure tells (short punchy fragments,
  listicle-in-a-trench-coat), tone tells ("Here's the kicker", false
  vulnerability, grandiose stakes), formatting tells (em dashes, bold-first
  bullets, unicode decoration), and composition tells (fractal summaries, dead
  metaphor, historical analogy stacking, signposted conclusions). Sourced from
  Kevin Lewis's "My Claude.md" blog post
  (<https://lws.io/blog/claude-dot-md/>) and cross-referenced to the Founder
  Content System's universal banned-pattern list
  ([career-advancement-practices/founder-content-system.md](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md))
  as the social-media-specific application.
* **Update**: Banned em dashes in [punctuation.md](punctuation.md). The
  previous guidance recommended em dashes for parenthetical emphasis. The new
  guidance bans em dashes entirely; use commas or parentheses instead. This
  aligns with the AI Writing Tells page (em-dash addiction as a formatting
  tell) and with the Founder Content System's existing "no dashes" rule.
  Updated the em-dash self-check item in
  [punctuation.md](punctuation.md) and the cross-reference in
  [detailed-guide.md](detailed-guide.md).
* **Update**: Added em-dash ban and AI-tell pointer to the build-time include
  [ste100-simplified-technical-english.md.tmpl](https://github.com/levonk/skills-releases/blob/main/includes/ste100-simplified-technical-english.md.tmpl).
  Added the new page to [index.md](index.md) and [overview.md](overview.md)
  concept tables. Bumped `date.knowledge-basis` and `date.last-used` to
  2026-09-08 on the overview.

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
