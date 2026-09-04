<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Fetch all comments on a GitHub issue/PR, classify each as PRO/ANTI/MIXED/NEUTRAL relative to a user-specified stance, and output a summary with links to each classified comment for manual review. Read-only — no reactions, no mutations. Use when analyzing community sentiment on a GitHub issue, understanding where commenters stand on a topic, or preparing to engage manually with an issue's discussion. Triggers on 'sentiment analysis', 'issue sentiment', 'classify comments', 'who agrees with this issue', or 'community stance'. Do NOT trigger on mass reaction operations (rejected for ToS risk), general GitHub API questions, or issue creation (use github-issue skill).

## Metadata

| Field | Value |
|-------|-------|
| Name | `issue-sentiment-mapper` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `github`
- `sentiment-analysis`
- `issue-analysis`
- `community`
- `read-only`
- `classification`

## Quick Start

```bash
# Classify comments on an issue — pro-stance and anti-stance keywords
uv run --script scripts/map_sentiment.py.tmpl \
  --repo owner/repo \
  --number 123 \
  --stance "merge,ship it,looks good,approve" \
  --anti-stance "block,reject,concerns,bikeshedding"

# JSON output for programmatic consumption
uv run --script scripts/map_sentiment.py.tmpl \
  --repo owner/repo \
  --number 123 \
  --stance "merge,approve" \
  --anti-stance "block,reject" \
  --json
```

The script fetches all comments via `gh api`, classifies each by keyword
matching, and prints a summary with counts and per-comment details (author,
date, URL, snippet). Use the output to understand where the community stands
before engaging manually.

---
description: >-
  Reusable rate-limit awareness protocol for bulk API calls — spacing, header monitoring, backoff, and error classification. Inlined by any skill that makes multiple API calls in sequence
---

### API Rate-Limit Awareness

When a skill or script makes multiple API calls in sequence, uncontrolled
request rates trigger rate-limit errors and — worse — secondary rate-limit
bans that block the token for hours. This protocol keeps bulk operations
safe. It is guidance only: the patterns below are reference implementations
to inline or adapt, not a shipped runtime script.

#### When to apply this protocol

Apply this protocol when **any** of the following are true:

- Making more than 5 API calls in sequence to the same API
- Any paginated API call (`--paginate`, `page=1..N`)
- Any bulk mutation (reactions, subscriptions, labels, comments on multiple
  issues)

Do NOT apply it for single calls — one `gh issue create`, one `gh pr view`
needs no spacing, backoff, or header monitoring.

#### Default spacing

| Operation type | Default delay | Rationale |
|----------------|---------------|-----------|
| Read (GET/search) | 0.5s | Reads have higher limits; only needed for large pagination |
| Mutation (POST/PUT/DELETE) | 2s | Validated empirically — 0 failures with 2s delays on 11 subscriptions |
| Reaction (POST reaction) | 2s | Validated empirically — failures started at ~75 calls with no delay |
| After any 403/429 | Exponential: 1s → 2s → 4s → 8s → give up | Standard backoff |

#### Header monitoring

Check remaining quota after REST calls so you can slow down *before* a hard
limit, not after. GitHub exposes the standard headers; other APIs expose
similar headers (see the quick reference table below).

GitHub REST — inspect the rate-limit headers after a call:

```bash
gh api repos/$UPSTREAM_OWNER/$UPSTREAM_REPO/issues \
  --jq '.[0].number' \
  -i 2>/dev/null | grep -i '^x-ratelimit-'
# X-RateLimit-Limit: 5000
# X-RateLimit-Remaining: 4998
# X-RateLimit-Reset: 1700000000
```

GitHub GraphQL — query the `rateLimit` field directly:

```bash
gh api graphql -f query='{ rateLimit { remaining limit resetAt } }' \
  --jq '.data.rateLimit'
# {"remaining": 4998, "limit": 5000, "resetAt": "2023-11-14T12:00:00Z"}
```

Generic fallback — if the API exposes no headers, treat the operation as
opaque and rely on the default spacing table above. When `Remaining` drops
below 100 (or 2% of `Limit`), pause until `Reset`/`resetAt` before
continuing.

#### Error classification

| HTTP status | Response pattern | Classification | Action |
|-------------|------------------|----------------|--------|
| 200 | Success | OK | Continue |
| 403 | "rate limit" or "secondary rate limit" | RATE_LIMITED | Exponential backoff |
| 403 | "admin rights" or "Must have admin rights" | PERMISSION_ERROR | Do NOT retry — fix scopes or permissions |
| 403 | "locked" or "issue is locked" | RESOURCE_LOCKED | Do NOT retry — skip this item |
| 404 | "Not Found" | NOT_FOUND | Do NOT retry — check API path |
| 429 | Any | RATE_LIMITED (explicit) | Exponential backoff |
| 5xx | Any | SERVER_ERROR | Retry once after 5s, then give up |

Reference implementation — classify a response into one of the categories
above:

```python
def classify_error(status, message):
    """Map an HTTP status + response body to an error classification.

    Returns one of: OK, RATE_LIMITED, PERMISSION_ERROR,
    RESOURCE_LOCKED, NOT_FOUND, SERVER_ERROR, UNKNOWN.
    """
    if status == 200:
        return "OK"
    if status == 429:
        return "RATE_LIMITED"
    if status == 403:
        lower = (message or "").lower()
        if "rate limit" in lower or "secondary rate limit" in lower:
            return "RATE_LIMITED"
        if "admin rights" in lower or "must have admin rights" in lower:
            return "PERMISSION_ERROR"
        if "locked" in lower or "issue is locked" in lower:
            return "RESOURCE_LOCKED"
        return "UNKNOWN"
    if status == 404:
        return "NOT_FOUND"
    if 500 <= status < 600:
        return "SERVER_ERROR"
    return "UNKNOWN"
```

#### Bulk operation pattern (reference implementation)

A reference loop that spaces calls, classifies errors, backs off on rate
limits, skips non-retryable errors, and reports progress. Inline or adapt
this into the skill's own script — it is not shipped as a runtime include.

```python
import time

# Classifications that must NOT be retried — skip the item and move on.
NON_RETRYABLE = {"PERMISSION_ERROR", "RESOURCE_LOCKED", "NOT_FOUND"}

def bulk_api_call(items, api_fn, delay=2.0, max_retries=3):
    """Run api_fn(item) for each item with rate-limit-aware spacing.

    Args:
        items: iterable of items to process.
        api_fn: callable(item) -> (status, message, result). Must return
                an HTTP-like status code, a response message, and a result.
        delay: seconds to sleep between successful calls.
        max_retries: backoff attempts on RATE_LIMITED before giving up.

    Returns:
        dict with ok/fail/skipped counts and a per-item results list.
    """
    results = {"ok": 0, "fail": 0, "skipped": 0, "items": []}

    for i, item in enumerate(items, 1):
        attempt = 0
        backoff = 1.0
        outcome = None

        while attempt <= max_retries:
            status, message, result = api_fn(item)
            classification = classify_error(status, message)

            if classification == "OK":
                outcome = ("ok", result)
                results["ok"] += 1
                break

            if classification in NON_RETRYABLE:
                outcome = ("skipped", message)
                results["skipped"] += 1
                break

            if classification == "RATE_LIMITED":
                if attempt >= max_retries:
                    outcome = ("fail", f"rate-limited after {attempt} retries: {message}")
                    results["fail"] += 1
                    break
                time.sleep(backoff)
                backoff *= 2
                attempt += 1
                continue

            if classification == "SERVER_ERROR":
                if attempt >= 1:
                    outcome = ("fail", f"server error: {message}")
                    results["fail"] += 1
                    break
                time.sleep(5)
                attempt += 1
                continue

            # UNKNOWN — treat as a hard failure, do not retry blindly.
            outcome = ("fail", f"unclassified {status}: {message}")
            results["fail"] += 1
            break

        results["items"].append({"item": item, "outcome": outcome})

        if i % 10 == 0:
            print(f"Progress: {i} processed — ok={results['ok']} "
                  f"skipped={results['skipped']} fail={results['fail']}")

        if outcome and outcome[0] == "ok":
            time.sleep(delay)

    return results
```

#### API-specific quick reference

| API | Limit | Key headers | Notes |
|-----|-------|-------------|-------|
| GitHub REST | 5000/hr (authenticated) | `X-RateLimit-Remaining`, `X-RateLimit-Reset` | Secondary rate limit (~75 rapid mutations) is the real constraint |
| GitHub GraphQL | 5000 points/hr | `rateLimit { remaining limit resetAt }` | Query cost varies; mutations cost more |
| GitLab REST | 600/min (authenticated) | `RateLimit-Remaining`, `RateLimit-Reset` | Lower per-minute limit than GitHub |
| npm registry | 1000/5min (anonymous) | `X-RateLimit-Remaining` | Higher with auth token |
| PyPI JSON API | No documented limit | None | Be conservative — 1s delay |

#### When NOT to apply

- Single API calls (one `gh issue create`, one `gh pr view`)
- Local filesystem operations (no rate limit)
- Non-rate-limited APIs (rare — confirm via the API docs first)

## Related Skills
- **issue-watcher** (skill, complement) — Companion skill that watches issues for new comments and activity
- **github-issue** (skill, alternative) — Creates new GitHub issues against upstream repos — use this instead for issue creation
- **github-pr** (skill, alternative) — Creates pull requests against upstream repos — use this instead for PR creation
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/issue-sentiment-mapper/SKILL.md`](skills/software-dev/issue-sentiment-mapper/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-04T10:32:01Z
