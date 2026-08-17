---
type: Practice
title: Comprehensive PR Templates — UX Journey, Security Impact, Rollback Plan
description: A PR template that goes beyond Summary and Validation to require UX journey diagrams, architecture diagrams, security impact, compatibility/migration, blast radius, and a rollback plan — forcing the author to think about consequences before review.
tags: [pull-request, pr-template, review, security-impact, rollback-plan, ux-journey, blast-radius, github, gitlab]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: github-pr-template-docs
    resource: "https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository"
    title: "GitHub — Creating a pull request template for your repository"
  - id: gitlab-mr-template-docs
    resource: "https://docs.gitlab.com/ee/user/project/description_templates.html"
    title: "GitLab — Description templates"
---

# Comprehensive PR Templates — UX Journey, Security Impact, Rollback Plan

## Rule

A PR template should require the author to answer questions a reviewer
cannot infer from the diff alone. Beyond the standard Summary and
Validation Evidence, a comprehensive template includes sections that force
consequence-thinking **before** review:

1. **Summary** — problem, why it matters, what changed, and a scope
   boundary ("what did **not** change").
2. **UX Journey** — before/after diagrams of the user-facing flow. Even
   non-UI changes have a user journey (a CLI command, an API call, a
   webhook delivery). The before/after comparison surfaces what the user
   will experience differently.
3. **Architecture Diagram** — before/after module diagrams with a
   connection inventory table listing every module-to-module edge and its
   status (unchanged / new / removed / modified).
4. **Label Snapshot** — risk level, size, scope, and module — so reviewers
   can triage without reading the full diff.
5. **Change Metadata** — change type (bug / feature / refactor / docs /
   security / chore) and primary scope.
6. **Linked Issue** — closes / related / depends on / supersedes.
7. **Validation Evidence** — commands run and result summary. If a command
   is intentionally skipped, explain why.
8. **Security Impact** — new permissions or capabilities? New external
   network calls? Secrets/tokens handling changed? File system access scope
   changed? If any yes, describe risk and mitigation.
9. **Compatibility / Migration** — backward compatible? Config/env changes?
   Database migration needed? If yes, exact upgrade steps.
10. **Human Verification** — what was personally validated beyond CI.
    Verified scenarios, edge cases checked, and what was **not** verified.
11. **Side Effects / Blast Radius** — affected subsystems/workflows,
    potential unintended effects, and guardrails/monitoring for early
    detection.
12. **Rollback Plan** — fast rollback command/path, feature flags or config
    toggles, and observable failure symptoms that would trigger rollback.

The template is a checklist, not a narrative prompt. Each section has
explicit questions with `Yes/No` answers or structured fields — not
free-form text boxes that get filled with "N/A."

## Why

A template with only Summary and Validation Evidence produces PRs where the
author has not thought about:

- **What happens if this breaks** — no rollback plan means the reviewer
  cannot assess whether the change is safe to merge. A one-line rollback
  command ("revert commit X, redeploy") makes the risk calculable.
- **What else is affected** — the diff shows the changed files, but not the
  downstream subsystems that depend on them. The blast radius section forces
  the author to enumerate the affected workflows and their monitoring.
- **Security implications** — a change that adds a new external network call
  or broadens file system access is a security-relevant change, even if the
  diff looks benign. The security impact section catches this before review,
  not after a security incident.
- **User experience** — the diff shows code changes, not the user's journey.
  The before/after UX diagram surfaces what the user will experience
  differently, even for backend-only changes (API response shape, error
  messages, latency).
- **Migration path** — a change that requires a database migration or a
  config change is not "just merge it." The compatibility section forces
  the author to document the exact upgrade steps.

## How to Apply

### Template placement

Place the template where the forge auto-discovers it:

- **GitHub**: `.github/pull_request_template.md` (or
  `.github/PULL_REQUEST_TEMPLATE.md`). For multiple templates,
  `.github/PULL_REQUEST_TEMPLATE/<name>.md` with a `?template=<name>.md`
  query parameter on the PR creation URL.
- **GitLab**: `.gitlab/merge_request_templates/<name>.md`. GitLab does not
  auto-apply a default MR template — the author selects it from the
  template dropdown when creating the MR.

### Filling the template

When opening a PR via `gh pr create`, copy the template into the body
explicitly — GitHub only auto-applies the template through the web UI, not
through the CLI:

```bash
gh pr create --body-file .github/pull_request_template.md
```

For GitLab:

```bash
glab mr create --description "$(cat .gitlab/merge_request_templates/Default.md)"
```

### Section-by-section guidance

**UX Journey**: Draw the before/after as ASCII art or Mermaid sequence
diagrams. Show each step the user takes. Highlight what changed with
brackets or asterisks. Even a CLI change has a UX journey: the command the
user types, the output they see, the next action they take.

**Architecture Diagram**: List every module touched or connected to the
change. Draw lines between them. Use `[+]` for new modules, `[-]` for
removed, `[~]` for modified. The connection inventory table should list
every module-to-module edge with its status.

**Security Impact**: Answer all four questions. A "No" is informative — it
tells the reviewer the change does not broaden the attack surface. A "Yes"
without a mitigation is a red flag.

**Rollback Plan**: The fast rollback command should be a single command or
a short sequence, not a paragraph of prose. "Revert commit X, redeploy" is
good. "Contact the on-call engineer and follow the runbook at
<url>" is acceptable for complex changes. "N/A" is not acceptable — every
change can be reverted.

## Concrete Instances

### GitHub PR template (12-section)

A `.github/pull_request_template.md` file with the 12 sections described
above. Each section has a header and structured prompts — `Yes/No`
questions for security and compatibility, table templates for the
connection inventory, and code blocks for the UX journey and architecture
diagrams. The template is copied into the PR body explicitly when using
`gh pr create` because GitHub only auto-applies it through the web UI.

### GitLab MR template

A `.gitlab/merge_request_templates/Default.md` file with the same 12
sections. GitLab MR templates support the same markdown structure. The
author selects the template from the dropdown when creating the MR, or
passes it via `--description` in `glab mr create`. GitLab also supports
multiple templates for different change types (feature, bugfix, security).

### Conventional Commits + auto-generated PR body

For projects using conventional commits (`feat:`, `fix:`, `BREAKING
CHANGE:`), the PR body can be partially auto-generated from the commit
messages. Tools like `release-please` and `semantic-pull-request` generate
the Summary and Change Metadata sections from commit types. The remaining
sections (UX Journey, Security Impact, Rollback Plan) are still
manual — they require human judgment that commit messages cannot encode.

## Related

* [Human Review Gate](human-review-gate.md) — the template is filled before
  the human review gate; the reviewer uses the template to assess the
  change.
* [Forge Template Discovery](forge-template-discovery.md) — discover the
  correct template path for the target forge before drafting the PR body.
* [gh --body-file](gh-body-file.md) — use `--body-file` to avoid body
  corruption when posting the PR.
* [Minimal Scope](minimal-scope.md) — the scope boundary in the Summary
  section ("what did **not** change") enforces minimal scope.
