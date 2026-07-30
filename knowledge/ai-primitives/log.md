---
type: Log
title: Bundle Update Log
description: Chronological history of updates to the AI Primitives knowledge bundle.
tags: [log, history]
date:
  created: "2026-07-12"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
---

# Bundle Update Log

## 2026-07-29
* **Ingest**: Added [cross-domain/agent-integration-standards.md](cross-domain/agent-integration-standards.md)
  — concept page documenting the three cross-domain agent-integration
  standards from ADR-20260607001 v5.0.0: skill emission via `--gen-skill`,
  coding-agent hook wiring with per-agent `config.toml` preferences, and
  non-user-identifiable telemetry. Maps each standard onto the primitive
  system (skill emission → Skills, hook wiring → Hooks + Memory, telemetry
  boundary → Rules), cross-links the canonical ADR and the Rust-specific gist
  in rust-development-practices, and names apmw as the canonical reference
  implementation.
* **Update**: Listed the new cross-domain page in [index.md](index.md).

## 2026-07-28
* **Ingest**: Added [cross-domain/eve-filesystem-agents.md](cross-domain/eve-filesystem-agents.md)
  — concept page documenting vercel/eve, a filesystem-first framework for
  durable AI agents. Maps eve's `agent/` layout (instructions, tools, skills,
  subagents, channels, schedules, evals) to the skills-src primitive system,
  extracts transferable design lessons (path-as-name, subagents as a
  first-class slot, evals as a peer directory), and contrasts filesystem-first
  vs template-first composition.
* **Update**: Added eve as a source to [primitives/agents.md](primitives/agents.md)
  and [composition/composition-chain.md](composition/composition-chain.md),
  with a "Real-World Reference" section in agents.md and a "Real-World
  Composition" note in the Layer 5 (Agents) section of the composition chain.
* **Update**: Listed the new cross-domain page in [index.md](index.md).

## 2026-07-26
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md, migrated `# Citations` body sections to `sources` frontmatter with footnote attribution per §13.1, (migrated `timestamp` to `generated` if applicable).

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
