---
type: Practice
title: Human Review Gate
description: Present issue and PR content to the user for review before posting. Never auto-open PRs or issues. Prevents publishing wrong content to a public upstream repo.
tags: [review, human-in-the-loop, gate, pr, issue, publishing]
timestamp: 2026-07-14T12:00:00Z
---

# Human Review Gate

## Rule

Before posting any issue or PR to an upstream repository, present the
full content (title and body) to the user for review. Do not
auto-open. Wait for explicit approval before running `gh issue create`
or `gh pr create`.

## Why

Once an issue or PR is posted to a public upstream repo:

- **It's public immediately.** The maintainer and anyone watching the
  repo gets a notification. There's no "undo."
- **First impressions matter.** A PR with a wrong title, broken body, or
  incorrect install examples creates a bad first impression that's hard
  to recover from — even after you edit it.
- **Edit history is visible.** GitHub shows that the PR was edited,
  which signals the content wasn't reviewed before posting.
- **Notifications are sent.** Editing the body after posting doesn't
  un-send the original notification. Subscribers see the original
  broken version.

The human reviewer catches things the skill can't:
- Wrong upstream owner/repo in the body
- Tone that doesn't match the project's culture
- Technical claims that are inaccurate for this specific project
- Missing context the maintainer would expect

## What to Present

Present the **complete, final** content — exactly what will be posted,
with all placeholders substituted:

```
Title: feat: add Nix flake support for one-command installation

Body:
[full rendered markdown, with $UPSTREAM_OWNER etc. substituted]
```

Do not present a template with unsubstituted placeholders and ask "does
this look right?" — present the final text. The user should review what
they're about to post, not a template.

## When to Present

| Artifact | When to present |
|----------|----------------|
| Orientation issue | After all work is done, before `gh issue create` |
| PR description | After the issue is created (need issue number for `Resolves #N`), before `gh pr create` |
| Changelog entry | Before committing, if the project has a CHANGELOG.md |

## Related

* [gh --body-file](gh-body-file.md) — the posting method that preserves
  the reviewed content intact
* [Upstream Identity](upstream-identity.md) — the human review gate is
  where wrong upstream references get caught

# Citations

[1] [nixify SKILL.md Step 20](https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl) — "Present to user for review. Record issue number for PR body."
[2] [nixify SKILL.md Step 23](https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl) — "Present to user for review. Do NOT open PR automatically."
