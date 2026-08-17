# issue-watcher

Subscribe to a list of GitHub issues/PRs (or discover them by topic keyword),
then subscribe via the GitHub GraphQL API with rate-limit-aware delays.

## What it does

- **Mode 1 (explicit list)**: subscribe to specific issue/PR numbers in a repo
- **Mode 2 (keyword discovery)**: search for issues by keyword, present results
  for confirmation, then subscribe to the confirmed list
- **Unsubscribe**: use `--unsubscribe` to reverse the operation

## Requirements

- `gh` CLI installed and authenticated with the `notifications` scope
  (run `gh auth refresh -s notifications` if missing)
- `uv` for running the Python script (`uv run --script`)

## Usage

```bash
# Subscribe to specific issues
uv run --script ./scripts/watch_issues.py --repo owner/repo --numbers 1,2,3,42

# Discover and subscribe to issues about a topic
uv run --script ./scripts/watch_issues.py --repo owner/repo --search "feature-x" --state open

# Unsubscribe
uv run --script ./scripts/watch_issues.py --repo owner/repo --numbers 1,2,3 --unsubscribe
```

## How it works

1. Checks the `notifications` scope on your gh CLI token
2. Resolves issue numbers (explicit list or keyword search with confirmation)
3. Fetches GraphQL node IDs for each issue
4. Subscribes via the `updateSubscription` GraphQL mutation
5. Inserts a 2-second delay between each subscription (rate limit awareness)
6. Reports a summary: subscribed / skipped / failed counts

Already-subscribed items are skipped (not errors). Locked issues still accept
subscriptions (locking blocks comments, not subscriptions).

## See also

- **issue-sentiment-mapper** — identify which issues are worth watching before
  bulk-subscribing
- **github-issue** — file a new issue, then use issue-watcher to subscribe to
  related issues on the same topic
