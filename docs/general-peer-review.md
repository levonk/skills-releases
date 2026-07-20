<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **general** · Status:  · Version: 1.0.0

>-

## Metadata

| Field | Value |
|-------|-------|
| Name | `peer-review` |
| Category | `general` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

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

## Related Skills
- **think-assist** (skill, consumer) — Light council that uses peer-review for its blind review round
- **briefingmemo** (skill, optional-consumer) — Heavy council that may adopt peer-review before the CSO memo
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/general/peer-review/SKILL.md`](skills/general/peer-review/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
