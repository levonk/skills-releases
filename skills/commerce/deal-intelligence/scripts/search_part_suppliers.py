#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31",
#     "beautifulsoup4>=4.12",
# ]
# ///
"""
Search parts suppliers by OEM part number. Searches eBay, Google Shopping,
Partsouq, and RockAuto for any part number.

Searching by OEM part number avoids the "convenience tax" — model-name
searches surface pre-packaged repair kits at 30–150% markup; part-number
searches surface the raw OEM component from multiple suppliers at a
fraction of the cost.

Usage:
    # Search a single part number across all suppliers
    uv run --script scripts/search_part_suppliers.py --part-number 1A100-77040

    # Search multiple part numbers (comma-separated)
    uv run --script scripts/search_part_suppliers.py --part-numbers "1A100-77040,77A10-62081"

    # Search part numbers from a file (one per line)
    uv run --script scripts/search_part_suppliers.py --part-numbers-file part-numbers.txt

    # JSON output for piping into a monitor
    uv run --script scripts/search_part_suppliers.py --part-number 1A100-77040 --json

    # Dry run — show which suppliers would be searched
    uv run --script scripts/search_part_suppliers.py --part-number 1A100-77040 --dry-run

Outputs text table by default, JSON with --json.
"""

import argparse
import json
import sys
import time
from dataclasses import asdict, dataclass
from typing import Any
from urllib.parse import quote_plus

try:
    import requests
except ImportError:
    requests = None  # type: ignore[assignment]

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None  # type: ignore[assignment]


# --- Supplier search configurations ---

SUPPLIERS: list[dict[str, str]] = [
    {
        "name": "eBay",
        "search_url": "https://www.ebay.com/sch/i.html?_nkw={query}&_sop=15",  # sort by price+shipping lowest
        "parse": "ebay",
    },
    {
        "name": "Google Shopping",
        "search_url": "https://www.google.com/search?q={query}&tbm=shop",
        "parse": "google_shopping",
    },
    {
        "name": "Partsouq",
        "search_url": "https://www.partsouq.com/parts?q={query}",
        "parse": "generic",
    },
    {
        "name": "RockAuto",
        "search_url": "https://www.rockauto.com/en/search/?partsearch={query}",
        "parse": "generic",
    },
]

REQUEST_DELAY = 2.0  # seconds between supplier requests — be polite
REQUEST_TIMEOUT = 30
USER_AGENT = "Mozilla/5.0 (compatible; auto-parts-sourcing/1.0)"


@dataclass
class SupplierMatch:
    part_number: str
    supplier: str
    title: str = ""
    price: str = ""
    condition: str = ""
    url: str = ""


def search_supplier(supplier: dict[str, str], part_number: str) -> list[SupplierMatch]:
    """Search a single supplier for a part number."""
    if requests is None:
        print("ERROR: requests not installed. Run: uv pip install requests", file=sys.stderr)
        return []

    # Search with quoted part number for exact match
    query = quote_plus(f'"{part_number}"')
    url = supplier["search_url"].format(query=query)

    try:
        resp = requests.get(url, timeout=REQUEST_TIMEOUT, headers={"User-Agent": USER_AGENT})
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"WARN: {supplier['name']} search failed for {part_number}: {e}", file=sys.stderr)
        return []

    matches: list[SupplierMatch] = []
    if BeautifulSoup is None:
        print("ERROR: beautifulsoup4 not installed. Run: uv pip install beautifulsoup4", file=sys.stderr)
        return matches

    soup = BeautifulSoup(resp.text, "html.parser")

    # Generic parsing — look for elements that contain the part number and a price
    # This is a best-effort parse; supplier page structures vary and change.
    # The script surfaces candidate listings for the AI to verify.
    price_elements = soup.find_all(string=lambda t: t and "$" in t and any(c.isdigit() for c in t))

    seen_titles: set[str] = set()
    for pe in price_elements[:10]:  # limit to first 10 price-adjacent elements
        parent = pe.parent
        if parent is None:
            continue
        # Walk up to find a container with a title/link
        container = parent
        for _ in range(5):
            if container is None:
                break
            link = container.find("a", href=True)
            title_elem = container.find(["h3", "h4", "span", "div"], class_=lambda c: c and any(
                kw in str(c).lower() for kw in ["title", "name", "item", "product"]
            ))
            if link or title_elem:
                break
            container = container.parent

        title = ""
        url_found = ""
        if title_elem:
            title = title_elem.get_text(strip=True)
        elif link:
            title = link.get_text(strip=True)
        if link:
            url_found = link.get("href", "")

        if title and title not in seen_titles:
            seen_titles.add(title)
            matches.append(SupplierMatch(
                part_number=part_number,
                supplier=supplier["name"],
                title=title,
                price=pe.strip() if pe else "",
                url=url_found,
            ))

    return matches


def search_all_suppliers(
    part_numbers: list[str],
    dry_run: bool = False,
) -> list[SupplierMatch]:
    """Search all suppliers for all given part numbers."""
    if dry_run:
        print(f"DRY RUN — would search {len(SUPPLIERS)} suppliers for {len(part_numbers)} part number(s):", file=sys.stderr)
        for s in SUPPLIERS:
            print(f"  Supplier: {s['name']}", file=sys.stderr)
        for pn in part_numbers:
            print(f"    Part: {pn}", file=sys.stderr)
        return []

    all_matches: list[SupplierMatch] = []
    for part_number in part_numbers:
        print(f"Searching for {part_number}...", file=sys.stderr)
        for supplier in SUPPLIERS:
            matches = search_supplier(supplier, part_number)
            all_matches.extend(matches)
            time.sleep(REQUEST_DELAY)

    return all_matches


def output_text(matches: list[SupplierMatch]) -> None:
    """Print matches as a text table."""
    if not matches:
        print("No supplier matches found for any part number.")
        print("Run again weekly — new listings appear on eBay and parts sites.")
        return

    print(f"# Part Number Supplier Matches — {len(matches)} found\n")
    print(f"{'Part Number':<18} {'Supplier':<16} {'Price':<10} {'Title':<60}")
    print("-" * 110)
    for m in matches:
        print(f"{m.part_number:<18} {m.supplier:<16} {m.price:<10} {m.title[:60]:<60}")
    print()
    print("Verify each listing — supplier page structures vary and parsing is best-effort.")
    print("Search the part number directly on each supplier's site for the most current results.")


def output_json(matches: list[SupplierMatch]) -> None:
    """Print matches as JSON."""
    print(json.dumps([asdict(m) for m in matches], indent=2))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Search parts suppliers by OEM part number."
    )
    parser.add_argument("--part-number", help="Single part number to search")
    parser.add_argument("--part-numbers", help="Comma-separated list of part numbers")
    parser.add_argument("--part-numbers-file", help="File containing part numbers (one per line)")
    parser.add_argument("--dry-run", action="store_true", help="Show which suppliers would be searched without fetching")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of text table")
    args = parser.parse_args()

    # Collect part numbers from the various input methods
    part_numbers: list[str] = []
    if args.part_number:
        part_numbers.append(args.part_number)
    if args.part_numbers:
        part_numbers.extend(pn.strip() for pn in args.part_numbers.split(","))
    if args.part_numbers_file:
        with open(args.part_numbers_file) as f:
            part_numbers.extend(line.strip() for line in f if line.strip() and not line.startswith("#"))

    if not part_numbers:
        parser.error("At least one part number is required (--part-number, --part-numbers, or --part-numbers-file)")

    matches = search_all_suppliers(
        part_numbers=part_numbers,
        dry_run=args.dry_run,
    )

    if args.json:
        output_json(matches)
    else:
        output_text(matches)

    return 0


if __name__ == "__main__":
    sys.exit(main())
