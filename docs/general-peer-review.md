<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **general** · Status:  · Version: 1.0.0

Run an anonymous (blind) peer-review round over a set of responses, designs, documents, code diffs, or proposals so reviewers evaluate on merit instead of authority. Use when you have multiple independent outputs on the same question and want to surface the strongest, the biggest blind spot, and what every reviewer missed — without named-author bias. Triggers on requests like 'peer-review these', 'review blind', 'anonymize and review', 'which response is strongest', 'pressure-test these options', 'compare these proposals without bias', 'blind review this', or whenever a council / multi-advisor / multi-model process needs an unbiased evaluation round. Also use for code review (multiple blind reviewers on a diff), design review, document/policy review, and any multi-perspective evaluation where deferring to a named authority would distort the verdict. Do NOT trigger on single responses with nothing to compare against, factual questions with one right answer, pure creation tasks, or summary/processing tasks.

## Metadata

| Field | Value |
|-------|-------|
| Name | `peer-review` |
| Category | `general` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **think-assist** (skill, consumer) — Light council that uses peer-review for its blind review round
- **briefingmemo** (skill, optional-consumer) — Heavy council that may adopt peer-review before the CSO memo
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/general/peer-review/SKILL.md`](skills/general/peer-review/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-17T03:55:48Z
