<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **business** · Status:  · Version: 1.1.0

Draft, review, and improve business emails using a structured framework that prioritizes speed, clarity, and judgment. Creates new emails from a brief or ask, reviews and improves existing emails for conciseness and impact, and converts rough notes or chat messages into polished emails. Use when users need to write or revise a business email, draft an action request, decision email, status update, risk notification, escalation, or confirmation message, prepare a client-facing or executive communication, or improve an email's subject line, structure, or tone. Make sure to use this skill whenever the user mentions email writing, email drafting, email review, email revision, business communication, professional email, subject lines, or wants help composing a message for work, even if they don't explicitly ask for "biz-email-upsert." Do NOT trigger on personal/informal emails, marketing emails or newsletters, customer support ticket responses, or coding tasks — this skill is for structured business communication, not bulk email or casual correspondence.

## Metadata

| Field | Value |
|-------|-------|
| Name | `biz-email-upsert` |
| Category | `business` |
| Version | `1.1.0` |
| Status | `` |
| Owner |  |

## Overview

### What This Skill Does

1. **Draft new emails** — from a brief, ask, or set of bullet points
2. **Review and improve existing emails** — audit against the framework, propose fixes
3. **Convert rough notes or chat messages** — into polished, structured emails

### Email Architecture (Four Layers)

1. **Subject line** — triage tag (Action / Decision / Update / Risk) + topic
2. **First sentence** — the ask, decision, risk, or update. No warm-up.
3. **Body** — two to five lines of facts with names, numbers, and dates
4. **Close** — recommendation or next step, owner and deadline

See `references/email-framework.md` for the full principle set and default
structure template.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **task-triage** (skill, complement) — Prioritization framework for triaging tasks — use before writing email to determine if the request warrants an email at all

---

- **Full skill**: [`skills/business/biz-email-upsert/SKILL.md`](skills/business/biz-email-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:39:39Z
