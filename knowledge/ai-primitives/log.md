---
type: Log
title: Bundle Update Log
description: Chronological history of updates to the AI Primitives knowledge bundle.
tags: [log, history]
timestamp: 2026-07-11T10:30:00Z
---

# Bundle Update Log

## 2026-07-18
* **Cross-link**: Added [cross-domain/tech-decision-risk-assessment.md](cross-domain/tech-decision-risk-assessment.md)
  — stub reference page pointing to the canonical risk hierarchy in
  software-architecture-essentials. Adds AI-agent-specific application
  guidance: place each path on the hierarchy before recommending, pair with
  the AI + human timeline estimate format, name specific reasons when
  deviating from the lower-risk path.
* **Cross-link**: Added [cross-domain/ai-human-timeline-estimates.md](cross-domain/ai-human-timeline-estimates.md)
  — stub reference page pointing to the canonical four-axis estimate format
  in software-architecture-essentials. Adds AI-agent-specific application
  guidance: do not report "X days of engineering", report on four axes
  (AI execution, human review, verification, tail risk); distinguish what
  collapses with AI from what does not.
* **Update**: Added "Cross-Domain Principles (cross-links)" section to
  [index.md](index.md) listing both stub pages.

## 2026-07-12
* **Initialization**: Created the AI Primitives knowledge bundle at `src/current/knowledge/ai-primitives/`.
* **Creation**: Created bundle root `index.md` with `okf_version: "0.1"` and full catalog.
* **Creation**: Created `overview.md` synthesis document.
* **Creation**: Created 10 primitive definition concept documents (committees, agents, skills, workflows, templates, prompts, memory, rules, hooks, snippets).
* **Creation**: Created full comparison matrix (`comparison/primitive-comparison.md`) with all dimensions.
* **Creation**: Created composition chain document (`composition/composition-chain.md`) documenting templates → prompts → workflows → skills → agents → committees.
* **Creation**: Created 12 upsert skill reference documents covering the full upsert family.
* **Creation**: Created build-system docs (templater, dependencies).

## 2026-07-11
* **Research**: Explored the skills-src repo structure, reading AGENTS.md, developer guide, all upsert skill sources, agent/committee/workflow/template/prompt/rule/hook/snippet/context structures.
