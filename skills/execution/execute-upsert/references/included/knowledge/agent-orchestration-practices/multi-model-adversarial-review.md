---
type: Practice
title: Multi-Model Adversarial Review
description: Adversarial signal in code review comes from model diversity, not from assigned personas. Spawn N reviewers with the same rubric across different models, synthesize by consensus tier — agreement across two or more models is high-confidence, a lone-model finding is lower confidence. The lead judgment categorizes findings as Act on, Consider, Noted, or Dismissed, with an Agreement Map showing where models agreed vs diverged.
tags: [agent-orchestration, adversarial-review, multi-model, consensus-tier, code-review, agreement-map, model-diversity]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: open-pstack-interrogate
    resource: "https://github.com/ericlitman/open-pstack"
    title: "open-pstack interrogate skill — multi-model adversarial review with consensus-tier synthesis"
---

# Multi-Model Adversarial Review

## The General Rule

Adversarial review does not come from telling a single model to "be
critical." A model asked to play devil's advocate tends to produce the
same blind spots it would produce in its default mode — the persona is
cosmetic, not structural. Real adversarial signal comes from **model
diversity**: different models have different training data, different
reasoning shortcuts, and different failure modes. When they disagree,
the disagreement is the signal.

### Spawn N Reviewers with the Same Rubric

Give every reviewer the **same rubric** — the same checklist, the same
scoring criteria, the same scope. Do not assign different personas
("you are the security reviewer, you are the performance reviewer").
Persona assignment creates coverage gaps (two models both skip the
unassigned area) and false specialization (a model told to focus on
security still has opinions on architecture, but suppresses them).

The rubric is the shared contract. Each reviewer applies it
independently. The orchestrator collects the outputs and synthesizes.

### Consensus Tiers

Synthesize findings by **consensus tier**, not by averaging scores:

- **High confidence (2+ models agree)** — two or more models
  independently raised the same finding. This is the strongest signal.
  The finding is real even if no single model's reasoning is airtight —
  the convergence is the evidence.
- **Lower confidence (lone model)** — only one model raised the finding.
  This may be a genuine blind spot the other models missed, or it may be
  a hallucination. Treat as worth investigating but not automatically
  actionable.

This degrades gracefully: with N=1 model, every finding is lone-model
(lower confidence). The pattern still works — it just reports everything
as lower confidence. Single-model review remains valid; the multi-model
upgrade is additive.

### Lead Judgment Categorization

The orchestrator (or a designated lead) reads all reviewer outputs and
categorizes each finding:

- **Act on** — must fix before proceeding. High-confidence findings
  with clear remediation.
- **Consider** — worth fixing but not blocking. High-confidence findings
  with tradeoffs, or lone-model findings that are plausible and cheap
  to address.
- **Noted** — acknowledged but no action now. Lone-model findings that
  are speculative, or findings about future work.
- **Dismissed** — rejected with reasoning. Findings that are
  factually wrong, out of scope, or already addressed.

The categorization is the lead's judgment, not a vote. The lead can
override consensus (dismiss a high-confidence finding if it is
factually wrong) or elevate a lone-model finding (act on it if the
lead's own analysis confirms it).

### Agreement Map

The synthesis output includes an **Agreement Map** — a table showing
which models raised which findings, and where they agreed vs diverged:

| Finding | Model A | Model B | Model C | Tier |
|---------|---------|---------|---------|------|
| Missing error check on line 42 | raised | raised | — | High |
| N+1 query in user loader | raised | — | raised | High |
| Inconsistent naming convention | — | raised | — | Lone |
| Suggest extracting helper function | raised | raised | raised | High |

The Agreement Map makes the consensus structure visible. A finding
where all models agree is different from a finding where two agree and
one explicitly disagreed (the disagreement may reveal a deeper issue).

### Cross-Judge in Parallel

The cross-judge step (reading all reviewer outputs and synthesizing)
runs in parallel with the parent's own reading of the code. The parent
does not wait for reviewers before forming its own opinion — it forms
its opinion independently, then compares. This prevents anchoring: if
the parent reads the reviewers first, it tends to see only what they
saw.

## Concrete Instances

### Single-Model Review (Degraded Case)

When only one model is available, the pattern degrades to
single-context review. Every finding is lone-model (lower confidence).
The lead judgment categorization still applies — the lead reads the
single reviewer's output and categorizes each finding. The Agreement
Map has one column. This is the current default for most
code-review-guidance invocations.

### Multi-Model Interrogate

When two or more models are available (e.g. a frontier model and a
fast local model, or two different frontier models), spawn one
reviewer per model with the same rubric. Collect outputs, build the
Agreement Map, apply lead judgment. The cost is N× the single-model
cost, but the signal quality improvement is more than N× — convergence
across independent models is strong evidence.

## Anti-Patterns

- **Assigned personas instead of model diversity** — telling one model
  to "be the security reviewer" and another to "be the performance
  reviewer." This creates coverage gaps and false specialization. Use
  the same rubric for all reviewers; let model diversity provide the
  adversarial signal.
- **Averaging scores instead of consensus tiers** — averaging two
  models' scores (7 + 3 = 5) hides the disagreement. The disagreement
  is the signal. Use consensus tiers (high vs lone), not averages.
- **Reading reviewers before forming own opinion** — the parent
  anchors on the reviewers' findings and misses what they missed. Form
  your own opinion first, then compare.
- **Treating lone-model findings as noise** — a lone-model finding may
  be a genuine blind spot. Categorize as Consider or Noted, not
  automatic Dismiss. The lead judgment exists to make this call.
- **Voting instead of judgment** — the lead does not tally votes. The
  lead reads the reasoning, not just the verdicts, and makes a
  judgment. Two models agreeing for the wrong reason should be
  Dismissed, not Acted on.

## See Also

- [Encode Lessons in Structure](encode-lessons-in-structure.md) —
  structural enforcement of review findings (lint rules, scripts)
  instead of text instructions that get skipped.
- [Guard the Context Window](guard-the-context-window.md) — route
  reviewer outputs to subagents, keep only the Agreement Map in the
  main thread.
