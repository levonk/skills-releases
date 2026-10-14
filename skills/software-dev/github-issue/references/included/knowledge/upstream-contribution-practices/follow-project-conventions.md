---
type: Practice
title: Follow Project Conventions
description: Match the project's existing style for changelog entries, issue/PR templates, documentation format, and translated docs. Prevents review feedback asking you to match their conventions.
tags: [conventions, style, changelog, templates, documentation, translation]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-issue-pr-templates-md-changelog-entry
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/references/issue-pr-templates.md
    title: "nixify issue-pr-templates.md — Changelog Entry"
  - id: nixify-skill-md-step-15
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 15"
---

# Follow Project Conventions

## Rule

Every artifact you produce — code, documentation, changelog entries,
issue bodies, PR bodies — should match the project's existing
conventions. Read their files first, then mimic the style.

## Why

Maintainers notice when a contribution doesn't match their conventions.
A changelog entry in the wrong tense, a README section in a different
heading style, or a missing translation update all generate review
feedback that delays the PR. Matching conventions signals you respect
the project's norms and did your homework.

## What to Match

### Changelog

If the project has a `CHANGELOG.md`, check:

- **Tense** — most use present tense ("Added" not "Adds")
- **Section structure** — `## Unreleased` → `### Added` / `### Changed`
  / `### Fixed` (Keep a Changelog format) or a custom format
- **Entry style** — reference issue numbers? Link to PRs? One line or
  multi-line?

```bash
# Check existing changelog style
head -50 CHANGELOG.md
```

### Issue and PR Templates

If the project has `.github/ISSUE_TEMPLATE/` or
`.github/PULL_REQUEST_TEMPLATE.md`, use them. Don't invent your own
format.

```bash
ls .github/ISSUE_TEMPLATE/
cat .github/PULL_REQUEST_TEMPLATE.md
```

### Documentation

Match the project's documentation style:

- **Heading levels** — if install instructions are `### Installation`,
  don't use `## Nix Installation`
- **Code block language tags** — if they use ```bash, don't use ```sh
- **Link style** — relative vs absolute, GitHub vs custom domain

### Translated Docs

If the project has translated READMEs (e.g., `README.ko.md`,
`README.zh-CN.md`, `README.ja.md`), mirror your changes to each
translation that exists. Don't update only the English README and leave
the translations stale.

```bash
# Find translated READMEs
ls README*.md
```

### Commit Messages

Match the project's commit message conventions:

- **Conventional Commits** (`feat:`, `fix:`, `docs:`) — check `git log`
  for the pattern
- **No commit trailers** — some projects don't use `Co-Authored-By` or
  `Generated with` lines. Check their existing commits before adding
  them.
- **Line length** — some projects enforce 72-character subject lines
- **Tag arrays** — some projects append a `#tag` array as the last line
  of the commit body for search/filter/analytics metadata. The
  `git-repository-management` skill uses this convention with
  `#skill-grm-created` as a provenance marker. See the shared
  `commit-tagging-standard` include for the full tag schema and the
  project-override config path.

```bash
# Check existing commit style
git log --oneline -20
```

## Commit Message Tagging Standard (MANDATORY — NOT OPTIONAL)

**Every commit produced by this skill MUST include a `#tag` array as the last
line of the commit body. This is not optional, not a suggestion, and not a
"nice to have." The tag array is a hard requirement on equal footing with the
mandatory commit body and the no-AI-signatures rule.**

The `git-commit-batch.sh` script **enforces this mechanically** — commits
missing the tag array are rejected with `COMMIT_FAILED:NO_TAG_ARRAY`, the same
way bodyless commits are rejected with `COMMIT_FAILED:NO_BODY`. You cannot
bypass this by omitting the tags; the script will fail the commit.

Tags are metadata for search, filtering, and analytics — they do not replace
the subject, the body prose, or any project-standard footer (ticket
references, `Fixes #N`, `Signed-off-by`, etc.).

### Agent MUST NOT decide to skip the tag array

You (the AI agent) **must not** decide on your own to omit the tag array. The
tag array is mandatory unless ALL of the following are true:

1. A project-level config file exists at
   `.agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml`
   inside the repository being committed to, AND
2. That file contains `[commit-tagging]` with `enabled = false`, AND
3. The user has explicitly confirmed the override applies to this commit.

If any of these conditions is unmet, the tag array is required. Do not skip it
because the change "feels too small to tag," because the repo "doesn't seem to
use tags," because you are unsure which tags apply, or because the project's
AGENTS.md is silent on tagging. When unsure which tags apply, use the standard
list below — a best-guess tag array is always better than omitting it (the
script will reject the omission; it will not reject a suboptimal tag choice).

### Format

The tag line is the **last line of the body**. A blank line separates it from
the body prose above, and a blank line separates it from any optional footer
below (`Closes #N`, `Fixes #N`, `Signed-off-by:`, etc.):

```
<subject>

<body line 1>
<body line 2>

#project-auth #module-jwt #design-di #skill-grm-created

Closes #123
```

- **One line**, space-separated `#kebab-case` tags
- **Blank line before** the tag line (separates it from the body prose)
- **Blank line after** the tag line (separates it from the optional footer)
- **No trailing punctuation**
- **Tags are part of the body**, not a git trailer — they do not appear in
  `git log --format="%B"` trailers and are not parsed by `git interpret-trailers`
- **The footer is optional and project-specific** — the tag line is always
  present; the footer (`Closes #N`, `Fixes #N`, `Signed-off-by:`, etc.) is
  added by the project's own conventions

### Standard Tag Categories

The skill always prioritizes the **project's own conventions** — if a project
defines its own tagging scheme, use it instead and skip this standard. When no
project convention exists, use this standard list as a minimum:

| Category | Prefix | Example | Notes |
|----------|--------|---------|-------|
| Project | `#project-<slug>` | `#project-auth` | The functional area / project module touched |
| Module | `#module-<slug>` | `#module-jwt` | The specific submodule or component |
| Design pattern | `#design-<slug>` | `#design-di`, `#design-repo`, `#design-cqrs` | Architectural pattern applied |
| Change type | `#type-<slug>` | `#type-feat`, `#type-fix`, `#type-refactor` | Mirrors Conventional Commits type |
| Skill creator | `#skill-<skill>-created` | `#skill-grm-created` | Identifies which skill produced this commit |
| Breaking | `#breaking` | `#breaking` | Breaking change marker |
| Security | `#security` | `#security` | Security-relevant change |

**Skill-creator tag**: Every commit made by the
`git-repository-management` skill includes `#skill-grm-created` as the last
tag in the array. This identifies the commit's provenance without adding AI
attribution (it is a searchable tag, not a `Co-Authored-By` trailer). This
does **not** replace any project-standard footer or ticket reference.

### Choosing Tags

1. **Project convention first** — if the repo has a tagging scheme in
   AGENTS.md, CONTRIBUTING.md, or `.gitmessage`, use it and skip this standard
2. **Be concise** — 2-5 tags per commit is typical; do not tag every file or
   every function
3. **Tag the significant change, not the diff** — `#module-jwt` not
   `#file-auth-py`; tags follow the same "significant change" principle as
   the subject line
4. **Redundancy is OK** — some tags will overlap with the Conventional Commits
   type in the subject (`feat:` → `#type-feat`). This is intentional; the tag
   makes the type machine-filterable without parsing the subject
5. **Never tag secrets** — no tag should reference a secret value, key name,
   or internal identifier that would leak sensitive context

### Disabling Tagging (Project Override — explicit config only)

A repository can disable commit tagging for a specific skill by creating a
config file at:

```
.agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml
```

Where:
- `<github-owner>` — the GitHub owner of the skill's source repo (e.g. `levonk`)
- `<github-repo>` — the GitHub repo name of the skill's source (e.g. `skills-releases`)
- `<skill-path>` — the skill's path within the source repo (e.g. `software-dev/git-repository-management`)

Example to disable tagging for the `git-repository-management` skill installed
from `levonk/skills-releases`:

```toml
# .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml
[commit-tagging]
enabled = false
```

When `enabled = false`, the skill omits the tag line entirely from all commits
in that repository. Other config keys may be added in the future (e.g.
`additional-tags`, `replace-standard-tags`).

**Discovery**: the skill checks for this config file relative to the
repository root of the repo being committed to (not the skill's own source
repo). If the file does not exist, tagging is enabled by default.

**This is the ONLY way to disable tagging.** The agent must not disable
tagging based on its own judgment, the absence of tags in prior commits, the
perceived triviality of the change, or the silence of the project's
AGENTS.md/CONTRIBUTING.md on the subject. The `git-commit-batch.sh` script
reads this config file and skips the `NO_TAG_ARRAY` check only when
`enabled = false` is present — there is no other bypass.


## Related

* [Contribution Eligibility](contribution-eligibility.md) — reading
  CONTRIBUTING.md is where convention discovery starts
* [Format Artifacts](format-artifacts.md) — formatting is a subset of
  conventions; the formatter handles code style, this page covers
  everything else
* [Minimal Scope](minimal-scope.md) — don't reformat or restyle files
  you're not touching (scope expansion)
