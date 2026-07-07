---
name: task-triage
description: Apply the Agent Organization 26-tier prioritization framework to triage tasks, requests, and work items. Use when users need to prioritize work, evaluate requests against the prioritization matrix, determine accept/defer/reject decisions, or apply the Eisenhower matrix to task management. Make sure to use this skill whenever the user mentions prioritization, triage, task ranking, request evaluation, decision matrices, or needs to determine what work to focus on, even if they don't explicitly ask for "task triage."
version: 1.0.0
date:
  created: "2026-06-11"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags:
  - "ai/skill"
  - "prioritization"
  - "task-management"
  - "triage"
  - "agent-org"
  - "decision-matrix"
see-also:
  - template: "org-development"
    relationship: "related"
    description: "Organizational development skill defining the entity and department structure used for requestor adjustments"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies: []
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Task Triage

A skill for applying the Agent Organization Prioritization Framework to systematically evaluate and triage tasks, requests, and work items across Shared Services, Business Office, and Venture Studio contexts.

## Overview

The Agent Organization uses a three-dimensional prioritization framework:

1. **Work Type** — 26 tiers from Security Incidents (Tier 1) to Backlog (Tier 26)
2. **Requestor Priority** — Adjustments based on who is making the request (±3 tiers)
3. **Cost/Capacity** — Shared Services capacity constraints by effort level

This skill helps you apply this framework to make consistent, defensible prioritization decisions.

## When to Use This Skill

Use this skill when you need to:

- Evaluate a new request or task against the prioritization framework
- Determine whether to accept, defer, reject, or escalate work
- Apply the Eisenhower matrix (Urgent/Important) to task prioritization
- Calculate effective priority considering requestor and cost factors
- Resolve priority conflicts between competing requests
- Document prioritization decisions with clear rationale

## The 26-Tier Framework

The full 26-tier framework listing, requestor priority adjustment tables, cost/capacity constraints, decision matrix, cross-cutting adjustments, escalation rules, and Eisenhower matrix mapping are in `references/prioritization-framework.md`.

**Quick reference:**

- **Tiers 1-2**: Security incidents and critical system issues
- **Tiers 3-6**: Scheduled work and important maintenance
- **Tiers 7-10**: Client expansion, acquisition, and strategic investment
- **Tiers 11-25**: Backlog and low-priority work

**Key adjustments:**

- **Requestor**: Principal/CoS (+3), Critical Business (+2), Standard (0), Active Pod (-1), Experimental Pod (-3)
- **Cost**: Low (<2h), Medium (2-8h), High (8-40h), Very High (>40h)
- **Cross-cutting**: Regulatory deadlines (+5), litigation (+4), PR crises (+3), revenue at risk (+3), security (override to Tier 1)

## How to Triage a Request

### Step 1: Identify Base Tier

Match the request type to the 26-tier framework. Consider:

- What category of work is this? (Security, Client, Tech Debt, R&D, etc.)
- Is it urgent (time-sensitive) or important (strategic value)?
- What's the default Eisenhower quadrant?

### Step 2: Apply Cross-Cutting Adjustments

Check for additional priority modifiers:

- Legal/compliance factors? (+2 to +5 tiers)
- Reputational risk? (+1 to +3 tiers)
- Financial impact? (+0 to +3 tiers)
- Security implications? (Override to Tier 1)

### Step 3: Apply Requestor Adjustment

Who is making the request?

- Principal/CoS: +3 tiers (capped at Tier 1)
- Established Business (Critical): +2 tiers
- Established Business (Standard): No adjustment
- Venture Pod (Active): -1 tier
- Venture Pod (Experimental): -3 tiers

### Step 4: Calculate Effective Tier

Sum all adjustments (minimum Tier 1, maximum Tier 26):

```
Effective Tier = Base Tier + Cross-Cutting + Requestor
```

### Step 5: Estimate Cost

Estimate the effort required:

- Low Cost: < 2 hours
- Medium Cost: 2-8 hours
- High Cost: 8-40 hours
- Very High Cost: > 40 hours

### Step 6: Apply Decision Matrix

Cross-reference Effective Tier with Cost Level in the decision matrix to determine:

- **Auto-accept** — Proceed immediately
- **Accept** — Add to queue, proceed in order
- **Defer** — Hold for later, re-evaluate when capacity frees
- **Reject** — Decline, suggest alternative approach
- **Escalate to CoS** — Chief of Staff decision required

### Step 7: Document Decision

Record the triage decision with clear rationale:

- Base tier and reasoning
- All adjustments applied
- Cost estimate
- Final decision
- Next steps or alternatives

## Best Practices

1. **Be consistent** — Apply the framework uniformly across all requests
2. **Document rationale** — Clear decisions build trust and enable review
3. **Re-evaluate periodically** — Priorities change as context evolves
4. **Communicate clearly** — Explain decisions to requestors with reasoning
5. **Escalate appropriately** — Don't hesitate to involve CoS for ambiguous cases
6. **Consider capacity** — Shared Services has finite resources; use wisely
7. **Balance stability and agility** — Established businesses need governance; pods need speed

## Common Patterns

- **Security trumps all** — Any security incident is Tier 1, regardless of other factors
- **Principal requests get priority** — But still go through the framework for documentation
- **Venture pods pay in priority** — Experimental pods accept lower priority for autonomy
- **Cost limits high tiers** — Very expensive work requires high priority or escalation
- **Client relationships matter** — Critical client requests get +2 tier boost

---
## Context Declaration

### File Paths

- Main skill: `config/ai/skills/business/task-triage/SKILL.md`
- References: `config/ai/skills/business/task-triage/references/prioritization-framework.md`

### Related Skills

- org-development (related) — Organizational development skill defining the entity and department structure used for requestor adjustments
- base-ai-guidance (base-framework) — Shared framework for creating all AI guidance types

### Project Information

- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
