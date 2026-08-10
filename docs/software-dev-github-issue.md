<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

File a well-formed GitHub issue against a third-party or upstream repository. Discovers the project's own contribution standards and issue templates (caching them with a 7-day TTL), searches for duplicate issues, drafts a body that matches project conventions, presents it for human review, posts via gh --body-file, and validates the posted body for corruption. Use when the user wants to file a feature request, bug report, or proposal against a repository they don't own. Do NOT trigger on internal project issues, PR creation, or code changes — use github-pr for pull requests.

## Metadata

| Field | Value |
|-------|-------|
| Name | `github-issue` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `github`
- `issue`
- `upstream-contribution`
- `open-source`
- `filing`
- `forge`

## Related Skills
- **github-pr** (skill, complement) — Creates PRs against upstream repos; requires an issue number (creates one inline using this skill's procedure if needed)
- **github-issue-procedure** (template, base-framework) — Shared issue creation procedure inlined at build time
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **gh-posting-guard** (template, base-framework) — Shared guard for posting GitHub bodies via gh --body-file
- **forge-template-discovery** (template, base-framework) — Host-aware issue/PR template directory search order

---

- **Full skill**: [`skills/software-dev/github-issue/SKILL.md`](skills/software-dev/github-issue/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-10T21:38:16Z
