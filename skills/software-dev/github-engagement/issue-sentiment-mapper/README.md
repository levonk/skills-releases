# Issue Sentiment Mapper

## Overview

A read-only GitHub skill that fetches all comments on an issue or PR,
classifies each comment's stance relative to a user-specified position, and
outputs a summary with direct links to each classified comment for manual
review.

## What It Does

- Fetches all comments via `gh api repos/{owner}/{repo}/issues/{number}/comments --paginate`
- Classifies each comment as **PRO**, **ANTI**, **MIXED**, or **NEUTRAL** based on
  user-supplied pro-stance and anti-stance keywords
- Outputs a text summary (counts + bar chart + per-comment details) or
  structured JSON
- Every comment includes a deep-link URL (`#issuecomment-{id}`) for quick
  navigation

## Read-Only

This skill makes **only GET API calls**. It does not post reactions, comments,
or any mutations. Mass automated reactions were explicitly rejected for ToS
risk, brigading perception, account risk, and misuse potential. Review the
sentiment summary, then engage manually where your judgment warrants it.

## Usage

```bash
uv run --script scripts/map_sentiment.py.tmpl \
  --repo owner/repo \
  --number 123 \
  --stance "merge,approve,ship it" \
  --anti-stance "block,reject,concerns"

# JSON output
uv run --script scripts/map_sentiment.py.tmpl \
  --repo owner/repo \
  --number 123 \
  --stance "merge,approve" \
  --anti-stance "block,reject" \
  --json
```

## Classification Logic

| Condition | Classification |
|-----------|---------------|
| Pro keywords match, anti don't | PRO |
| Anti keywords match, pro don't | ANTI |
| Both match | MIXED |
| Neither match | NEUTRAL |

Keyword matching is case-insensitive substring matching. The logic is
intentionally simple and transparent — the user sees exactly which keywords
drove each classification and can adjust the keyword lists to refine results.

## Requirements

- `gh` CLI installed and authenticated (`gh auth login`)
- `uv` for running the Python script (`uv run --script`)

## See Also

- **issue-watcher** — companion skill for monitoring issue activity over time
- **github-issue** — creates new GitHub issues against upstream repos
- **github-pr** — creates pull requests against upstream repos
