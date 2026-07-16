<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **business** · Status:  · Version: 1.0.0

Apply the Agent Organization 26-tier prioritization framework to triage tasks, requests, and work items. Use when users need to prioritize work, evaluate requests against the prioritization matrix, determine accept/defer/reject decisions, or apply the Eisenhower matrix to task management. Make sure to use this skill whenever the user mentions prioritization, triage, task ranking, request evaluation, decision matrices, or needs to determine what work to focus on, even if they don't explicitly ask for "task triage.

## Metadata

| Field | Value |
|-------|-------|
| Name | `task-triage` |
| Category | `business` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

The Agent Organization uses a three-dimensional prioritization framework:

1. **Work Type** — 26 tiers from Security Incidents (Tier 1) to Backlog (Tier 26)
2. **Requestor Priority** — Adjustments based on who is making the request (±3 tiers)
3. **Cost/Capacity** — Shared Services capacity constraints by effort level

This skill helps you apply this framework to make consistent, defensible prioritization decisions.

## When to Use

Use this skill when you need to:

- Evaluate a new request or task against the prioritization framework
- Determine whether to accept, defer, reject, or escalate work
- Apply the Eisenhower matrix (Urgent/Important) to task prioritization
- Calculate effective priority considering requestor and cost factors
- Resolve priority conflicts between competing requests
- Document prioritization decisions with clear rationale

## Related Skills
- **org-development** (template, related) — Organizational development skill defining the entity and department structure used for requestor adjustments
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/business/task-triage/SKILL.md`](skills/business/task-triage/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:35:31Z
