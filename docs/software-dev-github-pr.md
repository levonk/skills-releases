<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.1.0

Open a well-formed pull request against a third-party/upstream repository OR your own repository. Detects repo mode (own-repo vs upstream) via gh viewerPermission. For upstream: forks and clones, discovers contribution standards and PR templates, runs CLA gate, pushes to fork. For own-repo: skips fork (push to origin directly), skips CLA gate, checks only for local PR templates. Both modes: requires an issue number (creates an orientation issue inline using the github-issue procedure if none provided; own-repo may skip with a one-line justification), runs the project's tests for a baseline, commits with a clean linear history, syncs before push, drafts a PR body that matches project conventions, presents it for human review, posts via gh --body-file, and validates the posted body. Use when the user wants to contribute a code change to a repository they own or don't own. Do NOT trigger on issue filing without code, or nix packaging — use github-issue for issues only, nixify for Nix flake packaging.

## Metadata

| Field | Value |
|-------|-------|
| Name | `github-pr` |
| Category | `software-dev` |
| Version | `1.1.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `github`
- `pull-request`
- `upstream-contribution`
- `open-source`
- `fork`
- `forge`
- `own-repo`

## Related Skills
- **github-issue** (skill, complement) — PRs should reference an issue (or a one-line justification in own-repo); use github-issue for issue-only work
- **github-issue-procedure** (template, base-framework) — Issue creation procedure inlined at build time so github-pr is self-contained — no separate github-issue install required (handles both own-repo and upstream modes)
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **gh-posting-guard** (template, base-framework) — Shared guard for posting GitHub bodies via gh --body-file
- **forge-template-discovery** (template, base-framework) — Host-aware issue/PR template directory search order

---

- **Full skill**: [`skills/software-dev/github-pr/SKILL.md`](skills/software-dev/github-pr/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:58:30Z
