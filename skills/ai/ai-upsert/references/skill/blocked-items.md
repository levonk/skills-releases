# Blocked Items — Format Contract and Human Handoff Routing

## Table of Contents

1. [Blocked-Item Format](#blocked-item-format)
2. [Routing Decision — HUMAN vs AGENT](#routing-decision--human-vs-agent)
3. [When to Create the Human Handoff](#when-to-create-the-human-handoff)
4. [Human Handoff Content](#human-handoff-content)
5. [GitHub Issue Creation](#github-issue-creation)
6. [Human Handoff Filename](#human-handoff-filename)
7. [Human Handoff Archive](#human-handoff-archive)

When a task cannot proceed, mark it `[!]` and follow the **blocked-item format
contract**. A vague "note the blocker inline" is not sufficient — the blocker
must be structured so the next reader (agent or human) can act on it
immediately.

## Blocked-Item Format

Append after the `[!]` mark on the same task line, using a sub-list:

```markdown
- [!] {task description}
    - BLOCKED ON: {what is needed — concrete, one line}
    - NEEDED FROM: {HUMAN: action description | AGENT: action description}
    - WHY CAN'T PROCEED: {reason — what was attempted and why it failed}
    - TRIED: {approaches attempted before blocking}
    - ROUTES TO: {path to human handoff file if HUMAN | "stays inline" if AGENT}
```

## Routing Decision — HUMAN vs AGENT

- **HUMAN:** the blocker requires human-only action (API keys, credentials,
  access grants, decisions between researched options, approvals for
  destructive operations, information only the user has). Create a human
  handoff document in `.agents/handoffs/human/todo/` following the
  `work-lifecycle` include's Audience Variants section. The human handoff is
  action-oriented (what is needed, why, what was tried, how to unblock). The
  agent handoff's `[!]` mark references the human handoff file path in
  `ROUTES TO:`.
- **AGENT:** the blocker can be resolved by a future agent session (waiting
  on an upstream dependency, needing more research, requiring a different
  skill). The `[!]` mark stays inline with `ROUTES TO: stays inline`. No
  human handoff is created.

## When to Create the Human Handoff

Immediately when the blocker is identified and classified as HUMAN — not at
end-of-run. This is the crash-safety guarantee: if the run crashes after the
human handoff is written, the human action request is already durable on disk.

## Human Handoff Content

Self-contained — include Project Context (project name and description),
Feature Context (what was being attempted and why), and Current State (what's
done, what's in progress, where the blocker sits) so the human can understand
the full picture without reading the agent handoff. See the `work-lifecycle`
include's "Audience Variants" section for the full required sections.

## GitHub Issue Creation

After writing the human handoff file, if `gh` is available and the repo has a
GitHub remote, create a GitHub issue from the file content via `gh issue
create --body-file --label "human-handoff"`. The issue is the visibility
layer — it shows up in the issue list and stays open until the human resolves
the blocker. The file is always created first (crash safety); the issue is
conditional. See the `work-lifecycle` include's "Audience Variants" section
for the full protocol, including the `gh-posting-guard` requirement to use
`--body-file` (never `--body`).

## Human Handoff Filename

`YYYYMMDDHHmm-{slug}.md` in `.agents/handoffs/human/todo/`, where the slug
describes the action needed (e.g., `provide-openai-api-key`, not
`blocked-on-eval-runner`). Same naming convention as agent handoffs.

## Human Handoff Archive

When the human resolves the blocker and the blocking task is marked `[x]`,
archive the human handoff from `human/todo/` to `human/archive/YYYY/MM/` via
`git mv` per the `work-lifecycle` include's archive protocol. If a GitHub
issue was created, verify it is closed before archiving.
