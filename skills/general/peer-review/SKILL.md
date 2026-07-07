---
name: peer-review
description: >-
  Run an anonymous (blind) peer-review round over a set of responses, designs,
  documents, code diffs, or proposals so reviewers evaluate on merit instead of
  authority. Use when you have multiple independent outputs on the same question
  and want to surface the strongest, the biggest blind spot, and what every
  reviewer missed — without named-author bias. Triggers on requests like
  'peer-review these', 'review blind', 'anonymize and review', 'which response
  is strongest', 'pressure-test these options', 'compare these proposals
  without bias', 'blind review this', or whenever a council / multi-advisor /
  multi-model process needs an unbiased evaluation round. Also use for code
  review (multiple blind reviewers on a diff), design review, document/policy
  review, and any multi-perspective evaluation where deferring to a named
  authority would distort the verdict. Do NOT trigger on single responses with
  nothing to compare against, factual questions with one right answer, pure
  creation tasks, or summary/processing tasks.
version: "1.0.0"
date:
  created: "2026-07-05"
  updated: "2026-07-05"
  last-used: "2026-07-05"
tags:
  - ai/skill
  - peer-review
  - blind-review
  - anonymization
  - evaluation
  - decision-making
  - multi-perspective
see-also:
  - skill: think-assist
    relationship: consumer
    description: Light council that uses peer-review for its blind review round
  - skill: briefingmemo
    relationship: optional-consumer
    description: Heavy council that may adopt peer-review before the CSO memo
  - template: base-ai-guidance
    relationship: base-framework
    description: Shared framework for creating all AI guidance types
triggers:
  - user
---

{{{ include "includes/base-ai-guidance.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# Anonymous Peer Review

A reusable blind-review technique. Take N independent responses to the same
question, anonymize them so reviewers can't tell who produced which, ask each
reviewer three fixed questions, then hand the de-anonymized bundle to a
synthesizer. The anonymization is the core innovation — it strips out authority
bias, persona deference, and positional anchoring so the verdict rests on the
content, not the source.

## When to Use

| Situation | Use this skill? |
|---|---|
| Multiple advisors/models answered the same question | Yes — this is the canonical case |
| Multiple blind reviewers needed on a code diff | Yes — see `references/code-review-pattern.md` |
| Multiple proposals/designs to compare without author bias | Yes — see `references/design-review-pattern.md` |
| Multiple policy/doc drafts to evaluate | Yes — see `references/document-review-pattern.md` |
| Single response to review | No — nothing to anonymize or compare |
| Factual question with one right answer | No — review won't add perspective |
| Pure creation task (write a tweet) | No — review is for evaluation, not generation |

## Steps

1. **Collect responses.** Gather the N independent outputs to review. Each must
   answer the same question or address the same artifact. If responses reference
   their own author by name, strip those references before proceeding.

2. **Anonymize.** Run `scripts/anonymize.py` to shuffle the responses into a
   randomized A–N mapping. The script emits the anonymized bundle (for
   reviewers) and a mapping key (for the synthesizer only). Do not share the
   mapping with reviewers. See `references/review-protocol.md` for the
   anonymization rules and why randomization matters.

3. [fork] **Spawn reviewers.** Dispatch one reviewer per original response (N
   reviewers). Each reviewer sees the full anonymized bundle and answers the
   three fixed questions from `references/review-protocol.md`:
   - Which response is the strongest, and why? (pick one)
   - Which response has the biggest blind spot, and what is it?
   - What did ALL responses miss that the council should consider?

   Use the reviewer prompt template in `references/review-protocol.md`. Keep
   reviews under 200 words. Be direct — no hedging.

4. **De-anonymize for synthesis.** Reveal the A–N mapping to the synthesizer
   only (chairman, facilitator, or whoever produces the final verdict). The
   synthesizer now sees which author produced which response, plus all reviews,
   and can weigh the verdict on merit while tracking which perspective raised
   which point.

5. **Apply a domain pattern (optional).** If running a code review, design
   review, or document review rather than a council decision, follow the
   matching pattern in `references/`:
   - `references/code-review-pattern.md` — blind multi-reviewer on a diff
   - `references/design-review-pattern.md` — blind multi-reviewer on proposals
   - `references/document-review-pattern.md` — blind multi-reviewer on drafts

## Output

The skill produces two artifacts:

- **Anonymized bundle** (`peer-review-anonymized-[timestamp].md`) — the
  shuffled A–N responses given to reviewers. Save it so the review round is
  reproducible.
- **Review transcript** (`peer-review-transcript-[timestamp].md`) — the
  original question, the anonymized bundle, all N reviews, and the de-anonymized
  mapping. This is the artifact the synthesizer consumes and the provenance
  record for later re-runs.

## Important Notes

- **Always randomize the A–N mapping.** If reviewer A always maps to the first
  response, positional bias creeps back in. The script handles this.
- **Never reveal the mapping to reviewers.** Reviewers who know which named
  author produced which response will defer to authority instead of merit.
- **One reviewer per original response.** N responses → N reviewers. Each
  reviewer answers the same three questions so the synthesizer can compare
  reviews across the same axes.
- **Reviews are not votes.** A review naming "Response C as strongest" is a
  signal, not a ballot. The synthesizer weighs reasoning, not counts.

## References

- [review-protocol.md](references/review-protocol.md) — the three-question
  framework, anonymization rules, reviewer prompt template, de-anonymization
  rules
- [code-review-pattern.md](references/code-review-pattern.md) — blind
  multi-reviewer pattern for code diffs
- [design-review-pattern.md](references/design-review-pattern.md) — blind
  multi-reviewer pattern for design proposals
- [document-review-pattern.md](references/document-review-pattern.md) — blind
  multi-reviewer pattern for policy/doc drafts

## Context Declaration

- **Bundled scripts**: `scripts/anonymize.py` (deterministic shuffle + mapping
  emission)
- **Consumed by**: `general/think-assist` (council blind review round),
  `execution/briefingmemo` (optional pre-CSO review round)
- **External dependencies**: None beyond Python 3 stdlib
