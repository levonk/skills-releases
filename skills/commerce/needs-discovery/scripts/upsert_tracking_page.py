#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
upsert_tracking_page.py — Create or update a shopping tracking page.

Tracking pages live under ${XDG_DATA_HOME:-$HOME/.local/share}/shopping/
as one markdown file per item being researched or monitored.

Usage:
    # Create or update a tracking page
    uv run --script scripts/upsert_tracking_page.py \\
        --item "NVIDIA DGX Spark 128GB" \\
        --budget 3000 \\
        --status researching

    # Add a source row (pipe-delimited: Source|URL|Price|Condition|Status)
    uv run --script scripts/upsert_tracking_page.py \\
        --item "NVIDIA DGX Spark 128GB" \\
        --add-source "Amazon|https://www.amazon.com/dp/B0XXX|3199|New|verified"

    # Set price thresholds
    uv run --script scripts/upsert_tracking_page.py \\
        --item "NVIDIA DGX Spark 128GB" \\
        --buy-now-threshold 2800 \\
        --alert-threshold 3000

    # Add a must-have feature
    uv run --script scripts/upsert_tracking_page.py \\
        --item "NVIDIA DGX Spark 128GB" \\
        --must-have "128GB unified memory" \\
        --must-have "Thunderbolt 5"

    # Update status only
    uv run --script scripts/upsert_tracking_page.py \\
        --item "NVIDIA DGX Spark 128GB" \\
        --status purchased

The script is idempotent — running it twice with the same args produces the
same file. Source rows are deduplicated by URL. Feature lists are deduplicated
by text.
"""

import argparse
import os
import re
import sys
from datetime import date
from pathlib import Path


def slugify(name: str) -> str:
    """Convert an item name to a URL-safe slug."""
    slug = name.lower().strip()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = slug.strip("-")
    return slug or "item"


def tracking_dir() -> Path:
    """Resolve the shopping tracking directory."""
    base = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
    return Path(base) / "shopping"


def tracking_path(item: str) -> Path:
    """Resolve the tracking page path for an item."""
    return tracking_dir() / f"{slugify(item)}.md"


def parse_frontmatter(content: str) -> tuple[dict[str, str], str]:
    """Split a markdown file into frontmatter dict and body."""
    if not content.startswith("---\n"):
        return {}, content
    end = content.find("\n---\n", 4)
    if end == -1:
        return {}, content
    fm_block = content[4:end]
    body = content[end + 5 :]
    fm = {}
    for line in fm_block.splitlines():
        if ":" in line:
            key, _, val = line.partition(":")
            fm[key.strip()] = val.strip().strip('"').strip("'")
    return fm, body


def serialize_frontmatter(fm: dict[str, str]) -> str:
    """Serialize a frontmatter dict back to YAML-ish text."""
    lines = ["---"]
    for key in ["item", "slug", "created", "last-updated", "status"]:
        if key in fm:
            val = fm[key]
            lines.append(f'{key}: "{val}"')
    # Any extra keys
    for key, val in fm.items():
        if key not in ["item", "slug", "created", "last-updated", "status"]:
            lines.append(f'{key}: "{val}"')
    lines.append("---")
    return "\n".join(lines)


def today() -> str:
    return date.today().isoformat()


def create_new_page(args: argparse.Namespace) -> str:
    """Generate a new tracking page from scratch."""
    slug = slugify(args.item)
    status = args.status or "researching"
    fm = {
        "item": args.item,
        "slug": slug,
        "created": today(),
        "last-updated": today(),
        "status": status,
    }

    budget_line = f"- **Budget / target price**: ${args.budget}" if args.budget else "- **Budget / target price**: (not set)"
    must_haves = "\n".join(f"- {f}" for f in (args.must_have or [])) or "- (none specified)"
    nice_haves = "\n".join(f"- {f}" for f in (args.nice_to_have or [])) or "- (none specified)"
    timeline = "- **Timeline**: (not set)"

    body = f"""# {args.item}

## Target

{budget_line}
- **Must-have features**:
{must_haves}
- **Nice-to-have features**:
{nice_haves}
- **Specs** (each tagged `min:` or `ceiling:`):
  - (none specified)
{timeline}

## Sources

| # | Source | URL | Price | Condition | Date Checked | Status |
|---|--------|-----|-------|-----------|-------------|--------|

## Price History

| Date | Source | Price | Notes |
|------|--------|-------|-------|

## Target Discount / Price Thresholds

- **Buy-now threshold**: {f"${args.buy_now_threshold}" if args.buy_now_threshold else "(not set)"}
- **Alert threshold**: {f"${args.alert_threshold}" if args.alert_threshold else "(not set)"}
- **Historical low**: (not set)
- **Target discount %**: (not set)

## Timing

- **Best purchase window**: (not determined)
- **Next expected sale**: (not determined)
- **Price trend**: (not determined)

## Qualifying Features Checklist

"""
    for f in (args.must_have or []):
        body += f"- [ ] {f} (required)\n"
    if not args.must_have:
        body += "- (none specified)\n"

    body += """
## Notes

- (none)
"""

    return serialize_frontmatter(fm) + "\n" + body


def add_source_row(body: str, source_str: str) -> str:
    """Add a source row to the Sources table. Dedup by URL."""
    parts = source_str.split("|")
    if len(parts) < 5:
        sys.stderr.write(f"ERROR: --add-source needs 5 pipe-delimited fields: Source|URL|Price|Condition|Status\n")
        sys.stderr.write(f"  got: {source_str}\n")
        return body
    source, url, price, condition, status = (p.strip() for p in parts[:5])
    date_checked = today()

    # Check if URL already exists in the table
    if url in body:
        # Update the existing row
        lines = body.splitlines()
        for i, line in enumerate(lines):
            if url in line and line.startswith("|"):
                # Replace the row
                lines[i] = f"| ~ | {source} | {url} | {price} | {condition} | {date_checked} | {status} |"
                # Renumber
                return renumber_source_rows("\n".join(lines))
        # URL found but not in a table row — append
    # Append new row
    return append_table_row(body, "## Sources", f"| ~ | {source} | {url} | {price} | {condition} | {date_checked} | {status} |")


def renumber_source_rows(body: str) -> str:
    """Renumber the # column in the Sources table."""
    lines = body.splitlines()
    in_sources = False
    count = 0
    for i, line in enumerate(lines):
        if line.startswith("## Sources"):
            in_sources = True
            continue
        if in_sources and line.startswith("## "):
            in_sources = False
        if in_sources and line.startswith("|") and not line.startswith("| #") and not line.startswith("|---"):
            count += 1
            # Replace first cell
            parts = line.split("|")
            if len(parts) >= 3:
                parts[1] = f" {count} "
                lines[i] = "|".join(parts)
    return "\n".join(lines)


def append_table_row(body: str, section_header: str, row: str) -> str:
    """Append a row to the table under a section header."""
    lines = body.splitlines()
    section_start = None
    for i, line in enumerate(lines):
        if line.strip() == section_header:
            section_start = i
            break
    if section_start is None:
        # Section not found — append at end
        return body.rstrip() + f"\n\n{section_header}\n\n| # | Source | URL | Price | Condition | Date Checked | Status |\n|---|--------|-----|-------|-----------|-------------|--------|\n{row}\n"

    # Find the table (skip header + separator, find last table row)
    insert_at = section_start + 1
    # Skip blank lines
    while insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1
    # Skip table header row
    if insert_at < len(lines) and lines[insert_at].startswith("|"):
        insert_at += 1
    # Skip separator row
    if insert_at < len(lines) and lines[insert_at].startswith("|---"):
        insert_at += 1
    # Find last table row
    last_row = insert_at - 1
    while insert_at < len(lines) and lines[insert_at].startswith("|"):
        last_row = insert_at
        insert_at += 1
    # Insert after last row
    lines.insert(last_row + 1, row)
    result = "\n".join(lines)
    return renumber_source_rows(result)


def update_thresholds(body: str, args: argparse.Namespace) -> str:
    """Update price threshold lines."""
    lines = body.splitlines()
    for i, line in enumerate(lines):
        if args.buy_now_threshold is not None and "Buy-now threshold" in line:
            lines[i] = f"- **Buy-now threshold**: ${args.buy_now_threshold}"
        elif args.alert_threshold is not None and "Alert threshold" in line:
            lines[i] = f"- **Alert threshold**: ${args.alert_threshold}"
    return "\n".join(lines)


def update_features(body: str, args: argparse.Namespace) -> str:
    """Add must-have and nice-to-have features, and checklist items."""
    lines = body.splitlines()

    # Update must-have list
    if args.must_have:
        for i, line in enumerate(lines):
            if line.strip() == "- **Must-have features**:":
                # Collect existing
                existing = set()
                j = i + 1
                while j < len(lines) and lines[j].startswith("- "):
                    existing.add(lines[j].strip("- ").strip())
                    j += 1
                # Add new
                for feat in args.must_have:
                    if feat not in existing:
                        lines.insert(j, f"- {feat}")
                        existing.add(feat)
                        j += 1
                # Also add to checklist
                for k, line2 in enumerate(lines):
                    if "## Qualifying Features Checklist" in line2:
                        # Find end of checklist
                        m = k + 1
                        existing_checks = set()
                        while m < len(lines) and lines[m].startswith("- [ ]"):
                            existing_checks.add(lines[m].replace("- [ ]", "").replace("(required)", "").strip())
                            m += 1
                        for feat in args.must_have:
                            if feat not in existing_checks:
                                lines.insert(m, f"- [ ] {feat} (required)")
                                existing_checks.add(feat)
                                m += 1
                break

    # Update nice-to-have list
    if args.nice_to_have:
        for i, line in enumerate(lines):
            if line.strip() == "- **Nice-to-have features**:":
                existing = set()
                j = i + 1
                while j < len(lines) and lines[j].startswith("- "):
                    existing.add(lines[j].strip("- ").strip())
                    j += 1
                for feat in args.nice_to_have:
                    if feat not in existing:
                        lines.insert(j, f"- {feat}")
                        existing.add(feat)
                        j += 1
                break

    return "\n".join(lines)


def update_budget(body: str, budget: float) -> str:
    """Update the budget line."""
    lines = body.splitlines()
    for i, line in enumerate(lines):
        if "Budget / target price" in line:
            lines[i] = f"- **Budget / target price**: ${budget}"
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Create or update a shopping tracking page."
    )
    parser.add_argument("--item", required=True, help="Item name (used for slug and title)")
    parser.add_argument("--budget", type=float, default=None, help="Target budget/price")
    parser.add_argument("--status", default=None,
                        choices=["researching", "monitoring", "ready-to-buy", "purchased", "abandoned"],
                        help="Pipeline status")
    parser.add_argument("--add-source", default=None,
                        help="Source row: Source|URL|Price|Condition|Status")
    parser.add_argument("--buy-now-threshold", type=float, default=None,
                        help="Auto-buy price threshold")
    parser.add_argument("--alert-threshold", type=float, default=None,
                        help="Price alert threshold")
    parser.add_argument("--must-have", action="append", default=None,
                        help="Must-have feature (repeatable)")
    parser.add_argument("--nice-to-have", action="append", default=None,
                        help="Nice-to-have feature (repeatable)")
    parser.add_argument("--note", default=None, help="Append a note to the Notes section")

    args = parser.parse_args()

    page_path = tracking_path(args.item)
    page_path.parent.mkdir(parents=True, exist_ok=True)

    if page_path.exists():
        content = page_path.read_text()
        fm, body = parse_frontmatter(content)
        fm["last-updated"] = today()
        if args.status:
            fm["status"] = args.status

        if args.add_source:
            body = add_source_row(body, args.add_source)
        if args.buy_now_threshold is not None or args.alert_threshold is not None:
            body = update_thresholds(body, args)
        if args.must_have or args.nice_to_have:
            body = update_features(body, args)
        if args.budget is not None:
            body = update_budget(body, args.budget)
        if args.note:
            body = body.rstrip() + f"\n- {args.note}\n"

        page_path.write_text(serialize_frontmatter(fm) + "\n" + body)
        print(f"Updated: {page_path}")
    else:
        content = create_new_page(args)
        if args.add_source:
            fm, body = parse_frontmatter(content)
            body = add_source_row(body, args.add_source)
            content = serialize_frontmatter(fm) + "\n" + body
        if args.note:
            content = content.rstrip() + f"\n- {args.note}\n"
        page_path.write_text(content)
        print(f"Created: {page_path}")

    return 0


if __name__ == "__main__":
    sys.exit(main())

