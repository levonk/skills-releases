#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Issue Sentiment Mapper — classify GitHub issue/PR comments by stance.

Fetches all comments on a GitHub issue or PR via `gh api`, classifies each
comment as PRO/ANTI/MIXED/NEUTRAL relative to user-specified stance keywords,
and outputs a text summary or JSON with per-comment details.

Read-only: makes only GET API calls. No reactions, no comments, no mutations.

Usage:
    uv run --script map_sentiment.py.tmpl \\
        --repo owner/repo \\
        --number 123 \\
        --stance "merge,approve,ship it" \\
        --anti-stance "block,reject,concerns" \\
        [--json]
"""

import argparse
import json
import subprocess
import sys
import time
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Comment:
    """A single GitHub issue comment with its classification."""

    id: int
    author: str
    date: str
    body: str
    url: str
    classification: str
    matched_pro: list[str] = field(default_factory=list)
    matched_anti: list[str] = field(default_factory=list)

    @property
    def snippet(self) -> str:
        """Truncated comment body (100 chars, single-line)."""
        text = " ".join(self.body.split())
        if len(text) > 100:
            return text[:97] + "..."
        return text


def parse_keywords(raw: str) -> list[str]:
    """Parse comma-separated keywords into a clean list.

    Args:
        raw: Comma-separated string of keywords.

    Returns:
        List of lowercase, stripped keywords (empty strings removed).
    """
    return [k.strip().lower() for k in raw.split(",") if k.strip()]


def classify_comment(
    body: str,
    pro_keywords: list[str],
    anti_keywords: list[str],
) -> tuple[str, list[str], list[str]]:
    """Classify a comment body by keyword presence.

    Args:
        body: The comment body text.
        pro_keywords: List of pro-stance keywords (lowercase).
        anti_keywords: List of anti-stance keywords (lowercase).

    Returns:
        Tuple of (classification, matched_pro, matched_anti) where
        classification is one of PRO/ANTI/MIXED/NEUTRAL.
    """
    body_lower = body.lower()
    matched_pro = [k for k in pro_keywords if k in body_lower]
    matched_anti = [k for k in anti_keywords if k in body_lower]

    has_pro = len(matched_pro) > 0
    has_anti = len(matched_anti) > 0

    if has_pro and has_anti:
        classification = "MIXED"
    elif has_pro:
        classification = "PRO"
    elif has_anti:
        classification = "ANTI"
    else:
        classification = "NEUTRAL"

    return classification, matched_pro, matched_anti


def fetch_comments(repo: str, number: int) -> list[dict]:
    """Fetch all comments on a GitHub issue/PR via gh api.

    Uses `gh api repos/{repo}/issues/{number}/comments --paginate` to follow
    Link headers. Inserts 0.5s between paginated reads for rate-limit spacing.

    Args:
        repo: Repository in owner/repo format.
        number: Issue or PR number.

    Returns:
        List of comment dicts from the GitHub API.

    Raises:
        SystemExit: On API errors (404, 410, 403, rate limit) with a clear
        message.
    """
    endpoint = "repos/{}/issues/{}/comments".format(repo, number)
    cmd = ["gh", "api", endpoint, "--paginate"]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired:
        print(
            "Error: gh api timed out after 120s while fetching comments "
            "from {}/{}".format(repo, number),
            file=sys.stderr,
        )
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: gh CLI not found. Install it from https://cli.github.com/ "
            "and authenticate with `gh auth login`.",
            file=sys.stderr,
        )
        sys.exit(1)

    if result.returncode != 0:
        stderr = result.stderr.strip()
        if "HTTP 404" in stderr or "not found" in stderr.lower():
            print(
                "Error: Issue {}#{} not found.".format(repo, number),
                file=sys.stderr,
            )
            sys.exit(1)
        if "HTTP 410" in stderr or "gone" in stderr.lower():
            print(
                "Error: Issue {}#{} has been deleted.".format(repo, number),
                file=sys.stderr,
            )
            sys.exit(1)
        if "HTTP 403" in stderr:
            if "locked" in stderr.lower():
                print(
                    "Error: Issue {}#{} is locked. Comments cannot be "
                    "fetched.".format(repo, number),
                    file=sys.stderr,
                )
                sys.exit(1)
            if "rate limit" in stderr.lower():
                print(
                    "Error: GitHub API rate limit exceeded. Wait for the "
                    "rate limit to reset and try again.",
                    file=sys.stderr,
                )
                sys.exit(1)
            print(
                "Error: GitHub API returned 403: {}".format(stderr),
                file=sys.stderr,
            )
            sys.exit(1)
        print(
            "Error: gh api failed (exit {}): {}".format(
                result.returncode, stderr
            ),
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        comments = json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        print(
            "Error: Failed to parse gh api JSON output: {}".format(exc),
            file=sys.stderr,
        )
        sys.exit(1)

    # Rate-limit spacing: 0.5s sleep after the paginated fetch completes.
    # The gh CLI --paginate flag issues sequential requests internally;
    # this sleep ensures we don't immediately burst another API call.
    time.sleep(0.5)

    return comments


def build_comment_url(repo: str, number: int, comment_id: int) -> str:
    """Build a deep-link URL to a specific comment.

    Args:
        repo: Repository in owner/repo format.
        number: Issue or PR number.
        comment_id: The comment ID from the GitHub API.

    Returns:
        URL in the format
        https://github.com/{repo}/issues/{number}#issuecomment-{comment_id}
    """
    return "https://github.com/{}/issues/{}#issuecomment-{}".format(
        repo, number, comment_id
    )


def process_comments(
    raw_comments: list[dict],
    repo: str,
    number: int,
    pro_keywords: list[str],
    anti_keywords: list[str],
) -> list[Comment]:
    """Classify all fetched comments.

    Args:
        raw_comments: List of comment dicts from the GitHub API.
        repo: Repository in owner/repo format.
        number: Issue or PR number.
        pro_keywords: List of pro-stance keywords (lowercase).
        anti_keywords: List of anti-stance keywords (lowercase).

    Returns:
        List of Comment dataclasses with classification applied.
    """
    results: list[Comment] = []
    for raw in raw_comments:
        comment_id = raw.get("id", 0)
        author = raw.get("user", {}).get("login", "unknown")
        date = raw.get("created_at", "unknown")
        body = raw.get("body", "")
        url = build_comment_url(repo, number, comment_id)

        classification, matched_pro, matched_anti = classify_comment(
            body, pro_keywords, anti_keywords
        )

        results.append(
            Comment(
                id=comment_id,
                author=author,
                date=date,
                body=body,
                url=url,
                classification=classification,
                matched_pro=matched_pro,
                matched_anti=matched_anti,
            )
        )
    return results


def render_bar(count: int, total: int, width: int = 20) -> str:
    """Render a simple Unicode bar chart segment.

    Args:
        count: The count for this category.
        total: The total across all categories.
        width: Maximum bar width in characters.

    Returns:
        A string of Unicode block characters proportional to count/total.
    """
    if total == 0:
        return ""
    filled = int((count / total) * width)
    return "\u2588" * filled


def output_text(
    comments: list[Comment],
    repo: str,
    number: int,
    pro_keywords: list[str],
    anti_keywords: list[str],
) -> None:
    """Print a text summary with counts and per-comment details.

    Args:
        comments: List of classified Comment dataclasses.
        repo: Repository in owner/repo format.
        number: Issue or PR number.
        pro_keywords: Pro-stance keywords used for classification.
        anti_keywords: Anti-stance keywords used for classification.
    """
    total = len(comments)
    counts = count_by_classification(comments)

    print("Issue Sentiment Summary: {}#{}".format(repo, number))
    print("=" * 40)
    print("Total comments: {}".format(total))
    print()
    print(
        "PRO:     {:>3}  {}".format(
            counts["PRO"], render_bar(counts["PRO"], total)
        )
    )
    print(
        "ANTI:    {:>3}  {}".format(
            counts["ANTI"], render_bar(counts["ANTI"], total)
        )
    )
    print(
        "MIXED:   {:>3}  {}".format(
            counts["MIXED"], render_bar(counts["MIXED"], total)
        )
    )
    print(
        "NEUTRAL: {:>3}  {}".format(
            counts["NEUTRAL"], render_bar(counts["NEUTRAL"], total)
        )
    )
    print()
    print(
        "Stance keywords:     {}".format(", ".join(pro_keywords))
    )
    print(
        "Anti-stance keywords: {}".format(", ".join(anti_keywords))
    )
    print()

    for label in ("PRO", "ANTI", "MIXED", "NEUTRAL"):
        subset = [c for c in comments if c.classification == label]
        print("--- {} ({}) ---".format(label, len(subset)))
        for i, c in enumerate(subset, 1):
            matched = []
            if c.matched_pro:
                matched.append("pro: " + ", ".join(c.matched_pro))
            if c.matched_anti:
                matched.append("anti: " + ", ".join(c.matched_anti))
            matched_str = " [" + "; ".join(matched) + "]" if matched else ""
            print(
                "{}. @{}  {}  {}{}".format(
                    i, c.author, c.date, c.url, matched_str
                )
            )
            print('   "{}"'.format(c.snippet))
        if subset:
            print()


def output_json(
    comments: list[Comment],
    repo: str,
    number: int,
    pro_keywords: list[str],
    anti_keywords: list[str],
) -> None:
    """Print a structured JSON summary.

    Args:
        comments: List of classified Comment dataclasses.
        repo: Repository in owner/repo format.
        number: Issue or PR number.
        pro_keywords: Pro-stance keywords used for classification.
        anti_keywords: Anti-stance keywords used for classification.
    """
    counts = count_by_classification(comments)
    output = {
        "repo": repo,
        "number": number,
        "total_comments": len(comments),
        "counts": counts,
        "stance_keywords": pro_keywords,
        "anti_stance_keywords": anti_keywords,
        "comments": [
            {
                "id": c.id,
                "author": c.author,
                "date": c.date,
                "url": c.url,
                "classification": c.classification,
                "matched_pro": c.matched_pro,
                "matched_anti": c.matched_anti,
                "snippet": c.snippet,
            }
            for c in comments
        ],
    }
    print(json.dumps(output, indent=2))


def count_by_classification(comments: list[Comment]) -> dict[str, int]:
    """Count comments in each classification category.

    Args:
        comments: List of classified Comment dataclasses.

    Returns:
        Dict with keys PRO, ANTI, MIXED, NEUTRAL and their counts.
    """
    counts = {"PRO": 0, "ANTI": 0, "MIXED": 0, "NEUTRAL": 0}
    for c in comments:
        if c.classification in counts:
            counts[c.classification] += 1
    return counts


def validate_repo(repo: str) -> bool:
    """Validate that repo is in owner/repo format.

    Args:
        repo: Repository string to validate.

    Returns:
        True if the format is valid (single slash, no empty parts).
    """
    parts = repo.split("/")
    return len(parts) == 2 and all(parts) and "/" not in parts[0]


def main() -> None:
    """Parse arguments, fetch comments, classify, and output summary."""
    parser = argparse.ArgumentParser(
        description="Classify GitHub issue/PR comments by stance (read-only)."
    )
    parser.add_argument(
        "--repo",
        required=True,
        help="Target repository in owner/repo format (e.g. microsoft/vscode)",
    )
    parser.add_argument(
        "--number",
        required=True,
        type=int,
        help="Issue or PR number to analyze",
    )
    parser.add_argument(
        "--stance",
        required=True,
        help='Comma-separated pro-stance keywords (e.g. "merge,approve")',
    )
    parser.add_argument(
        "--anti-stance",
        required=True,
        help='Comma-separated anti-stance keywords (e.g. "block,reject")',
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output structured JSON instead of text summary",
    )

    args = parser.parse_args()

    if not validate_repo(args.repo):
        print(
            "Error: --repo must be in owner/repo format (e.g. microsoft/vscode)",
            file=sys.stderr,
        )
        sys.exit(1)

    if args.number < 1:
        print(
            "Error: --number must be a positive integer",
            file=sys.stderr,
        )
        sys.exit(1)

    pro_keywords = parse_keywords(args.stance)
    anti_keywords = parse_keywords(args.anti_stance)

    if not pro_keywords:
        print(
            "Error: --stance must contain at least one non-empty keyword",
            file=sys.stderr,
        )
        sys.exit(1)

    if not anti_keywords:
        print(
            "Error: --anti-stance must contain at least one non-empty keyword",
            file=sys.stderr,
        )
        sys.exit(1)

    raw_comments = fetch_comments(args.repo, args.number)

    if not raw_comments:
        print(
            "No comments found on issue {}#{}".format(args.repo, args.number)
        )
        sys.exit(0)

    comments = process_comments(
        raw_comments,
        args.repo,
        args.number,
        pro_keywords,
        anti_keywords,
    )

    if args.json:
        output_json(
            comments, args.repo, args.number, pro_keywords, anti_keywords
        )
    else:
        output_text(
            comments, args.repo, args.number, pro_keywords, anti_keywords
        )


if __name__ == "__main__":
    main()
