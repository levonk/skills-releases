<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status:  · Version: 1.0.0

Use when making high-stakes business decisions, strategic choices, partnership evaluations, or any decision requiring structured committee deliberation. Triggers on requests like 'help me decide', 'strategic decision', 'briefing memo', 'committee deliberation', or 'evaluate this decision'. Strategic decision-making system using multi-agent committee deliberation that transforms strategic questions into well-researched decisions through a structured committee process: (1) Create structured brief with required sections, (2) Research phase where committee requests additional information, (3) Committee deliberation with parallel debate and optional blind peer review, (4) CSO final decision memo with one concrete next step, (5) Post-decision review by specialized agents. 17-member committee includes dedicated Partnership & Opportunities Agent for strategic partnerships, government contracts, funding opportunities, and growth synergies, plus an Outsider member who catches curse-of-knowledge blind spots. Do NOT trigger on fast pressure-tests or "council this" requests (use think-assist instead), factual questions with one right answer, pure creation tasks, or summary/processing tasks.

## Metadata

| Field | Value |
|-------|-------|
| Name | `briefingmemo` |
| Category | `execution` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **think-assist** (skill, dependency) — Thinking-method library consumed by this skill's committee
- **peer-review** (skill, optional) — Blind peer-review round that can be added before the CSO memo
- **ai-guidance-improver** (skill, complement) — For improving guidance file quality
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/execution/briefingmemo/SKILL.md`](skills/execution/briefingmemo/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-10T21:38:16Z
