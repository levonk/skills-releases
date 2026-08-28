# Scrum Update Format

Guidance for crafting the daily scrum update during Phase 6 of the
sign-off skill.

## Standard Format (Three Questions)

The classic scrum update answers three questions:

```
**Yesterday / Today:**
- Did: <accomplishment 1>
- Did: <accomplishment 2>
- Did: <accomplishment 3>

**Today / Next:**
- Next: <priority 1>
- Next: <priority 2>

**Blockers:**
- <blocker or "None">
```

## Format Variants

### Slack/Chat (concise)

```
Did: shipped auth flow, fixed 3 bugs in checkout, reviewed 2 PRs
Next: start payment retry logic, deploy staging
Blockers: need API key from ops team
```

### Email (structured)

```
Subject: Daily Update — YYYY-MM-DD

Accomplishments:
- Implemented user authentication (login, session, tests)
- Fixed checkout bugs (#123, #124, #127)
- Reviewed PRs #45, #46

Planned for tomorrow:
- Payment retry logic (ticket #130)
- Deploy to staging environment

Blockers:
- Need API key from ops team for payment gateway
```

### Standup (verbal, 60 seconds)

```
Yesterday I finished the auth flow and fixed three checkout bugs.
Today I'm starting on payment retry logic and pushing the staging deploy.
I'm blocked on the payment API key — need ops to provision it.
```

### Asynchronous (detailed)

```
## YYYY-MM-DD Update

### Completed
- [x] User authentication (3 commits: login, session management, tests)
- [x] Checkout bug fixes (#123 cart total, #124 promo code, #127 race condition)
- [x] PR reviews: #45 (auth refactor), #46 (test coverage)

### In Progress
- Payment retry logic — research done, implementation starts tomorrow

### Planned Tomorrow
- Payment retry logic implementation (ticket #130)
- Staging deployment (waiting on CI green)

### Blockers / Help Needed
- Payment gateway API key — need ops team to provision (@ops-team)
```

## Tone Guidance

- **Be specific**: "fixed cart total calculation bug" not "fixed a bug."
- **Be concise**: 3-5 bullets max for accomplishments. If you did more,
  group related items.
- **Be honest**: If the day was light, say so. "Light day — mostly
  meetings and reviews" is better than padding.
- **Link when possible**: Reference ticket numbers, PR numbers, commit
  hashes. This makes the update verifiable.
- **Match team culture**: If the team uses emoji, use emoji. If the team
  is formal, be formal. When unsure, default to concise and factual.

## What to Include

- Features shipped or implemented
- Bugs fixed (with ticket numbers)
- PRs reviewed or merged
- Tests written or fixed
- Documentation updated
- Meetings/decisions made
- Deployments or releases

## What NOT to Include

- Vague statements ("made progress on several things")
- Every single commit (group related commits into accomplishments)
- Personal commentary ("feeling good about today")
- Future intentions without specifics ("will work on stuff tomorrow")
