#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Bulk-subscribe (or unsubscribe) to GitHub issues/PRs via the GraphQL API.

Two modes:
  Mode 1 (explicit): --repo owner/repo --numbers 1,2,3
  Mode 2 (keyword):  --repo owner/repo --search "keyword" --state open

The script:
  1. Checks the 'notifications' scope on the gh CLI token
  2. Resolves issue numbers (search in keyword mode, present for confirmation)
  3. Fetches GraphQL node IDs via gh api
  4. Subscribes/unsubscribes via the updateSubscription GraphQL mutation
  5. Inserts a 2-second delay between each subscription (rate limit awareness)
  6. Handles already-subscribed items (skip, no error)
  7. Handles locked issues (subscriptions work on locked issues)
  8. Reports a summary: subscribed/skipped/failed counts

Usage:
  # Mode 1: explicit issue numbers
  uv run --script watch_issues.py --repo owner/repo --numbers 1,2,3,42

  # Mode 2: keyword discovery
  uv run --script watch_issues.py --repo owner/repo --search "feature-x" --state open

  # Unsubscribe instead
  uv run --script watch_issues.py --repo owner/repo --numbers 1,2,3 --unsubscribe
"""

import argparse
import subprocess
import sys
import time


SUBSCRIBE_MUTATION = """mutation Subscribe($id: ID!, $state: SubscriptionState!) {
  updateSubscription(input: {subscribableId: $id, state: $state}) {
    subscribable {
      ... on Issue { number title }
      ... on PullRequest { number title }
    }
  }
}"""


def run_gh(args, capture=True):
    """Run a gh CLI command and return the result."""
    cmd = ["gh"] + args
    return subprocess.run(
        cmd,
        capture_output=capture,
        text=capture,
    )


def check_notifications_scope():
    """Check that the 'notifications' scope is present on the gh CLI token.

    Returns True if present, False otherwise.
    """
    result = run_gh(["auth", "status"])
    output = (result.stdout or "") + (result.stderr or "")
    # gh auth status prints scopes to stderr in some versions, stdout in others
    if "notifications" in output:
        return True
    return False


def search_issues(repo, keyword, state):
    """Search for issues in a repo via gh search issues.

    Returns a list of (number, title, state) tuples.
    """
    args = ["search", "issues", "--repo", repo, keyword, "--state", state]
    result = run_gh(args)
    if result.returncode != 0:
        print(f"Error: gh search issues failed: {result.stderr}", file=sys.stderr)
        return []

    issues = []
    for line in (result.stdout or "").strip().splitlines():
        line = line.strip()
        if not line:
            continue
        # gh search issues output format: "NUMBER\tTITLE\tSTATE" (tab-separated)
        # or "NUMBER  TITLE  STATE" with padding in some versions
        parts = line.split("\t")
        if len(parts) >= 3:
            try:
                num = int(parts[0].strip())
            except ValueError:
                continue
            title = parts[1].strip()
            istate = parts[2].strip()
            issues.append((num, title, istate))
        else:
            # Fallback: try to parse the first token as a number
            tokens = line.split()
            if tokens:
                try:
                    num = int(tokens[0])
                    title = " ".join(tokens[1:])
                    issues.append((num, title, "unknown"))
                except ValueError:
                    continue
    return issues


def present_for_confirmation(issues):
    """Print discovered issues and wait for user confirmation.

    Returns the list of issue numbers the user confirmed, or None to abort.
    """
    if not issues:
        print("No issues found matching the search.")
        return None

    print("\nDiscovered issues:")
    print("-" * 60)
    for num, title, istate in issues:
        print(f"  #{num} [{istate}] {title}")
    print("-" * 60)
    print(f"\nTotal: {len(issues)} issue(s) found.")
    print("\nOptions:")
    print("  - Type 'all' to subscribe to all listed issues")
    print("  - Type a comma-separated list of numbers (e.g. 1,3,5) to select")
    print("  - Type 'no' to abort")

    choice = input("\nConfirm subscription target: ").strip().lower()
    if choice == "no" or choice == "n":
        print("Aborted by user.")
        return None
    if choice == "all" or choice == "a":
        return [num for num, _, _ in issues]

    # Parse comma-separated numbers
    try:
        selected = [int(x.strip()) for x in choice.split(",") if x.strip()]
    except ValueError:
        print("Error: invalid input. Expected numbers or 'all'.", file=sys.stderr)
        return None

    # Validate against discovered issues
    discovered_nums = {num for num, _, _ in issues}
    valid = [n for n in selected if n in discovered_nums]
    invalid = [n for n in selected if n not in discovered_nums]
    if invalid:
        print(f"Warning: numbers not in search results, ignoring: {invalid}")
    if not valid:
        print("No valid issues selected. Aborting.")
        return None
    return valid


def fetch_node_id(repo, number):
    """Fetch the GraphQL node ID for an issue/PR via the REST API.

    Returns the node_id string, or None on failure.
    """
    result = run_gh([
        "api", f"repos/{repo}/issues/{number}", "--jq", ".node_id",
    ])
    if result.returncode != 0:
        print(f"Error fetching node_id for #{number}: {result.stderr}", file=sys.stderr)
        return None
    node_id = (result.stdout or "").strip()
    if not node_id:
        print(f"Error: empty node_id for #{number}", file=sys.stderr)
        return None
    return node_id


def subscribe(node_id, number, state):
    """Subscribe or unsubscribe via the GraphQL updateSubscription mutation.

    Returns "subscribed", "skipped", or "failed".
    """
    result = run_gh([
        "api", "graphql",
        "-f", "query=" + SUBSCRIBE_MUTATION,
        "-F", f"id={node_id}",
        "-f", f"state={state}",
    ])
    if result.returncode != 0:
        stderr = (result.stderr or "").lower()
        # Already subscribed/unsubscribed — GitHub returns success, but
        # some edge cases may surface as errors. Treat gracefully.
        if "already" in stderr:
            return "skipped"
        print(f"Error subscribing to #{number}: {result.stderr}", file=sys.stderr)
        return "failed"

    # Check for GraphQL errors in the response body
    stdout = (result.stdout or "").strip()
    if '"errors"' in stdout:
        # Parse minimal error detection without json module dependency
        if "already" in stdout.lower():
            return "skipped"
        print(f"GraphQL error for #{number}: {stdout}", file=sys.stderr)
        return "failed"

    return "subscribed"


def main():
    parser = argparse.ArgumentParser(
        description="Bulk-subscribe to GitHub issues/PRs via the GraphQL API",
    )
    parser.add_argument(
        "--repo", required=True,
        help="Target repository in owner/repo format",
    )
    parser.add_argument(
        "--numbers",
        help="Comma-separated issue/PR numbers (Mode 1: explicit list)",
    )
    parser.add_argument(
        "--search",
        help="Keyword to search for in issues (Mode 2: keyword discovery)",
    )
    parser.add_argument(
        "--state", default="all",
        choices=["open", "closed", "all"],
        help="Issue state filter for keyword search (default: all)",
    )
    parser.add_argument(
        "--unsubscribe", action="store_true",
        help="Unsubscribe instead of subscribe",
    )
    args = parser.parse_args()

    # Validate mode
    if not args.numbers and not args.search:
        parser.error("Provide either --numbers (Mode 1) or --search (Mode 2)")
    if args.numbers and args.search:
        parser.error("Use either --numbers or --search, not both")

    # Step 1: Check notifications scope
    print("Step 1: Checking 'notifications' scope on gh CLI token...")
    if not check_notifications_scope():
        print("\nMissing 'notifications' scope. The updateSubscription mutation")
        print("requires this scope. Run:")
        print("  gh auth refresh -s notifications")
        sys.exit(1)
    print("  notifications scope present.")

    # Determine subscription state
    sub_state = "UNSUBSCRIBED" if args.unsubscribe else "SUBSCRIBED"
    action_verb = "Unsubscribing from" if args.unsubscribe else "Subscribing to"

    # Step 2: Resolve issue numbers
    print("\nStep 2: Resolving issue numbers...")
    if args.numbers:
        # Mode 1: explicit list
        try:
            issue_numbers = [int(n.strip()) for n in args.numbers.split(",") if n.strip()]
        except ValueError:
            print(f"Error: invalid --numbers value: {args.numbers}", file=sys.stderr)
            sys.exit(1)
        if not issue_numbers:
            print("Error: no valid issue numbers provided.", file=sys.stderr)
            sys.exit(1)
        print(f"  Mode 1 (explicit): {len(issue_numbers)} issue(s): {issue_numbers}")
    else:
        # Mode 2: keyword discovery
        print(f"  Mode 2 (keyword): searching '{args.search}' in {args.repo} (state: {args.state})")
        issues = search_issues(args.repo, args.search, args.state)
        if not issues:
            print("  No issues found. Exiting.")
            sys.exit(0)

        # Step 3: Present for user confirmation
        print("\nStep 3: Presenting discovered issues for confirmation...")
        issue_numbers = present_for_confirmation(issues)
        if not issue_numbers:
            sys.exit(0)
        print(f"  Confirmed: {len(issue_numbers)} issue(s): {issue_numbers}")

    # Step 4: Fetch GraphQL node IDs
    print(f"\nStep 4: Fetching GraphQL node IDs for {len(issue_numbers)} issue(s)...")
    node_ids = {}
    failed_fetch = []
    for num in issue_numbers:
        node_id = fetch_node_id(args.repo, num)
        if node_id:
            node_ids[num] = node_id
            print(f"  #{num}: node_id fetched")
        else:
            failed_fetch.append(num)
            print(f"  #{num}: FAILED to fetch node_id")

    if not node_ids:
        print("\nError: no node IDs could be fetched. Exiting.", file=sys.stderr)
        sys.exit(1)

    # Step 5: Subscribe/unsubscribe with 2-second delays
    print(f"\nStep 5: {action_verb} {len(node_ids)} issue(s) with 2-second delays...")
    subscribed = 0
    skipped = 0
    failed = 0
    failed_items = []

    for i, (num, node_id) in enumerate(node_ids.items()):
        result = subscribe(node_id, num, sub_state)
        if result == "subscribed":
            subscribed += 1
            print(f"  [{i+1}/{len(node_ids)}] #{num}: {result}")
        elif result == "skipped":
            skipped += 1
            print(f"  [{i+1}/{len(node_ids)}] #{num}: skipped (already in desired state)")
        else:
            failed += 1
            failed_items.append(num)
            print(f"  [{i+1}/{len(node_ids)}] #{num}: FAILED")

        # 2-second delay between subscriptions (rate limit awareness)
        # Skip delay after the last item
        if i < len(node_ids) - 1:
            time.sleep(2)

    # Step 6: Report summary
    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"  Repository: {args.repo}")
    print(f"  Action:     {action_verb}")
    print(f"  Subscribed: {subscribed}")
    print(f"  Skipped:    {skipped} (already in desired state)")
    print(f"  Failed:     {failed}")
    if failed_fetch:
        print(f"  Node ID fetch failures: {failed_fetch}")
    if failed_items:
        print(f"  Failed items: #{', #'.join(str(n) for n in failed_items)}")
    print("=" * 60)

    if failed > 0 or failed_fetch:
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
