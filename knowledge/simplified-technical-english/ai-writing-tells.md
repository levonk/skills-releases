---
type: Practice
title: AI Writing Tells
description: A catalog of AI-specific writing patterns to avoid in technical prose and content. Covers word choice tells (magic adverbs, "delve", "tapestry", "serves as"), sentence structure tells (negative parallelism, "Not X. Not Y. Just Z.", anaphora abuse, tricolon abuse), paragraph structure tells (short punchy fragments, listicle-in-a-trench-coat), tone tells ("Here's the kicker", false vulnerability, grandiose stakes), formatting tells (em-dash addiction, bold-first bullets, unicode decoration), and composition tells (fractal summaries, dead metaphor, historical analogy stacking, signposted conclusions). Distinct from general STE100 clarity rules: a sentence can be clear and active but still read as AI slop.
tags: [technical-writing, ai-writing-tells, ai-slop, writing-patterns, content-quality, anti-patterns]
date:
  created: "2026-09-08"
  knowledge-basis: "2026-09-08"
  last-used: "2026-09-08"
sources:
  - id: lws-claude-md
    resource: "https://lws.io/blog/claude-dot-md/"
    title: "My Claude.md by Kevin Lewis"
  - id: founder-content-system
    resource: "../career-advancement-practices/founder-content-system.md"
    title: "Founder Content System (sibling bundle) — universal banned-pattern list"
---

# AI Writing Tells

AI-generated text has recognizable overuse patterns. These patterns are
distinct from general clarity problems. A sentence can be active, short, and
one-topic-per-sentence and still read as AI slop. The tells are in the
*repetition* of specific rhetorical devices, not in any single use.

This page catalogs the patterns. Use it as a self-check before publishing
AI-assisted prose. The [Founder Content System](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md)
maintains a social-media-specific banned-pattern list that is the applied
subset of this catalog.

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

## Paragraph Structure Tells

### Short Punchy Fragments

Excessive use of very short sentences or fragments as standalone paragraphs
for manufactured emphasis. RLHF training pushes models toward one-thought-per-
sentence writing. No real person writes first drafts this way.

**Avoid:**
> He published this. Openly. In a book. As a priest.
> These weren't just products. And the software side matched. Then it
> professionalised. But I adapted.

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
becomes a meditation on the fate of civilization.

**Avoid:**
> This will fundamentally reshape how we think about everything.
> will define the next era of computing

### "Let's Break This Down"

The pedagogical voice that assumes the reader needs hand-holding. Also
includes "Let's unpack this", "Let's explore", "Let's dive in".

**Avoid:**
> Let's break this down step by step.
> Let's unpack what this really means.

### Vague Attributions

Attributing claims to unnamed authorities. AI invokes "experts", "observers",
"industry reports", and "several publications" without naming anyone. It also
inflates the quantity of sources.

**Avoid:**
> Experts argue that this approach has significant drawbacks.
> Industry reports suggest that adoption is accelerating.

### Invented Concept Labels

AI clusters invented compound labels that sound analytical without being
grounded. It appends abstract problem-nouns (paradox, trap, creep, divide,
vacuum, inversion) to domain words. Multiple such labels in the same piece is
a strong signal of AI slop.

**Avoid:**
> the supervision paradox
> the acceleration trap
> workload creep

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
quotes and ASCII arrows.

**Avoid:**
> Input then Processing then Output (with unicode arrows)
> "Smart quotes" instead of straight "quotes"

## Composition Tells

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
- [ ] No short punchy fragments as standalone paragraphs
- [ ] No listicle-in-a-trench-coat ("The first... The second... The third...")
- [ ] No "Here's the kicker" / "Here's the thing" false suspense
- [ ] No "Think of it as..." patronizing analogies
- [ ] No "Imagine a world where..." futurism invitations
- [ ] No false vulnerability ("And yes, I'm openly in love with...")
- [ ] No "The truth is simple" / "History is clear" assertions
- [ ] No grandiose stakes inflation ("fundamentally reshape everything")
- [ ] No "Let's break this down" pedagogical hand-holding
- [ ] No vague attributions ("Experts argue...", "Industry reports suggest...")
- [ ] No invented concept labels ("supervision paradox", "acceleration trap")
- [ ] No em dashes (use commas or parentheses)
- [ ] No bold-first bullets (every bullet starting with a bolded phrase)
- [ ] No unicode decoration (arrows, smart quotes)
- [ ] No fractal summaries (summary at every structural level)
- [ ] No dead metaphors (same metaphor repeated 5+ times)
- [ ] No historical analogy stacking (rapid-fire company/tech comparisons)
- [ ] No one-point dilution (same argument restated 8+ ways)
- [ ] No content duplication (verbatim or near-verbatim paragraph repeats)
- [ ] No signposted conclusions ("In conclusion", "To sum up")
- [ ] No "Despite its challenges..." dismiss-and-continue formula

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

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Punctuation (em-dash ban): [Punctuation](punctuation.md)
- Word choice and consistency: [Word Choice and Consistency](word-choice.md)
- Procedures and lists: [Procedures and Lists](procedures-and-lists.md)
- Founder content system (social-media application): [Founder Content System](https://github.com/levonk/skills-releases/blob/main/knowledge/career-advancement-practices/founder-content-system.md)
- Bundle index: [index.md](index.md)
