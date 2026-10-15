---
type: Practice
title: AI Assistance Caveats
description: How to use AI safely as a cancer-patient adjunct — models may downplay seriousness before diagnosis, but excel at visit summarization, question generation, and standard-of-care interpretation.
tags: [cancer, ai, llm, caveats, summarization]
date:
  created: "2026-10-15"
  knowledge-basis: "2026-10-15"
  last-used: "2026-10-15"
sources:
  - id: maxwell-cancer-2026
    resource: "https://jjmaxwell4.com/writing/things-to-know-when-you-get-cancer/"
    title: "Things to know if you get cancer (2026 Edition) — JJ Maxwell"
---

# AI Assistance Caveats

## The Failure Mode: Reassurance Bias

Before diagnosis, multiple AI models pushed the seed author toward
"you don't have cancer" for a while.[^maxwell-cancer-2026] Models
pattern-match toward common, benign explanations and are tuned to be
reassuring. Treat pre-diagnosis AI reassurance as noise: persistent
symptoms deserve a physician and, when indicated, a biopsy — not a
model's probability estimate.

## Where AI Helps After Diagnosis

- **Visit summarization.** Dictate what happened and what the doctor
  said after each appointment; have AI produce a dated summary and a
  list of follow-up questions.[^maxwell-cancer-2026] See
  [Medical Record Keeping](medical-record-keeping.md).
- **Standard-of-care interpretation.** NCCN flow charts are dense;
  AI is good at mapping your specific case (type, stage, markers) onto
  the decision tree.[^maxwell-cancer-2026] See
  [Standard of Care Navigation](standard-of-care-navigation.md).
- **Question generation.** "Here is my diagnosis and planned
  treatment; what should I ask my oncologist?" reliably surfaces
  questions the patient didn't know to ask.
- **Document translation.** Pathology and radiology reports in plain
  language, with a list of terms to ask the team about.

## Operating Rules

- **AI informs questions; physicians answer them.** Never let a
  model's output substitute for the care team's judgment on treatment
  decisions.
- **Feed it documents, not descriptions.** Accuracy rises sharply
  when the model sees the actual pathology report rather than your
  paraphrase.
- **Verify citations.** If a model cites a guideline, open the
  guideline. Models cite plausible-but-wrong sources.
- **Watch for drift toward reassurance.** If a model tells you a
  concerning result is "probably fine," that is a reason to ask the
  physician — not a reason to relax.

[^maxwell-cancer-2026]: JJ Maxwell, "Things to know if you get cancer
    (2026 Edition)."
