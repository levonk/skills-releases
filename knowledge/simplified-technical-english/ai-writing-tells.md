---
type: Practice
title: AI Writing Tells
description: A catalog of AI-specific writing patterns to avoid in technical prose and content, with severity triage (act-on-one-sighting tells vs weak-alone tells that only matter in clusters). Covers word choice tells (magic adverbs, "delve", "tapestry", "serves as"), sentence structure tells (negative parallelism, "Not X. Not Y. Just Z.", anaphora abuse, tricolon abuse, stacked qualifiers, hyphenated pairs), paragraph structure tells (short punchy fragments, listicle-in-a-trench-coat), tone tells ("Here's the kicker", false vulnerability, grandiose stakes, arguing with no one, fake-depth sayings, sales language), formatting tells (em-dash addiction, bold-first bullets, decorative headings, unicode decoration), composition tells (one-line closers, fractal summaries, dead metaphor, historical analogy stacking, signposted conclusions, writing about the document, re-explaining what the reader knows), and chatbot/draft leftovers (chatbot residue, knowledge-limit disclaimers, heading echo). Distinct from general STE100 clarity rules: a sentence can be clear and active but still read as AI slop.
tags: [technical-writing, ai-writing-tells, ai-slop, writing-patterns, content-quality, anti-patterns]
date:
  created: "2026-09-08"
  knowledge-basis: "2026-11-13"
  last-used: "2026-11-13"
sources:
  - id: lws-claude-md
    resource: "https://lws.io/blog/claude-dot-md/"
    title: "My Claude.md by Kevin Lewis"
  - id: founder-content-system
    resource: "../career-advancement-practices/founder-content-system.md"
    title: "Founder Content System (sibling bundle) — universal banned-pattern list"
  - id: ste80-humanizer
    resource: "https://github.com/Dodaios/ste80-humanizer"
    title: "STE80 Humanizer — 26-pattern AI-tell catalog and severity triage (MIT)"
    author: "Dodaios"
  - id: blader-humanizer
    resource: "https://github.com/blader/humanizer"
    title: "humanizer — upstream 26-pattern catalog based on Wikipedia's Signs of AI writing (MIT)"
    author: "Siqi Chen"
  - id: wikipedia-ai-writing
    resource: "https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing"
    title: "Wikipedia: Signs of AI writing (WikiProject AI Cleanup)"
---

# AI Writing Tells

AI-generated text has recognizable overuse patterns. These patterns are
distinct from general clarity problems. A sentence can be active, short, and
one-topic-per-sentence and still read as AI slop. The tells are in the
*repetition* of specific rhetorical devices, not in any single use.

This page catalogs the patterns. Use it as a self-check before publishing
AI-assisted prose. The [Founder Content System](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md)
maintains a social-media-specific banned-pattern list that is the applied
subset of this catalog. For the rewrite method that applies this catalog to
existing text, see [STE80 Rewrite Method](ste80-rewrite-method.md).

## Severity Triage

Not every tell justifies an edit on its own. A tell counts in proportion to
how rarely a careful writer would produce it by accident. Three tiers:

- **Act on one sighting.** Chatbot residue, "not X but Y" and its variants,
  one-line closers, staged run-ups, fake-depth sayings, arguing with no one,
  meaning-padding triads, sales language, knowledge-limit disclaimers, text
  that describes the document instead of its subject. Careful writers almost
  never produce these deliberately.
- **Weak alone — act in clusters.** Em dashes, repeated sentence openings,
  stacked qualifiers, hyphenated pairs after the noun, passive voice, curly
  quotes, a lone bolded list label. One sighting is style; a page full of
  them is a tell.
- **Deliberate craft — leave alone.** A single well-placed tricolon, a short
  sentence that lands a real point, a metaphor used once. The problem is
  repetition and reflex, not the device itself.

Entries marked *(weak alone)* below fall in the second tier. Everything
unmarked justifies an edit on one sighting.

## Word Choice Tells

### Magic Adverbs

AI overuses "quietly", "deeply", "fundamentally", "remarkably", and "arguably"
to convey subtle importance. These adverbs make mundane descriptions feel
significant.

**Avoid:**
> quietly orchestrating workflows, decisions, and interactions
> a quiet intelligence behind it

### "Delve" and Friends

"Delve" was the most infamous AI tell. The family includes "certainly",
"utilize", "leverage" (as a verb), "robust", "streamline", and "harness".

**Avoid:**
> Let's delve into the details.
> We certainly need to leverage these robust frameworks.

### "Tapestry" and "Landscape"

AI overuses ornate nouns where simpler words work. "Tapestry" describes
anything interconnected. "Landscape" describes any field. Other offenders:
"paradigm", "synergy", "ecosystem", "framework".

**Avoid:**
> The rich tapestry of human experience.
> Navigating the complex landscape of modern AI.

### The "Serves As" Dodge

AI replaces simple "is" or "are" with "serves as", "stands as", "marks", or
"represents". The repetition penalty pushes the model toward fancier
constructions when a copula would do.

**Avoid:**
> The building serves as a reminder of the city's heritage.
> The station marks a pivotal moment in the evolution of regional transit.

**Use:**
> The building reminds the city of its heritage.
> The station is a pivotal moment in regional transit.

## Sentence Structure Tells

### Negative Parallelism

The "It's not X, it's Y" pattern. The single most common AI writing tell. AI
uses it to create false profundity by framing everything as a surprising
reframe. One instance can be effective. Ten in a blog post is an insult to
the reader. Includes the causal variant "not because X, but because Y" and
the cross-sentence reframe "The question isn't X. The question is Y."

Two harder-to-spot variants:

- **Contrast split across two sentences.** "This doesn't mean tests are
  optional. It means the linter catches the easy errors first." Same formula
  at paragraph scale — merge it into one positive claim.
- **Clipped negative tail.** "The form fills in your address from the
  postcode, no typing." The trailing negation borrows the contrast without
  stating it. Say the positive claim outright: "...so you do not have to
  type it."

**Avoid:**
> It's not bold. It's backwards.
> Half the bugs you chase aren't in your code. They're in your head.

### "Not X. Not Y. Just Z."

The dramatic countdown. AI negates two or more things before revealing the
actual point. Creates a false sense of narrowing down to the truth.

**Avoid:**
> Not a bug. Not a feature. A fundamental design flaw.
> Not ten. Not fifty. Five hundred and twenty-three lint violations.

### "The X? A Y."

Self-posed rhetorical questions answered immediately. The model asks a
question nobody was asking, then answers it for dramatic effect.

**Avoid:**
> The result? Devastating.
> The worst part? Nobody saw it coming.

### Anaphora Abuse

Repeating the same sentence opening multiple times in quick succession.

**Avoid:**
> They assume that users will pay. They assume that developers will build.
> They assume that ecosystems will emerge.

### Tricolon Abuse

Overuse of the rule-of-three pattern, often extended to four or five. A
single tricolon is elegant. Three back-to-back tricolons are a pattern
recognition failure.

**Avoid:**
> Products impress people; platforms empower them. Products solve problems;
> platforms create worlds. Products scale linearly; platforms scale
> exponentially.

### "It's Worth Noting"

Filler transitions that signal nothing. AI uses these to introduce new points
without connecting them to the previous argument. Also includes "It bears
mentioning", "Importantly", "Interestingly", "Notably".

**Avoid:**
> It's worth noting that this approach has limitations.
> Importantly, we must consider the broader implications.

### Superficial Analyses

Tacking a present participle ("-ing") phrase onto the end of a sentence to
inject shallow analysis. Phrases like "highlighting its importance",
"reflecting broader trends", or "contributing to the development of".

**Avoid:**
> contributing to the region's rich cultural heritage
> underscoring its role as a dynamic hub of activity and culture

### False Ranges

"From X to Y" constructions where X and Y are not on any real scale. Legitimate
use implies a spectrum with a meaningful middle. AI uses it as a fancy way to
list two loosely related things.

**Avoid:**
> From innovation to implementation to cultural transformation.
> From problem-solving and tool-making to scientific discovery, artistic
> expression, and technological innovation.

### Stacked Qualifiers *(weak alone)*

Hedges piled on hedges until every claim sounds unsure: "could potentially",
"might arguably", "in some cases it may", "to be fair, it's also possible".
Edit after edit adds qualifiers to repair an earlier overstatement. Keep one
qualifier when the source supports it; a single "perhaps" or "tends to" is
human. See also the honest-modals rule in
[STE80 Rewrite Method](ste80-rewrite-method.md) — keep uncertainty at its
original strength, no more and no less.

**Avoid:**
> This change could potentially possibly cause some issues in certain edge
> cases.

**Use:**
> This change can break requests with empty headers.

### Hyphenated Pairs After the Noun *(weak alone)*

Compound modifiers keep their hyphen in every position: "the API is
well-documented", "the support is long-term", "the feature is client-facing".
The hyphen belongs before the noun ("a well-documented API"), not after it.
Words that always hyphenate (third-party, cross-platform) keep it
everywhere. Mechanical and regex-checkable — one instance is a copyediting
choice, a page full is a tell.

**Avoid:**
> The API is well-documented and the schema is machine-readable.

**Use:**
> The API is well documented and the schema is machine readable.

## Paragraph Structure Tells

### Short Punchy Fragments

Excessive use of very short sentences or fragments as standalone paragraphs
for manufactured emphasis. RLHF training pushes models toward one-thought-per-
sentence writing. No real person writes first drafts this way. Includes the
typographic variants: one word in ALL CAPS for emphasis, and periods after
every word ("every. single. day.").

**Avoid:**
> He published this. Openly. In a book. As a priest.
> These weren't just products. And the software side matched. Then it
> professionalised. But I adapted.
> No setup. No config. No waiting.

### Listicle in a Trench Coat

Numbered or labeled points dressed up as continuous prose. The model writes
a listicle but wraps each point in a paragraph starting with "The first... The
second... The third..." to disguise the format.

**Avoid:**
> The first wall is the absence of a free, scoped API. The second wall is the
> lack of delegated access. The third wall is the absence of scoped
> permissions.

## Tone Tells

### "Here's the Kicker"

False suspense transitions that promise a revelation but deliver a point that
did not need the buildup. Also includes "Here's the thing", "Here's where it
gets interesting", "Here's what most people miss".

**Avoid:**
> Here's the kicker.
> Here's the thing about AI adoption.
> Here's where it gets interesting.

### "Think of It As..."

The patronizing analogy. AI defaults to teacher mode and assumes the reader
needs a metaphor. Often produces analogies that are less clear than the
original concept.

**Avoid:**
> Think of it like a highway system for data.
> Think of it as a Swiss Army knife for your workflow.

### "Imagine a World Where..."

The classic AI invitation to futurism. Begins with "Imagine" followed by a
list of wonderful things that will happen if the reader agrees with the
premise.

**Avoid:**
> Imagine a world where every tool you use has a quiet intelligence behind it.

### False Vulnerability

Simulated self-awareness that reads as performative. The model pretends to
break the fourth wall or admit a bias. Real vulnerability is specific and
uncomfortable. AI vulnerability is polished and risk-free.

**Avoid:**
> And yes, I'm openly in love with the platform model.
> This is not a rant; it's a diagnosis.

### "The Truth Is Simple"

Asserting that something is obvious or simple instead of proving it. Includes
the dramatic reveal variant: "but none of them is the real story. The real
story is..."

**Avoid:**
> The reality is simpler and less flattering.
> History is unambiguous on this point.

### Grandiose Stakes Inflation

Everything is the most important thing ever. AI inflates the stakes of every
argument to world-historical significance. A blog post about API pricing
becomes a meditation on the fate of civilization. The stock-phrase variants:
"a pivotal moment", "stands as a testament", "reflects a broader shift",
"marks an indelible mark", "setting the stage for", "plays a key role", the
"Challenges and Legacy" / "Future Outlook" boilerplate section, and the
optimistic send-off paragraph ("the future looks bright", "exciting times
ahead"). Keep the fact underneath; end on the last concrete fact.

**Avoid:**
> This will fundamentally reshape how we think about everything.
> will define the next era of computing
> Version 2.0 marks a pivotal moment, reflecting a broader shift toward
> developer-first tooling.

**Use:**
> Version 2.0 adds a CLI and drops support for Node 16.

### "Let's Break This Down"

The pedagogical voice that assumes the reader needs hand-holding. Also
includes "Let's unpack this", "Let's explore", "Let's dive in", plus the
broader staged run-up family — any announcement of the point instead of the
point itself: "Here's what you need to know", "without further ado", "now
let's look at", "heads up", "quick note", "Here's the thing", "Let's be
honest", "Real talk", "Honestly?". "Honestly" inside a casual sentence is
normal; the tell is the stand-alone opener before a routine claim.

**Avoid:**
> Let's break this down step by step.
> Let's unpack what this really means.
> Is the paid plan worth it? Honestly? It depends on your team size.

### Vague Attributions

Attributing claims to unnamed authorities. AI invokes "experts", "observers",
"industry reports", and "several publications" without naming anyone. It also
inflates the quantity of sources. A named-outlet variant borrows authority by
listing coverage ("featured in TechCrunch, Wired, and The Verge") without
saying what any of them said or linking to it. Name who said what and let the
reader verify it; otherwise cut the claim. Never invent a source.

**Avoid:**
> Experts argue that this approach has significant drawbacks.
> Industry reports suggest that adoption is accelerating.
> The project has been featured in TechCrunch, Wired, and Hacker News.

### Invented Concept Labels

AI clusters invented compound labels that sound analytical without being
grounded. It appends abstract problem-nouns (paradox, trap, creep, divide,
vacuum, inversion) to domain words. Multiple such labels in the same piece is
a strong signal of AI slop.

**Avoid:**
> the supervision paradox
> the acceleration trap
> workload creep

### Arguing With No One

The text answers an objection nobody raised: "To be clear", "I'm not saying",
"Don't get me wrong", "This is not to say", "A tempting approach would be",
"One might be tempted to", "You might think... but", "It would be easy to
just". Usually it is leftover scaffolding from a draft, or the model hedging
against a reader it imagines. Remove the defense; if it holds a real claim,
state the claim. Keep an objection only when someone in the actual context
made it.

**Avoid:**
> To be clear, I'm not saying microservices are bad. A tempting approach
> would be to split everything at once, but that would break the deploy. We
> split the billing service first.

**Use:**
> We split the billing service out first.

### Sayings That Sound Deep

Stock phrases that dress an ordinary point as a hidden truth: "at its core",
"the real question is", "in reality", "what really matters", "the deeper
issue", "the heart of the matter", "X is the Y of Z", "not a tool but a
mirror", "the language of", "the currency of". The dressing adds no detail.
Replace the saying with the specific claim.

**Avoid:**
> At its core, observability is the language of trust between teams.

**Use:**
> Shared dashboards let the on-call team see what the API team sees.

### Sales Language

The text reads like an advertisement: "groundbreaking", "world-class",
"best-in-class", "cutting-edge", "stunning", "breathtaking", "renowned",
"must-try", "nestled in the heart of", "featuring a diverse array of",
"commitment to excellence". State what the thing is and what it does.

**Avoid:**
> Nestled in the heart of your workflow, our groundbreaking editor delivers
> a world-class writing experience.

**Use:**
> The editor runs inside VS Code and checks spelling as you type.

## Formatting Tells

### Em Dashes

Do not use em dashes (—). Use commas or parentheses instead. AI overuses em
dashes for dramatic pauses, parenthetical asides, and pivot points. A human
writer might use 2-3 per piece. AI will use 20+. See
[Punctuation](punctuation.md) for the em-dash ban.

**Avoid:**
> The problem—and this is the part nobody talks about—is systemic.
> Not recklessly, not completely—but enough to matter.

**Use:**
> The problem (and this is the part nobody talks about) is systemic.
> Not recklessly, not completely, but enough to matter.

### Bold-First Bullets

Every bullet point starts with a bolded phrase. Almost nobody formats lists
this way when writing by hand. It is a telltale sign of AI-generated
documentation, blog posts, and README files.

**Avoid:**
> **Security**: Environment-based configuration with...
> **Performance**: Lazy loading of expensive resources...

### Unicode Decoration

Use of unicode arrows, smart/curly quotes, and other special characters that
cannot be easily typed on a standard keyboard. Real writers produce straight
quotes and ASCII arrows. *(Curly quotes alone are weak alone — many editors
curl quotes automatically; in Markdown and code, use straight quotes.)*

**Avoid:**
> Input then Processing then Output (with unicode arrows)
> "Smart quotes" instead of straight "quotes"

### Decorative Headings

Headings written for effect rather than for navigation: Title Case on every
word, emoji and arrows in the heading, a rule separating every section, or a
heading that performs instead of names ("The decision, on one screen").
Use sentence case and name what the section holds ("How the options
compare"). A five-sentence answer does not need three headings.

**Avoid:**
> ## 🚀 Getting Started With The CLI →

**Use:**
> ## Install the CLI

## Composition Tells

### One-Line Closers

A one-sentence paragraph that repeats or inflates the paragraph before it:
"That's the real win.", "That distinction matters.", "Let that sink in.",
"Read that again.", or a sentence that names what an example just showed
("This shows the importance of..."). The same closer repeated after each
section is the tell at document scale. The line asks the reader to pause on
a claim instead of adding to it. A short sentence is fine when it carries a
new fact; cut the closer that only applauds.

**Avoid:**
> We moved the API to edge workers. Latency dropped to 40 ms.
>
> That's the power of the edge.
>
> Caching cuts repeat work. That's the real win.
> Retries hide short outages. That's the real win.

**Use:**
> Caching cuts repeat work. Retries hide short outages.

### Fractal Summaries

"What I'm going to tell you; what I'm telling you; what I just told you"
applied at every level. Every subsection gets a summary. Every section gets a
summary. The document itself gets a summary.

**Avoid:**
> In this section, we'll explore... [3000 words later] ...as we've seen in
> this section.
> A conclusion that restates every point already made in the previous 3000
> words.

### The Dead Metaphor

Latching onto a single metaphor and beating it into the ground. A human
writer introduces a metaphor, uses it, then moves on. AI repeats the same
metaphor 5-10 times.

**Avoid:**
> The ecosystem needs ecosystems to build ecosystem value.
> Walls and doors used 30+ times in the same article.

### Historical Analogy Stacking

Rapid-fire listing of historical companies or tech revolutions to build false
authority. Especially common in technical writing.

**Avoid:**
> Apple didn't build Uber. Facebook didn't build Spotify. Stripe didn't
> build Shopify. AWS didn't build Airbnb.
> Every major technological shift, the web, mobile, social, cloud, followed
> the same pattern.

### One-Point Dilution

Making a single argument and restating it in 10 different ways across
thousands of words. The model pads a simple thesis to feel "comprehensive" by
rephrasing the same idea with different metaphors, examples, and framings.

**Avoid:**
> The same point, restated eight ways across 4000 words.
> Each section rephrases the thesis with a different metaphor but adds
> nothing new.

### Content Duplication

Repeating entire sections or paragraphs verbatim within the same piece. This
happens when the model loses track of what it has already written, especially
in longer pieces.

**Avoid:**
> The same section appeared twice, word-for-word identical.
> Paragraph 3 and paragraph 17 are the same sentence reworded.

### The Signposted Conclusion

Explicitly announcing the conclusion with "In conclusion", "To sum up", or
"In summary". Competent writing does not need to tell the reader it is
concluding. The reader can feel it.

**Avoid:**
> In conclusion, the future of AI depends on...
> To sum up, we've explored three key themes.

### "Despite Its Challenges..."

The rigid formula where AI acknowledges problems only to immediately dismiss
them. Always follows the same beat: "Despite its [positive words], [subject]
faces challenges..." then ends with "Despite these challenges, [optimistic
conclusion]."

**Avoid:**
> Despite these challenges, the initiative continues to thrive.
> Despite its industrial and residential prosperity, Korattur faces
> challenges typical of urban areas.

### Writing About the Document Instead of Its Subject

The text describes itself rather than its subject: what the text replaced
("was added to replace the old approach"), how it was produced ("generated
from", "compiled from", "anything unconfirmed is flagged"), or a layout the
reader can already see ("the table below compares", "this section is
organized by", "in this guide, we will"). Mention an old version only in
change logs and migration guides. Keep a source credit the reader can
follow; cut the story of how the document was made.

**Avoid:**
> This function was added to replace the old approach of looping through all
> users, which caused O(n²) performance.
> The table below compares the three options.

**Use:**
> This function looks up users in a hash map, so each lookup is O(1).

### Re-Explaining What the Reader Knows

In a reply — a thread answer, a code-review comment, a chat response — the
model rebuilds the entire context the other person already has: it restates
the problem, walks the diagnosis, shows the evidence, and puts the decision
in the last line. Each sentence reads fine alone, so this tell survives a
sentence-level cleanup. Lead with the decision; keep only what could change
the reader's mind — usually one fact they lack and any link they need. Act
on this tell only when the conversation context is visible or the text is
plainly a reply.

**Avoid:**
> Yes, you're right that the cron job fails on the first of the month. I
> looked into it: the job uses the local time zone, and on the first the
> date math rolls back to the previous month, which has fewer days. I tested
> it with three dates. So I think we should switch to UTC.

**Use:**
> Agreed — switch the job to UTC. The local time zone breaks the date math
> on the first of the month.

## Chatbot Residue and Draft Leftovers

The most certain tells: wrappers and scaffolding that should never have
reached the page. Remove outright — no rewriting needed, keep the content.

### Chatbot Residue

A chatbot's greeting, praise, offer, or sign-off left in text that should
stand alone: "Great question!", "Of course!", "Certainly!", "You're
absolutely right", "I hope this helps", "Let me know if...", "Would you
like...", "Want me to...?", "Should I continue?", "Happy to help", "here is
a...". The wrapper survives because it frames real content.

**Avoid:**
> Great question! Here's an overview of how JWTs work. A JWT has three
> parts: a header, a payload, and a signature. I hope this helps! Let me
> know if you'd like more detail.

**Use:**
> A JWT has three parts: a header, a payload, and a signature.

### Knowledge-Limit Disclaimers and Guesses

The text announces where the model's knowledge ends, or admits it found no
source and then fills the gap with a guess: "as of my last update", "based
on available information", "while specific details are limited", "not
publicly available", "not widely documented", "maintains a low profile",
"it is believed that", "likely grew up". State plainly what the sources do
not show — or cut the sentence. Never rewrite a guess into a claim.

**Avoid:**
> While details about the library's origins are limited, it was likely
> created around 2015 to address performance concerns.

**Use:**
> The sources do not say when the library was created.

### Heading Repeated in the First Sentence

A heading followed by a one-line paragraph that repeats it. The line adds
nothing the heading did not say. Remove it.

**Avoid:**
> ## Security
>
> Security is important.
>
> The server rejects tokens older than one hour.

**Use:**
> ## Security
>
> The server rejects tokens older than one hour.

## Quick Self-Check

Before publishing AI-assisted prose, check for these tells:

- [ ] No negative parallelism ("It's not X, it's Y") repeated more than once
- [ ] No "Not X. Not Y. Just Z." countdown patterns
- [ ] No self-posed rhetorical questions ("The X? A Y.")
- [ ] No anaphora abuse (same sentence opening 3+ times in succession)
- [ ] No tricolon abuse (3+ back-to-back rule-of-three patterns)
- [ ] No magic adverbs ("quietly", "deeply", "fundamentally", "remarkably")
- [ ] No "delve", "leverage" (as verb), "utilize", "robust", "streamline"
- [ ] No "tapestry", "landscape", "paradigm", "synergy", "ecosystem" as ornate nouns
- [ ] No "serves as" / "stands as" / "marks" replacing simple "is" or "are"
- [ ] No "It's worth noting" / "Importantly" / "Interestingly" filler transitions
- [ ] No superficial "-ing" analyses ("highlighting its importance")
- [ ] No false ranges ("from X to Y" where no spectrum exists)
- [ ] No stacked qualifiers ("could potentially", "might arguably") — one
      qualifier at the source's strength
- [ ] No hyphenated pairs after the noun ("the API is well-documented" →
      "well documented")
- [ ] No short punchy fragments as standalone paragraphs
- [ ] No listicle-in-a-trench-coat ("The first... The second... The third...")
- [ ] No "Here's the kicker" / "Here's the thing" false suspense
- [ ] No "Think of it as..." patronizing analogies
- [ ] No "Imagine a world where..." futurism invitations
- [ ] No false vulnerability ("And yes, I'm openly in love with...")
- [ ] No "The truth is simple" / "History is clear" assertions
- [ ] No grandiose stakes inflation ("fundamentally reshape everything",
      "pivotal moment", "the future looks bright")
- [ ] No "Let's break this down" pedagogical hand-holding or staged run-ups
      ("Here's what you need to know", "without further ado")
- [ ] No vague attributions ("Experts argue...", "Industry reports
      suggest...", unverifiable "featured in" outlet lists)
- [ ] No invented concept labels ("supervision paradox", "acceleration trap")
- [ ] No arguing with no one ("To be clear", "A tempting approach would
      be...", "You might think...but")
- [ ] No fake-depth sayings ("at its core", "the real question is",
      "X is the Y of Z")
- [ ] No sales language ("groundbreaking", "world-class", "nestled in the
      heart of")
- [ ] No em dashes (use commas or parentheses)
- [ ] No bold-first bullets (every bullet starting with a bolded phrase)
- [ ] No decorative headings (Title Case, emoji/arrows, headings written for
      effect — use sentence case and name the section's contents)
- [ ] No unicode decoration (arrows, smart quotes)
- [ ] No fractal summaries (summary at every structural level)
- [ ] No dead metaphors (same metaphor repeated 5+ times)
- [ ] No historical analogy stacking (rapid-fire company/tech comparisons)
- [ ] No one-point dilution (same argument restated 8+ ways)
- [ ] No content duplication (verbatim or near-verbatim paragraph repeats)
- [ ] No signposted conclusions ("In conclusion", "To sum up")
- [ ] No "Despite its challenges..." dismiss-and-continue formula
- [ ] No one-line closers that repeat the point ("That's the real win",
      "Let that sink in")
- [ ] No writing about the document ("was added to replace", "the table
      below compares", "in this guide we will")
- [ ] No re-explaining what the reader knows (in a reply, lead with the
      decision)
- [ ] No chatbot residue ("Great question!", "I hope this helps",
      "Would you like...")
- [ ] No knowledge-limit disclaimers ("as of my last update", "it is
      believed that")
- [ ] No heading echoed verbatim in its first sentence

## Relationship to Other Concepts

- **[Simplified Technical English](simplified-technical-english.md)** — The
  core clarity rules (active voice, short sentences, one-word-one-meaning).
  This page covers patterns that survive those rules. A sentence can be clear
  and active but still read as AI slop.
- **[Punctuation](punctuation.md)** — The em-dash ban lives here. This page
  cross-references it as a formatting tell.
- **[Word Choice and Consistency](word-choice.md)** — Covers slang, jargon,
  abbreviations, and consistency. This page covers AI-specific word choices
  ("delve", "tapestry") that are a different category from general word
  choice.
- **[Founder Content System](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md)**
  — The social-media-specific application of this catalog. The Founder
  Content System's universal banned-pattern list is the applied subset for
  ghostwriting founder social content across X, LinkedIn, Instagram, TikTok,
  YouTube, Facebook, and blog.
- **[STE80 Rewrite Method](ste80-rewrite-method.md)** — The two-pass rewrite
  protocol that applies this catalog: Pass 1 removes the tells, Pass 2
  rebuilds sentence structure at ~80% of ASD-STE100. Includes the fidelity
  rules and the when-not-to-act list that bound every edit.

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Rewrite method (applies this catalog): [STE80 Rewrite Method](ste80-rewrite-method.md)
- Punctuation (em-dash ban): [Punctuation](punctuation.md)
- Word choice and consistency: [Word Choice and Consistency](word-choice.md)
- Procedures and lists: [Procedures and Lists](procedures-and-lists.md)
- Founder content system (social-media application): [Founder Content System](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md)
- Bundle index: [index.md](index.md)
