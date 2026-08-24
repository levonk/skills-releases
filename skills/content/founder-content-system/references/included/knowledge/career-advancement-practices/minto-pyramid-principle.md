---
type: Practice
title: Minto Pyramid Principle
description: Barbara Minto's Pyramid Principle for structured communication — answer-first (governing thought on top), MECE groupings of same-kind ideas in logical order, SCQA introductions, the Key Line, top-down vs bottom-up construction, the So-What and Why tests, the Gate (when NOT to use pyramid), evidence taxonomy and strength classification, the mechanics-vs-reasons test, the duplication test, problem definition (R1/R2), diagnostic frameworks, logic trees, tiered renderers, depth levels, the confidence contract, and applications to interview answers, presentations, and written communication throughout the hiring pipeline.
tags: [communication, structured-thinking, minto, pyramid-principle, scqa, mece, bluf, executive-communication, interview-answers, presentations, problem-definition, logic-trees, evidence-strength]
date:
  created: "2026-08-21"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
sources:
  - id: minto-pyramid-principle
    resource: "Barbara Minto, The Pyramid Principle (2009 revised edition)"
    title: "The Pyramid Principle: Logic in Writing and Thinking"
  - id: smplx-c-minto-skill
    resource: "https://github.com/smplx-c/minto-skill"
    title: "smplx-c/minto-skill — three logic rules, 7-step build, validation, epistemic discipline, tiered renderers, depth levels"
  - id: welltraum-minto
    resource: "https://github.com/welltraum/minto"
    title: "welltraum/minto — five modes (intent/audit/write/digest/viz), dose-the-Situation, kind-comes-first, mechanics-vs-reasons test, duplication test, failure catalogue, scoring rubric"
  - id: millwright-labs-minto-pyramid-skill
    resource: "https://github.com/millwright-labs/minto-pyramid-skill"
    title: "millwright-labs/minto-pyramid-skill — the Gate, offer-rather-than-act, do-not-force-three, invent-nothing, when-not-to-use-it, red flags"
  - id: damianof-minto-skill
    resource: "https://github.com/damianof/minto-skill"
    title: "damianof/minto-skill — brutal Level 1 test, 4-type evidence taxonomy, evidence strength classification, principle piece vs case study piece, subject test"
  - id: profeullerbarros-minto-pyramid-principle
    resource: "https://github.com/ProfEullerBarros/minto-pyramid-principle"
    title: "ProfEullerBarros/minto-pyramid-principle — problem definition (R1/R2), diagnostic frameworks, logic trees, visual reflection, deduction vs induction choice"
  - id: tyroneross-pyramid-principle
    resource: "https://github.com/tyroneross/pyramid-principle"
    title: "tyroneross/pyramid-principle — source-integrity layer, confidence contract, carry key terms, given-to-new flow, grammatical parallelism, direct writing contract"
  - id: patrick204nqh-skills
    resource: "https://github.com/patrick204nqh/skills"
    title: "patrick204nqh/skills — BLUF vs Minto distinction, one pyramid per doc, numbers over adjectives, restructure don't summarise, don't force pyramid onto bad reasoning"
  - id: geb-algebra-writer-skill
    resource: "https://github.com/geb-algebra/writer-skill"
    title: "geb-algebra/writer-skill — multiple pyramid configuration with bridge questions, max 4 levels/4 children, don't use body-defined terms in introduction"
  - id: that-in-rust-agent-room
    resource: "https://github.com/that-in-rust/agent-room-of-requirements"
    title: "that-in-rust/agent-room-of-requirements — action ideas must state end products, seven common reader positions, issue analysis (yes-or-no questions), storyboarding workflow"
  - id: refoundai-lenny-skills
    resource: "https://github.com/refoundai/lenny-skills"
    title: "refoundai/lenny-skills — SCR + Minto combined (SCR wraps, Minto structures Resolution), burying the ask, ignoring the Situation"
  - id: santos-sanz-lifeskills
    resource: "https://github.com/santos-sanz/lifeskills"
    title: "santos-sanz/lifeskills — evidence + implication + risk triple, closing contract (decision/owner/date/next action), one governing question, ask-before-drafting"
  - id: synthesized-practice
    resource: "general industry practice"
    title: "Synthesized from established communication and consulting practices"
---

# Minto Pyramid Principle

The Pyramid Principle is a structured-thinking method developed by Barbara
Minto at McKinsey. Its core idea: **state the answer first, then the reasons,
then the evidence** — in a pyramid shape where each level summarizes the level
below. The principle is not a writing style; it is a thinking tool that forces
you to work out the argument before drafting the communication.

In the hiring pipeline, the Pyramid Principle applies to interview answers,
presentations, demo talks, cover letters, follow-up emails, and salary
negotiation framing. Candidates who communicate answer-first are perceived as
more senior, more organized, and more confident — the same "safe pair of hands"
signal the resume is optimized for.

This concept page synthesizes the principle from Barbara Minto's original
framework and eleven open-source AI skill implementations that package it for
practical use.

## The Gate: When NOT to Use the Pyramid

Before applying the pyramid, ask: **does this communication ask its reader to
accept a judgment or make a decision?** The pyramid is for communications
that carry a conclusion or a recommendation. It is NOT for:

| Type | Why pyramid fails | What to do instead |
|------|-------------------|--------------------|
| **Timelines, incident write-ups** | Chronology IS the content; reordering destroys meaning | Keep time order; tighten prose |
| **Runbooks, procedures, tutorials** | Sequential execution is the point | Keep step order |
| **Storytelling, marketing hooks** | Withholding is the point — suspense requires building up | Lead with the hook, not the conclusion |
| **Exploratory thinking** | Forcing a conclusion you haven't reached is dishonest | Run the buried-lede test; admit if there's no single conclusion yet |
| **Hostile audience / bad news** | Reader rejects the conclusion before hearing why | Lead with the shared problem; let the answer land one beat later — still in the first paragraph, never on page two |

If the answer to the gate question is "no," say so and stop. Do not impose
pyramid structure on content whose value is the sequence.

## The Core Idea: Answer First

The reader (or listener) has a question. Give them the answer before the
supporting detail. This is the opposite of how most people naturally
communicate — building up to a conclusion through a chain of reasoning. The
pyramid inverts that instinct.

```
                    Governing Thought
                   /        |         \
              Key Line   Key Line   Key Line
              /  \         |          /  \
           Support Support Support Support Support
```

The **Governing Thought** is the single sentence that answers the reader's
question. The **Key Line** is the 2–4 major supporting points. Below each Key
Line point sits the evidence, findings, and reasoning that supports it.

### Why Answer-First Works in Interviews

Interviewers are time-constrained and mentally taxed. A candidate who opens
with the conclusion lets the interviewer relax and listen for confirmation
rather than working to assemble the point from scattered details. A candidate
who builds up to the conclusion forces the interviewer to hold multiple
threads in working memory while wondering "where is this going?"

The answer-first pattern is also called **BLUF** (Bottom Line Up Front) in
military and intelligence communication. It signals executive presence.

### BLUF vs Minto: When to Use Which

BLUF and Minto are related but distinct tools. Know which one the situation
calls for:

| Tool | What it is | When to use | Length |
|------|-----------|-------------|--------|
| **BLUF** | The opening sentence — the answer, conclusion, or ask | Short-form messages (Slack, email, PR comment, status update) where one sentence carries the answer | Under 100 words |
| **Minto** | The whole pyramid — answer + reasons + evidence | Longer-form arguments (proposals, RFCs, decision memos, strategy docs, interview answers) with more than one supporting reason | 300+ words |

**BLUF is the lede; Minto is the whole pyramid.** If the message is short
enough that one opening sentence does the job, use BLUF. If there are multiple
supporting reasons that need their own evidence, use Minto. In an interview,
a one-line answer to a quick screening question is BLUF; a behavioral story
with multiple supporting points is Minto.

### One Pyramid Per Document

If you have two answers, you have two documents. Don't braid them. A single
pyramid answers a single question. If a communication must address multiple
questions, either split it into multiple communications or use the multiple-
pyramid configuration described below.

### The Brutal Level 1 Test

The Governing Thought must pass a brutal test. If any of the following are
true, the answer is not ready:

- It takes more than one sentence to state
- It names a topic without taking a position ("meetings," "hiring," "pricing"
  are topics, not conclusions)
- It hedges with "it depends," "sometimes," or "in some cases"
- It is so broad that no reasonable reader would disagree ("good marketing
  matters")
- It is a question (the answer is what the question resolves to)

A real Governing Thought is **contestable** — someone could disagree with it.
"A one-hour meeting with eight people is an eight-hour meeting in disguise" is
a conclusion. "Meetings" is a topic.

## The Three Logic Rules

Every pyramid must obey three rules. Violating any of them produces a structure
that looks organized but fails under scrutiny.

### Rule 1 — The Parent Must Summarize the Children

Every statement above a group must be a genuine summary, synthesis, or logical
conclusion derived from the statements immediately below it. Ask: *Can this
parent statement genuinely be derived from all of its children?* If not,
regroup or rewrite.

**Good:**

```
Mobile UX is the primary conversion problem
├── Mobile conversion declined 22%
├── Mobile bounce rate increased 15%
└── Mobile PDP exits increased 30%
```

**Bad:**

```
Mobile UX is the primary conversion problem
├── Mobile conversion declined
├── Google Ads spend increased
└── New checkout launched in September
```

The bad example fails because "Google Ads spend" and "New checkout" do not
support the conclusion about mobile UX. The parent is not a summary of the
children — it is a topic label with loosely related items underneath.

### Rule 2 — Ideas in a Group Must Be the Same Kind

Sibling statements must answer the same question, serve the same logical
function, and sit at approximately the same level of abstraction. Valid
sibling groups are things of one kind: reasons, causes, effects, actions,
options, steps, findings, risks, components, or criteria. Do not mix logical
types within one group.

**Kind comes first.** Before filling a group, name out loud the kind the
question demands:

| Reader's question | Kind of the elements |
|-------------------|----------------------|
| Why? Is this a good idea? | **reasons** — what the reader gains or loses, never how the thing works |
| How? What do we do? | **actions or changes** — never the current state |
| Of what? What is it made of? | **parts** of one whole |
| Which one? | **options**, and separately the **criteria** for choosing |

A tidy list of the wrong kind passes the same-kind test and still fails the
reader — the kind comes first.

### The Mechanics-vs-Reasons Test

The commonest miss: writing mechanics while believing you wrote reasons. Test
every element of a *reasons* group by rephrasing it as **"the system can X"** —
if that reads naturally, it is mechanics, and the reason is what the reader
gets out of it.

- "The file format is compatible" is **mechanics**
- "We will finally have the data we lack" is a **reason**

When the source describes only mechanics, the reasons are still there to be
derived: for each mechanic ask what the reader ends up with once it works, put
that on the first level, and hang the mechanic under it as its support.

### Rule 3 — Ideas in a Group Must Follow a Logical Order

Every sibling group must have an identifiable ordering principle:

| Order type | When to use | Key question |
|------------|-------------|--------------|
| **Chronological** | Processes, timelines, causal chains | What comes first, second, third? |
| **Structural** | Parts of a whole (functions, regions, units) | What parts make up the whole? |
| **Ranking** | Elements ranked by size, risk, benefit, importance | What matters most, and why? |
| **Deductive** | A chain of premises leading to a conclusion | If A and B hold, what follows? |
| **Inductive** | Independent observations rolling up into one conclusion | What do these facts have in common? |

Time, structure, and ranking govern how you group and present. Deduction and
induction govern how the argument unfolds. Both questions need an answer; they
are not alternatives to each other.

Ask: *Why does B come after A?* If no meaningful answer exists, the ordering is
arbitrary and the group is probably not yet properly understood.

### Do Not Force Three

Three is a consulting convention, not one of Minto's rules. The logic
determines the count. Two reasons that genuinely cover the case beat three
where one is a detail wearing a reason's clothing. A fourth real reason beats
three plus filler. If a list runs long, subgroup it rather than making the
reader hold seven things at once.

### Deduction vs Induction at the Key Line

Prefer **induction** at the Key Line when the reader must absorb the structure
quickly — inductive groups can be skimmed. Keep **deductive** chains short;
they cannot be skimmed because each premise depends on the previous one. A
common failure is **false deduction** — sounds like logic, but the middle
premise is never proven. Recast as induction or comparison if the middle
premise doesn't hold.

## MECE

Groups should be **Mutually Exclusive and Collectively Exhaustive** — sibling
categories should not materially overlap, and together they should cover the
relevant whole sufficiently for the decision or argument.

```
Revenue
├── Traffic
├── Conversion Rate
└── Average Order Value
```

Do not force artificial completeness. A useful, decision-relevant structure
beats invented categories created only to make a framework look MECE. In an
interview answer, three well-chosen points that cover the real substance are
stronger than five points where two are padding.

### The Duplication Test

Cover one first-level branch with your hand. If its supports still fit under
the branches that remain, and the question is still answered without it, it
was a **duplicate** — merge it. Then find the real second branch: it is usually
sitting among the observations, demoted by the author.

### No False Grouping

A tidy-looking list can reflect the author's association chain rather than the
structure of the subject. Ask: is this how the subject is built, or how I
happened to recall it?

## SCQA — The Introduction Pattern

The **SCQA** pattern frames the pyramid with a story-like introduction that
establishes why the communication matters:

| Element | What it covers |
|---------|----------------|
| **S**ituation | The accepted starting context — what the reader already agrees with |
| **C**omplication | What changed, failed, conflicts, or creates urgency |
| **Q**uestion | The issue that logically follows from the complication |
| **A**nswer | The Governing Thought — your main conclusion |

The Situation is what the reader already knows — do not include anything
debatable here. The Complication is the disruption that makes the Situation
unstable. The Question arises naturally from the Complication. The Answer is
the Governing Thought of the pyramid.

### Dose the Situation by Audience

The Situation is dosed by what the reader already holds, with breadth of
readership as the proxy — the wider the circle, the less is shared, the
further back you start:

| Reader | Situation |
|-------|-----------|
| One person who asked for this, or was in the room | The request itself — one clause, or nothing |
| A small group already briefed | One or two sentences of the fact they all hold |
| A body or circulation list that was not in the room | The full story, pitched at the least-informed reader who must act |

Then cut back: cover any Situation sentence — if the Complication still bites
without it, it was a run-up, not a Situation.

### SCQA Anti-Patterns

| Anti-pattern | Why it fails | Fix |
|--------------|-------------|-----|
| Heading "Introduction," "Background," "Context" | Not on the same abstraction level as the Key Line | Run the story as prose, no heading |
| Statement of purpose ("the purpose of this memo is to…") | Names the topic, answers nothing, not a Situation | Delete; open with the Situation or the Answer |
| Long run-up ("as you know, last quarter we worked hard…") | Situation-shaped padding that never reaches a Complication | Cover the sentence: if the Complication still bites, cut it |
| Situation the reader would argue with | It needs proof, so it is an argument, not common ground | Move it below, as a support under the Key Line |
| SCQ labels on a four-sentence note | Apparatus wider than the document | Answer first, the reasons in the same sentence |
| The Question never reaches the page | S and C delivered, reader left to guess what is answered | One literal question, or a first line it is visibly the answer to |

### SCQA in an Interview Answer

When an interviewer asks "Tell me about a time you led a challenging project,"
a pyramid-structured answer uses SCQA implicitly:

> **S:** "My team owned the checkout service processing $2M daily."
> **C:** "During Black Friday prep, we discovered a race condition that could
> double-charge users under peak load."
> **Q:** (implicit) "How did you resolve it?"
> **A:** "I led the investigation and fix, achieving zero double-charges on
> Black Friday with 3x normal traffic."

The answer leads with the conclusion (zero double-charges), then the Key Line
supports it (investigation, fix, cross-team audit). Compare this to the
common failure: starting with "So, I was working at Company X in 2023..." and
building up to the result five minutes later.

### SCR + Minto Combined

SCR (Situation-Complication-Resolution) and the Minto Pyramid are often
combined: **SCR provides the narrative wrapper, and the Minto Pyramid
structures the Resolution section specifically.** The Situation and
Complication set up the context; the Resolution is the pyramid — answer
first, then reasons, then evidence.

```
SCR wrapper:
  Situation → Complication → Resolution (pyramid)
                                 ├── Answer (Governing Thought)
                                 ├── Key Line (2-4 reasons)
                                 └── Evidence under each
```

The best executive communication starts with a non-controversial set of facts
that everyone can agree on (the Situation), then introduces the Complication,
then delivers the Resolution as a pyramid. This avoids the failure mode of
proposing solutions without shared context, which leads to misalignment and
unnecessary debate over the problem itself.

### Burying the Ask

A common failure in written communication: **burying the ask**. Unclear
requests create friction and delay the help or decisions you need. The ask
must be visible — in the Governing Thought or the first Key Line point, not
in paragraph four. The [Recruiter Outreach](recruiter-outreach.md) message
structure follows this principle: the value proposition (the ask) comes first.

## Evidence: Taxonomy and Strength

Each Key Line argument must be backed by concrete evidence. There are four
valid evidence types:

| Type | What it is | Example | What fails |
|------|-----------|---------|------------|
| **Stat** | A specific number from a named source | "A 2023 Bain study found 70% of M&A deals destroy value within 3 years" | "Studies show…" |
| **Named example** | A specific company, product, or case | "Costco caps gross margin on any item at 15%" | Anonymous references |
| **Named person's position** | A specific quote or stated view from a real person | "Paul Graham argues startups should launch before they feel ready" | "Experts believe…" |
| **Concrete anecdote** | A specific story with who, when, what happened | "At Acme, the checkout race condition double-charged 12 users in staging" | "I've seen this work many times" |

### Evidence Strength Classification

Classify each argument's evidence as:

- **STRONG** — concrete, named, specific. State directly.
- **WEAK/MISSING** — asserted, vague, hypothetical. Flag the gap explicitly;
  tell the user exactly what kind of evidence would close it.

In an interview, weak evidence is detectable. "I improved performance
significantly" is weak. "I reduced p99 latency from 800ms to 200ms by adding
a read-through cache" is strong. The [Metrics and Quantification](metrics-and-quantification.md)
concept covers the X-Y-Z formula for resume bullets; the evidence taxonomy
here extends that principle to all pyramid-structured communication.

### One Strong Piece Per Branch

Do not pile evidence. One strong piece per branch is more persuasive than
three weak ones. If an argument seems to need five pieces of evidence, the
argument is probably too broad — narrow it.

### Numbers Over Adjectives

A claim with a number is testable. A claim with "significant" is rhetoric.
"Reduced latency by 75%" is a claim someone can verify or challenge.
"Improved performance significantly" is a claim that means nothing until
quantified. This applies to interview answers, resume bullets, and
presentation slides alike. See [Metrics and Quantification](metrics-and-quantification.md).

### Evidence + Implication + Risk Triple

Each Key Line point should carry three things: the **evidence** that supports
it, the **implication** of that evidence, and the **risk** if it is wrong or
ignored. Most pyramids stop at evidence. Adding the implication and risk
makes the argument decision-ready rather than merely informative.

## Building the Pyramid

### Ask Before Drafting

Before drafting, ask up to three questions — and answer them explicitly:

1. **What exact decision must this communication drive?** (If none, it may not
   need a pyramid — see the Gate.)
2. **Who is the final decision owner, and what is their risk tolerance?** (This
   determines the depth of evidence and the tone.)
3. **Which evidence is confirmed vs still assumed?** (This determines the
   confidence contract — see Epistemic Discipline.)

If answers are incomplete, proceed with explicit assumptions. Tag each
assumption with confidence: high, medium, low. Avoid fabricated data; request
verification when confidence is low.

### Top-Down Mode

Use when the central answer is already reasonably known — you know the
conclusion and need to structure the support.

```
Question → Provisional Answer → Key Lines → Supporting Arguments → Evidence
```

Treat the initial answer as a hypothesis until the support has been tested. Do
not preserve a preferred conclusion the evidence does not support.

### Bottom-Up Mode

Use when the answer must be discovered from notes, experience, or unstructured
thinking — common in interview prep when mining your career for stories.

```
Raw Ideas → Logical Groups → Group Summaries → Higher-Order Groups → Governing Thought
```

At every level ask: *What single statement accurately summarizes these points
without losing their decision-relevant meaning?* Repeat until one central
conclusion remains.

### Multiple Pyramid Configuration

When a single pyramid cannot hold all the material without exceeding 4 levels
or 4 children per node, switch to **multiple linked pyramids**. Each key node
becomes the apex of its own pyramid, and the pyramids are connected by
**bridge questions** — a short question at the end of one pyramid whose answer
is the apex of the next.

```
Introduction (SCQA) → Pyramid 1 → bridge question → Pyramid 2 → bridge question → Pyramid 3
```

Rules for multiple pyramids:
- The SCQA introduction appears **once**, at the top of the whole document
- Each sub-pyramid does **not** get its own SCQA — it starts directly with its apex claim
- Bridge questions are short (one sentence) and appear in the body, not in the introduction
- If a bridge question needs a long introduction, the overall introduction is insufficient or the key nodes are loosely related — restructure

### Structural Constraints

- **Maximum 4 levels deep.** If 5+ levels are needed, regroup: subgroup, split into sections, or switch to multiple pyramids.
- **Maximum 4 children per node.** If 5+ children appear, the grouping is wrong — split into subgroups or merge.
- **Uniform depth and width.** Keep branches as balanced as possible. A lopsided pyramid signals incomplete thinking on the thin branches.
- **Don't use body-defined terms in the introduction.** If a concept is defined in the body, the introduction must use plain language the reader already understands.

### Don't Force a Pyramid Onto Bad Reasoning

If the underlying argument doesn't hold — you can find no MECE grouping of
reasons, or the evidence doesn't support the conclusion — say so. Don't force
a pyramid onto bad reasoning. Flag the gap instead. An honest "the evidence
doesn't yet support a conclusion" is better than a fabricated pyramid that
collapses under scrutiny. In an interview, this maps to the "I don't know
but here's how I'd approach it" answer — see [Technical Interview Preparation](technical-interview-preparation.md).

### Restructure, Don't Summarise

When applying the pyramid to an existing draft, preserve every fact.
Restructure, don't summarise. The job is to make the **same content** readable
top-down — not to cut material to fit the shape. Cutting is a separate
operation (the So-What pass) that comes after the structure is sound.

### The 7-Step Build Process

1. **Identify the core question** — What question must this communication
   resolve? "Should we do X?" "Why is X happening?" "Which option should we
   choose?"
2. **Establish the Governing Thought** — The one-sentence answer. A topic is
   not a conclusion. "Mobile performance analysis" is a topic; "Mobile
   conversion is the primary growth constraint" is a conclusion.
3. **Build the Key Line** — The smallest useful set of major supporting
   statements (usually 2–4). Test: *If these are true, does the Governing
   Thought reasonably follow?*
4. **Support each Key Line** — Place reasoning and evidence beneath the claim
   it supports. Do not place evidence beside recommendations as if they were
   the same logical type.
5. **Separate findings, conclusions, and recommendations** — These are three
   different logical types and must not sit at the same level. A finding is
   what the evidence shows; a conclusion is what it means; a recommendation
   is what should be done. A "Key Findings" list that contains a recommendation
  is structurally broken.
6. **Apply the So-What test** — For observations and facts, repeatedly ask
   *So what?* until you reach a decision-relevant implication. Do not stop at
   a data point when a meaningful conclusion can be derived.
7. **Apply the Why test** — For every higher-level claim, ask *Why is this
   true?* The statements beneath it should answer that question.

## Problem Definition (Before Analysis)

Before analyzing a problem, define it. The **Problem Definition Framework**
has six elements:

| Element | What it captures |
|---------|-----------------|
| **Starting point** | The current state before anything went wrong |
| **Disturbing event** | What changed to create the problem |
| **R1 (undesired result)** | The current bad outcome |
| **R2 (desired result)** | The outcome you want instead |
| **Attempted action** | What has been tried so far (if anything) |
| **Question** | What the analysis must answer to get from R1 to R2 |

Defining the problem before analyzing it prevents the common failure of
collecting data before knowing what question the data must answer. In an
interview case study, this maps to the "clarify" step of the 4-step case
framework (see [Case Interviews](case-interview.md)).

## Diagnostic Frameworks and Logic Trees

Once the problem is defined, structure the analysis before collecting data.
Four diagnostic frameworks:

| Framework | When to use |
|-----------|-------------|
| **System** | Represent the problem area as a system with inputs, outputs, and feedback loops |
| **Causal chain** | Trace cause → mechanism → consequence |
| **Classification** | Divide the problem into MECE categories |
| **Business structure** | Map to a known business framework (value chain, profit equation, etc.) |

**Logic trees** generate solutions, test coverage, and reveal weak groupings.
A logic tree starts with the problem at the top and branches into possible
causes or solutions at each level, tested for MECE at every split.

### Issue Analysis: Yes-or-No Questions

A real issue is usually a **yes-or-no question**, not a topic prompt.

| Good (crisp issues) | Weak (topic prompts) |
|---------------------|---------------------|
| "Is the present inventory level too high?" | "What are the key issues?" |
| "Is the centralized system placing orders properly?" | "How should we reorganize?" |
| "Should we reorganize functionally?" | "What should we prioritize?" |

A section called "Issues" often signals fuzzy thinking. Usually what you
really need is one of: a problem definition, a diagnostic framework, a
solution logic tree, or a decision recommendation. In a case interview,
framing issues as yes-or-no questions demonstrates structured thinking — see
[Case Interviews](case-interview.md).

### Seven Common Reader Positions

The reader is usually in one of seven positions. The document structure
should change to fit which is true:

| # | Reader position | Document answers |
|---|----------------|-----------------|
| 1 | "I don't know how to get from R1 to R2" | What should we do? |
| 2 | "I think I know how, but I'm not sure I'm right" | Is this the right solution? |
| 3 | "I know the solution, but not the implementation path" | How do we implement it? |
| 4 | "I tried a solution and it failed" | What now? |
| 5 | "I have alternatives and need to choose" | Which is best? |
| 6 | "I know something is wrong but can't define the target" | What should the objective be? |
| 7 | "I know the target but I'm not sure there's really a problem" | Do we need to act? |

In an interview, the interviewer's question tells you which position they're
in. A "tell me about a time" question is position 1 or 3. A "how would you
handle X" question is position 1 or 5. Matching your answer's structure to
the reader's position is the same as matching abstraction level to seniority
— see [Strategic Abstraction](strategic-abstraction.md).

### Common Question Shapes

Use these question patterns to identify the reader's position quickly:

- We have a problem. What should we do?
- We think we have a solution. Is it the right one?
- We know the solution. How do we implement it?
- We tried a solution. It did not work. What now?
- We have several alternatives. Which is best?
- We know we need change but not the target. What should the objective be?
- We know the target but are not sure there is really a problem. Do we need to act?

## Validation

### The Mandatory Four Checks

Run these before delivering any pyramid-structured communication:

1. **Governing Thought** — Does the top statement directly answer the core
   question, and is it a conclusion rather than a topic?
2. **Parent / Why** — Can every parent genuinely be derived from its children?
   Do the children answer *why* the parent is true?
3. **Sibling / Abstraction** — Do siblings answer the same question, perform
   the same logical function, and sit at the same conceptual level?
4. **So-What** — Do lower-level observations lead to meaningful higher-level
   implications?

### Standard Checks (5–8)

5. **Order** — Does each group follow a clear ordering principle?
6. **MECE** — Are there material overlaps or important gaps?
7. **Evidence and necessity** — Are material claims supported by actual
   evidence? Would removing any point materially weaken the argument? If not,
   remove it.
8. **Contradiction** — Does any supporting point undermine another part of
   the pyramid? Resolve it rather than hiding it.

### The Fast Review Checklist

1. What question is the reader expecting this text to answer?
2. Is the answer stated before the supporting detail?
3. Do the Key Line points answer the question raised by the answer?
4. Are grouped ideas the same kind of idea?
5. Is each group ordered by time, structure, or degree?
6. Is the set MECE enough for the purpose?
7. Does the introduction use Situation, Complication, Question, Answer?
8. Do headings and slides make the pyramid visible?

### Scoring Rubric

Five axes, 0–2 each, maximum 10:

| Axis | 0 | 1 | 2 |
|------|---|---|---|
| **Top** | No answer | Answer is vague | Precise and actionable |
| **Same-kind groups** | Full mix | Partly mixed | One kind per group |
| **Order** | Unexplainable | Formally present | Explicable and useful to the reader |
| **MECE** | Clear gaps and overlaps | Some doubtful spots | Overlaps and gaps minimal |
| **Display** | Solid prose | Partly visible | Hierarchy readable in seconds |

Bands: 0–3 not structured yet · 4–6 baseline workable · 7–8 good working level
· 9–10 executive level.

## The Failure Catalogue

| Failure | What it looks like | Fix |
|---------|-------------------|-----|
| Top does not answer | "A memo about project X" instead of "we recommend X because…" | Turn the topic into a question, then answer it |
| Mixed kinds | One group holds reasons, steps, numbers, and risks | Split into same-kind classes |
| No order | Arguments sit in recall order | Assign time / structure / ranking / deduction / induction |
| Non-MECE split | Categories overlap or leave a hole | Reformulate branches, check the boundary |
| False deduction | Sounds like logic, but the middle premise is never proven | Recast as induction or comparison |
| Hidden structure | A good idea drowned in paragraphs | Headings, key line, numbering, slides |
| Missing intermediate conclusion | A fact jumps straight to a recommendation | Insert the conclusion the fact actually supports |
| Duplicate branches in disguise | Two elements say the same thing presented as different lines | Cover one branch: if the rest still answer, merge it |
| Right kind, wrong kind | Group is internally uniform but answers a different question than the reader's | Re-derive the kind from the question, then refill |

## Epistemic Discipline

Never make the pyramid appear stronger than its evidence. Distinguish:

| Type | Meaning | Drafting action |
|------|---------|-----------------|
| **Fact** | Directly supported by evidence | State directly without strengthening |
| **Inference** | Reasonably derived from evidence | State with source attribution or explicit limitation |
| **Assumption** | Required for the argument but not established | Label as assumption |
| **Recommendation** | A judgment about what should be done | Frame as recommendation, not fact |
| **Hypothesis** | A provisional explanation requiring testing | Label as provisional |

Do not convert assumptions or hypotheses into facts for the sake of a cleaner
structure. In an interview, if you do not know something, say so — an
incomplete pyramid is honest; a fabricated one is detectable and
disqualifying.

### The Confidence Contract

When evidence quality varies, calibrate the drafting action to confidence:

| Confidence | Required drafting action |
|------------|------------------------|
| **High** | State directly without strengthening the source |
| **Medium** | State with source attribution or an explicit limitation |
| **Low** | Keep out of central support; use only as a limitation or verification lead |
| **Unverified** | Exclude from the artifact as fact |

A derived value cannot exceed the confidence of its weakest required input.

### Never Fabricate to Fill a Structure

No invented facts, categories, evidence, proof points, quotes, testimonials,
reviews, ratings, figures, or scarcity. If something is not supported, label
it as an assumption or leave it out. An incomplete pyramid is acceptable; a
fabricated one is not.

## Invent Nothing

Every number, name, quote, and claim must already exist in the source.
Sharpening the language is the job; upgrading "pretty dated" into "a decade
behind" is not. This applies to interview answers too — do not inflate a 10%
improvement into "significant" or a supporting role into "led."

## Depth Levels and the Stop-Anywhere Property

A strong pyramid lets readers stop at different levels and still receive a
coherent argument:

| Depth | Contains | The reader can stop at |
|-------|----------|----------------------|
| **Compact** | Governing Thought + Key Lines | The main message and its reasons |
| **Standard** | + supporting reasoning | The argument in full |
| **Deep** | + framing, evidence, assumptions, implications, recommendations | Any level of detail |

An executive reads the Governing Thought and Key Lines; a specialist inspects
the evidence. The structure must remain coherent if only the top two levels
are read. This is why the [Conciseness and Length](conciseness-and-length.md)
principle works — a well-structured communication is complete at every depth.

### Compression

When there is far more material than the artifact needs, compress first, then
render. Do not let the volume of input set the length of the output. In an
interview, this means selecting the 2–3 strongest points, not narrating
everything that happened.

## Tiered Renderers: How Much the Pyramid Controls the Output

The pyramid does not control every format equally. Know which tier you are in:

| Tier | Formats | What the pyramid controls |
|------|---------|--------------------------|
| **Tier A** | Memos, emails, reports, proposals, executive summaries | Reasoning AND visible communication structure |
| **Tier B** | Blog posts, presentations, slides | Information architecture and structure |
| **Tier C** | Ads, landing pages, product pages | Message architecture only; persuasion controls visible expression |

### The Tier C Override

In Tier C, the pyramid decides **what must be communicated and supported** —
it does not dictate the visible sequence. The artifact may open with curiosity,
tension, a problem, a narrative hook, or a channel-native convention when that
is more effective than answer-first communication.

```
Governing Thought → Audience translation → Visible headline or hook
```

Translate the Governing Thought into the strongest customer-facing value
proposition rather than stating it analytically. Do not sacrifice persuasive
performance to make the visible copy look like a pyramid — and do not let the
creative freedom weaken the evidence standard behind it.

## Visual Reflection: Making the Pyramid Visible

The pyramid must be visible in the final artifact. Headings, transitions,
numbering, indentation, storyboards, and slide titles must reveal the same
logic as the pyramid.

- **Headings** are conclusions, not topic labels. "Q3 Performance" is a topic;
  "Revenue grew 40% driven by enterprise expansion" is a conclusion.
- **Numbering** mirrors the hierarchy — 1, 1.1, 1.1.1.
- **Transitions** carry the reader from one Key Line point to the next.
- **Slide titles** (the "ghost deck" technique) tell the story when read alone.

A reader who reads only the headings or slide titles should receive a coherent
argument. This is the [Presentation and Demo Interviews](presentation-demo-interview.md)
principle applied at the structural level.

## Direct Writing Contract

Every sentence in a pyramid-structured communication should:

- **State the answer before support** and give each sentence one main claim
- **Name a specific actor, use an active verb, and state a specific outcome**
  (not "improvements were made" but "I reduced latency by 75%")
- **Replace vague adjectives and adverbs with validated measures** when
  available; never invent data to sound precise
- **Carry key terms from each parent claim into its supporting statements** so
  the relationship remains visible
- **Connect sentences from given information to new information** — start with
  what the reader already knows, then introduce the new point
- **Make peer bullets grammatically and logically parallel** — same structure,
  same tense, same level of abstraction

## Named Operations

Five operations for working with existing drafts:

| # | Operation | Use when |
|---|-----------|---------|
| 1 | **Restructure** — impose the pyramid shape on an existing draft | You have prose and need the pyramid |
| 2 | **Buried-lede test** — find the conclusion the draft is building toward | You aren't sure what your own point is |
| 3 | **Reason audit** — test the middle layer against Minto's rules | Reasons feel repetitive, thin, or arbitrary |
| 4 | **So-what pass** — cut sentences that support nothing | The draft is bloated |
| 5 | **Email version** — compress to the same shape | The deliverable is an email or short update |

### The Buried-Lede Test

Read the draft and identify the one conclusion it is actually building toward.
If you had a single sentence to give your boss, what would it be? Then show
where it is hidden, and how many words a reader gets through before reaching
it. If the draft doesn't support one conclusion — if it's inconclusive, or
answers several questions at once — say that instead of picking one.

### The Subject Test for Openers

If a reader saw only the first one or two sentences of your proposed opener,
would they correctly name what the piece is about? If the reader's guess does
not match the actual subject, the opener is wrong. Rewrite.

**Principle piece vs case study piece.** In a principle piece (the subject is
a claim, examples illustrate it), the opener should state the answer — leading
with a concrete example causes "subject-swap" (the reader thinks the example
is the subject). In a case study piece (the subject is a specific case, the
principle is the takeaway), the opener can lead with the concrete because the
concrete IS the subject.

## Risks, Next Steps, and the Closing Section

Risks, constraints, dependencies, and next steps usually aren't reasons — they
must not be deleted as though they were. Give them a slot at the close. A risk
severe enough to change the decision is not a footnote: put it in or beside
the answer.

### The Closing Contract

A decision-ready communication ends with a closing contract — four things the
reader needs to act:

| Element | What it captures |
|---------|-----------------|
| **Decision** | What was decided or recommended |
| **Owner** | Who is responsible for executing it |
| **Date** | When it must be done or reviewed |
| **Next action** | The single immediate step that unblocks execution |

Without these four, the reader has been informed but not enabled. In an
interview, the "next action" is often implicit — "and that's why I'd approach
it the same way today" — but in written communication (follow-up emails,
recruiter outreach, salary negotiation), the closing contract makes the
message actionable.

### One Governing Question — Reject Multi-Question Drift

A single communication answers a single governing question. If the draft
starts answering a second question, either split it into a second
communication or restructure. Do not mix recommendation with exploratory
brainstorming in the same top level. Multi-question drift is the structural
equivalent of mixing logical types — it produces a document that answers
nothing well.

## Action Ideas Must State End Products

Action ideas must be worded so you can visualize the result. "Improve
reporting" is too vague to test. "Install a system that gives early notice of
change" is testable — you can picture what will exist when the step is
complete.

Ask of every action:
- What will exist when this step is complete?
- What will someone literally have in hand?
- How will we know the action is done?

Distinguish levels of action: a **result** and a **substep required to create
the result** must sit at different levels of the pyramid. Do not mix them in
the same sibling group.

### News Is Not Thinking

A list of facts is not yet reasoning. Facts belong in the document only if,
together, they explain or defend a higher point. A "Key Findings" section
that lists observations without synthesizing them into conclusions is news,
not thinking. Every fact must earn its place by supporting a claim one level
up.

## Hedging Dissolves the Claim

"We may want to consider" is not a conclusion — it dissolves the claim into a
maybe. State the claim at the strength the evidence supports — "likely," "on
current data," "I recommend" — rather than hedging until nothing is being
asserted. In an interview, hedging signals lack of confidence. The
[Governing Thought] must take a position.

## Red Flags in a Draft

- The point arrives in paragraph three or later
- The opening restates the request, apologizes for the delay, or warms up
- It narrates the investigation instead of reporting the finding
- Nothing changes for the reader if they stop after the first paragraph —
  because the first paragraph says nothing

## Applications in the Hiring Pipeline

### Interview Answers

Every behavioral interview answer (STAR/PAR/CAR) is a micro-pyramid. The
**Result** is the Governing Thought — state it first or early. The **Action**
is the Key Line. The **Situation** and **Task** are the SCQA introduction.

The [Behavioral Interview Framework](behavioral-interview-framework.md) covers
the STAR method in detail; the Pyramid Principle explains *why* leading with
the result works: it gives the interviewer the answer before the support,
reducing cognitive load and signaling executive communication.

### Presentations and Demo Interviews

In [Presentation and Demo Interviews](presentation-demo-interview.md), the
narrative arc should follow pyramid logic. The first slide or opening
statement should state the main takeaway. Each section should have a headline
that is a conclusion, not a topic label. Slide headlines should make the
pyramid visible — a reader who reads only the headlines should receive a
coherent argument (the "ghost deck" technique).

### Case Interviews

In [Case Interviews](case-interview.md), the 4-step framework (clarify,
structure, analyze, conclude) maps directly to the pyramid: the Problem
Definition Framework is the "clarify" step, diagnostic frameworks and logic
trees are the "structure" step, and the conclusion is the Governing Thought.
MECE is already central to case interview methodology.

### Written Communication

Cover letters, follow-up emails, and recruiter outreach all benefit from
answer-first structure. The [Recruiter Outreach](recruiter-outreach.md)
message structure is implicitly pyramidal: lead with the value proposition
(the answer), then the supporting evidence (background, fit), then the call
to action.

### Salary Negotiation

In [Salary Negotiation](salary-negotiation.md), framing your request as a
pyramid — conclusion first ("I'm targeting $X based on three factors"), then
the Key Line (market data, experience premium, scope of role), then the
evidence — is more persuasive than building up to the number. The interviewer
hears the number in context rather than wondering where the conversation is
going.

## Common Mistakes

### Topic Instead of Conclusion

The most common mistake: the top of the pyramid is a topic label, not a
conclusion. "Project Overview" is a topic. "The project reduced checkout
abandonment by 35%" is a conclusion. Test: can someone disagree with this
statement? If not, it is a topic, not a conclusion.

### Mixed Logical Types

Placing findings, conclusions, and recommendations at the same level. A
"Key Findings" list that contains a recommendation is structurally broken —
findings and recommendations are different logical types and must sit at
different levels of the pyramid.

### Inverted Time Allocation

Spending 60% of the time on context (Situation) and 10% on the answer
(Governing Thought). The interviewer wants the answer; the context is just
framing. This is the same failure mode as the [Behavioral Interview
Framework](behavioral-interview-framework.md) describes — spending most of a
STAR answer on the Situation and rushing the Action and Result.

### Building the Argument While Speaking

Discovering the argument while talking produces a rambling, unstructured
answer. The pyramid must be constructed before delivery — even if it takes
only a few seconds of pause to identify the core question and the Governing
Thought before speaking.

### Padding for MECE

Adding weak points to make a group look complete. Three strong reasons are
better than three strong reasons plus two weak ones. MECE is a quality test,
not a quota — do not manufacture categories to fill out a framework.

### Restructuring Unasked

If someone shares their draft for review, do not restructure it unasked. Name
the specific symptom in one sentence ("your recommendation lands in paragraph
six"), offer the restructure in one question, and wait. The writer knows what
you don't — who the reader is, what's political, what was already settled.

## Relationship to Other Concepts

- **[Behavioral Interview Framework](behavioral-interview-framework.md)** —
  STAR/PAR/CAR are micro-pyramids. The Pyramid Principle explains why
  leading with the result is more effective than chronological narration.
- **[Case Interviews](case-interview.md)** — The 4-step case framework maps
  to the pyramid: clarify = problem definition, structure = diagnostic
  frameworks, analyze = evidence, conclude = governing thought. MECE is
  central to both.
- **[Presentation and Demo Interviews](presentation-demo-interview.md)** —
  Pyramid logic governs the narrative arc and slide headline structure. The
  "ghost deck" technique is pyramid reflection on screen.
- **[Strategic Abstraction](strategic-abstraction.md)** — The Pyramid
  Principle's abstraction-level rule (siblings at the same level of
  abstraction) is the communication analog of matching bullet altitude to
  target seniority.
- **[Bullet Autonomy Principle](bullet-autonomy-principle.md)** — Each
  resume bullet is a one-line pyramid: action (governing thought) → outcome
  (key line) → context (support). Bullets that depend on other bullets for
  meaning violate the parent-summarizes-children rule.
- **[Metrics and Quantification](metrics-and-quantification.md)** — The
  evidence taxonomy (stat, named example, named person, concrete anecdote)
  extends the X-Y-Z formula from resume bullets to all pyramid-structured
  communication.
- **[Safe Pair of Hands Positioning](safe-pair-of-hands-positioning.md)** —
  Answer-first communication signals the organized, confident judgment that
  managers hire for safety.
- **[Recruiter Outreach](recruiter-outreach.md)** — The outreach message
  structure is implicitly pyramidal: value proposition first, then support.
- **[Conciseness and Length](conciseness-and-length.md)** — The pyramid's
  "stop at any level" property enables conciseness: an executive reads the
  Governing Thought and Key Line; a specialist reads the evidence. The
  structure remains coherent at every depth.
- **[Fluff and Buzzword Elimination](fluff-and-buzzword-elimination.md)** —
  The "invent nothing" rule and the evidence strength classification are the
  structural analogs of replacing buzzwords with evidence.
