---
name: think-assist
description: >-
  Thinking-method library and light multi-advisor council for pressure-testing
  decisions, ideas, and proposals. Use when you need to apply a specific
  thinking method (first principles, inversion, devil's advocate, second-order
  thinking, systems thinking, SCAMPER, five-whys, circle of competence,
  expansionist, outsider, executor) to a problem, OR when you want a fast
  multi-perspective "council this" / "pressure-test this" / "stress-test this"
  / "war room this" / "debate this" run that spawns 5 advisors with different
  thinking styles, runs a blind peer-review round, and synthesizes a verdict
  with "one thing to do first." Also use when consolidating outcomes from
  multiple thinking models, choosing which thinking model fits a problem, or
  refining unsatisfactory AI output ("meh" / "let's refine"). Do NOT trigger on
  factual lookups with one right answer, pure creation tasks, or summaries.
version: "1.0.0"
date:
  created: "2026-07-05"
  updated: "2026-07-05"
  last-used: "2026-07-05"
tags:
  - ai/skill
  - thinking
  - mental-models
  - council
  - decision-making
  - pressure-test
  - multi-perspective
  - first-principles
  - inversion
  - devils-advocate
see-also:
  - skill: peer-review
    relationship: dependency
    description: Blind review round used by the council orchestration
  - skill: briefingmemo
    relationship: complement
    description: Heavy council for high-stakes strategic decisions with research and governance
  - template: base-ai-guidance
    relationship: base-framework
    description: Shared framework for creating all AI guidance types
triggers:
  - user
---

{{{ include "includes/base-ai-guidance.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# Think-Assist — Thinking-Method Library + Light Council

Two modes: **single-method** (apply one thinking style to a problem) and
**council** (spawn 5 advisors with different styles, blind peer-review, chairman
synthesis). The library is the same for both — the council just uses 5 methods
at once.

## Mode 1: Single Thinking Method

Pick a method from the library, apply it to the problem.

### Method Library

| Method | When to use | Reference |
|---|---|---|
| First Principles | Seemingly impossible problems, challenging dogma | [first-principles-thinking.md](references/first-principles-thinking.md) |
| Inversion | Risk management, stress-testing plans | [inversion.md](references/inversion.md) |
| Devil's Advocate | Rigorous scrutiny, challenging consensus | [devils-advocate.md](references/devils-advocate.md) |
| Second-Order Thinking | Long-term consequences, "and then what?" | [second-order-thinking.md](references/second-order-thinking.md) |
| Systems Thinking | Interconnected impacts, feedback loops | [systems-thinking.md](references/systems-thinking.md) |
| Five Whys | Root cause analysis | [five-whys.md](references/five-whys.md) |
| SCAMPER | Creative innovation on existing things | [scamper.md](references/scamper.md) |
| Circle of Competence | Should you tackle this or delegate? | [circle-of-competence.md](references/circle-of-competence.md) |
| Expansionist | Upside-hunting, adjacent opportunities | [expansionist.md](references/expansionist.md) |
| Outsider | Fresh eyes, curse-of-knowledge check | [outsider.md](references/outsider.md) |
| Executor | "What do you do Monday morning?" | [executor.md](references/executor.md) |
| Research | Structured research before deciding | [research.md](references/research.md) |
| Advisory | Multi-expert advisory panel | [advisory.md](references/advisory.md) |
| Confident | Force confidence levels + sourcing | [confident.md](references/confident.md) |
| Meh | Quick refinement of unsatisfactory output | [meh.md](references/meh.md) |

### Choosing a Method

For guidance on selecting the right method for a problem, see
[choose-thinking-models.md](references/choose-thinking-models.md). For
synthesizing insights after applying multiple methods, see
[consolidate-model-outcomes.md](references/consolidate-model-outcomes.md).

### Steps (Single Method)

1. **Identify the problem type.** Match it to a method using the table above
   or the chooser reference.
2. **Read the method reference.** Open the matching `references/*.md` file and
   follow its operation steps.
3. **Apply the method.** Produce the output specified by the method's output
   template.
4. **Consolidate (if using multiple methods).** After applying 2+ methods,
   use [consolidate-model-outcomes.md](references/consolidate-model-outcomes.md)
   to synthesize: common themes, contradictions, prioritized actions.

## Mode 2: Light Council (5 Advisors + Blind Review)

For decisions where being wrong is expensive and a single perspective isn't
enough. This is the lightweight alternative to `execution/briefingmemo` — no
research team, no board governance, no 16-member committee. Five advisors,
blind peer review, chairman verdict, one concrete next step.

### When to Use the Council

| Situation | Use council? |
|---|---|
| "Should I do X or Y?" with real stakes | Yes |
| "Pressure-test this decision" | Yes |
| "What am I missing?" on a plan | Yes |
| "Is this the right move?" | Yes |
| Factual question with one right answer | No |
| Pure creation task ("write a tweet") | No |
| Summary or processing task | No |
| Validation-seeking when you already know the answer | No — the council tells you things you don't want to hear |
| High-stakes strategic decision needing research + governance | No — use `execution/briefingmemo` instead |

### The Five Advisors

The council uses 5 thinking styles that create natural tension with each other:

| Advisor | Thinking style | Tension with |
|---|---|---|
| **Contrarian** | Hunts for what will fail | Expansionist (downside vs upside) |
| **First Principles Thinker** | Asks if you're solving the right problem | Executor (rethink vs just do it) |
| **Expansionist** | Hunts for upside everyone's missing | Contrarian |
| **Outsider** | Zero context, fresh eyes | All (catches curse of knowledge) |
| **Executor** | "What do you do Monday morning?" | First Principles |

Each advisor's method is in `references/`:
[devils-advocate.md](references/devils-advocate.md),
[first-principles-thinking.md](references/first-principles-thinking.md),
[expansionist.md](references/expansionist.md),
[outsider.md](references/outsider.md),
[executor.md](references/executor.md).

### Council Steps

1. **Enrich context + frame the question.** Scan the workspace for relevant
   context (CLAUDE.md, memory/, referenced files, past transcripts). Reframe
   the raw question into a neutral prompt with stakes + context. See
   [context-enrichment.md](references/context-enrichment.md) for the scan
   pattern and framing rules. Save the framed question for the transcript.

2. [fork] **Spawn 5 advisors in parallel.** Dispatch all 5 simultaneously as
   sub-agents. Each gets: its advisor identity, the framed question, and an
   instruction to lean fully into its assigned perspective — no hedging, no
   balance, no "consider both sides." 150-300 words each. Go straight into
   analysis.

   Advisor prompt template:
   ```
   You are [Advisor Name] on a council.
   Your thinking style: [from the advisor's reference file]
   The question:
   ---
   [framed question]
   ---
   Respond from your perspective. Be direct and specific. Don't hedge.
   Lean fully into your assigned angle. 150-300 words. No preamble.
   ```

3. [fork] **Blind peer review.** Use the `peer-review` skill to anonymize the 5
   responses, spawn 5 reviewers (one per response), and collect reviews
   answering the three fixed questions (strongest / biggest blind spot / what
   all missed). See
   [../peer-review/references/review-protocol.md](../../peer-review/references/review-protocol.md)
   for the protocol and reviewer prompt template.

4. **Chairman synthesis.** One agent gets everything: the framed question, all
   5 advisor responses (de-anonymized), and all 5 peer reviews. Produce the
   verdict using the 5-part template in
   [chairman-verdict-template.md](references/chairman-verdict-template.md):
   - Where the council agrees
   - Where the council clashes
   - Blind spots the council caught
   - The recommendation
   - **The one thing to do first** (a single concrete next step, not a list)

5. **Generate the HTML report.** Run `scripts/generate_report.py` with the
   markdown transcript to produce a self-contained HTML report with the
   verdict prominently displayed and collapsible advisor sections.

6. **Save the transcript.** Write `council-transcript-[timestamp].md`
   containing: the original question, the framed question, all 5 advisor
   responses, all 5 peer reviews (with anonymization mapping revealed), and
   the chairman's full synthesis. This is the provenance artifact for later
   re-runs.

### Output

The council produces two files:

```
council-report-[timestamp].html      # visual report for scanning
council-transcript-[timestamp].md    # full transcript for reference
```

## Important Notes

- **Always spawn all 5 advisors in parallel.** Sequential spawning wastes time
  and lets earlier responses bleed into later ones.
- **Always anonymize for peer review.** If reviewers know which advisor said
  what, they defer to certain thinking styles instead of evaluating on merit.
  Use the `peer-review` skill's `scripts/anonymize.py`.
- **The chairman's "one thing to do first" is one thing, not a list.** This is
  the anti-pattern-corrective against the LLM habit of returning 10-item lists.
- **For high-stakes strategic decisions needing research and governance**, use
  `execution/briefingmemo` instead. Think-assist is the fast pressure-test,
  not the heavy deliberation.

## References

- [context-enrichment.md](references/context-enrichment.md) — workspace scan
  and question framing pre-step
- [chairman-verdict-template.md](references/chairman-verdict-template.md) — the
  5-part output structure with "one thing to do first"
- [choose-thinking-models.md](references/choose-thinking-models.md) — guide for
  selecting the right thinking method for a problem
- [consolidate-model-outcomes.md](references/consolidate-model-outcomes.md) —
  synthesizing insights from multiple thinking methods
- Individual method references: see the Method Library table above

## Context Declaration

- **Bundled scripts**: `scripts/generate_report.py` (HTML report from
  transcript)
- **Dependencies**: `general/peer-review` (blind review round + anonymize.py)
- **Consumed by**: `execution/briefingmemo` (references the thinking-method
  library via `see-also`)
- **External dependencies**: None beyond Python 3 stdlib
