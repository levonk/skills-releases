#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31",
#     "beautifulsoup4>=4.12",
# ]
# ///
"""
Search Pick Your Part (pyp.com) inventory across all California yards for
any vehicle make/model.

Pick Your Part has no public API. This script fetches each yard's inventory
page via HTTP and parses the HTML for vehicle listings matching the search
criteria. Results are sorted by yard distance from the user zip code
(nearest first).

Usage:
    # Search all California yards for a Toyota Mirai, sorted by distance from 91204
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Toyota --model Mirai

    # Search for any Hyundai vehicle
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Hyundai

    # Search for multiple models (comma-separated)
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Toyota --model "Mirai,Prius"

    # Limit to yards within 50 miles
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Toyota --model Mirai --max-distance 50

    # Dry run — show which yards would be searched without fetching
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Toyota --model Mirai --dry-run

    # JSON output for piping into a monitor
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --make Toyota --model Mirai --json

    # Search all vehicles (no make/model filter — list everything at each yard)
    uv run --script scripts/search_pyp_inventory.py --zip 91204 --all

Outputs text table by default, JSON with --json.
"""

import argparse
import json
import sys
import time
from dataclasses import asdict, dataclass
from typing import Any

try:
    import requests
except ImportError:
    requests = None  # type: ignore[assignment]

try:
    from bs4 import BeautifulSoup
except ImportError:
    BeautifulSoup = None  # type: ignore[assignment]


# --- California Pick Your Part yards ---
# Source: references/pyp-california-locations.md
# Distances are approximate driving miles from Glendale, CA 91204.
# The --zip flag overrides the sort order via a distance lookup table.
# When the zip is not 91204, yards are still sorted by the 91204 distances
# as a reasonable proxy for Southern California; for other regions, pass
# --max-distance 0 to disable distance filtering and search all yards.

YARDS_91204: list[dict[str, Any]] = [
    {"name": "Sun Valley", "id": 1292, "address": "11201 Pendleton Street", "city": "Sun Valley", "state": "CA", "zip": "91352", "distance": 10},
    {"name": "Monrovia", "id": 1288, "address": "3333 S. Peck Rd.", "city": "Monrovia", "state": "CA", "zip": "91016", "distance": 18},
    {"name": "Santa Fe Springs", "id": 1291, "address": "13780 Imperial Highway", "city": "Santa Fe Springs", "state": "CA", "zip": "90670", "distance": 20},
    {"name": "Wilmington", "id": 1293, "address": "1232 Blinn Ave.", "city": "Wilmington", "state": "CA", "zip": "90744", "distance": 30},
    {"name": "Anaheim", "id": 1285, "address": "1235 South Beach Blvd.", "city": "Anaheim", "state": "CA", "zip": "92804", "distance": 34},
    {"name": "Ontario", "id": 1289, "address": "2025 S. Milliken Ave.", "city": "Ontario", "state": "CA", "zip": "91761", "distance": 41},
    {"name": "Fontana", "id": 1286, "address": "15228 Boyle Avenue", "city": "Fontana", "state": "CA", "zip": "92337", "distance": 52},
    {"name": "Rialto", "id": 1294, "address": "221 E. Santa Ana Avenue", "city": "Bloomington", "state": "CA", "zip": "92316", "distance": 55},
    {"name": "San Bernardino", "id": 1295, "address": "434 6th St", "city": "San Bernardino", "state": "CA", "zip": "92410", "distance": 59},
    {"name": "Riverside", "id": 1290, "address": "3760 Pyrite St.", "city": "Riverside", "state": "CA", "zip": "92509", "distance": 62},
    {"name": "Hesperia", "id": 1287, "address": "11399 Santa Fe Ave. E.", "city": "Hesperia", "state": "CA", "zip": "92345", "distance": 77},
    {"name": "Victorville", "id": 1296, "address": "17229 Gas Line Road", "city": "Victorville", "state": "CA", "zip": "92394", "distance": 83},
    {"name": "Bakersfield", "id": 1284, "address": "5311 South Union Ave.", "city": "Bakersfield", "state": "CA", "zip": "93307", "distance": 107},
    {"name": "Chula Vista", "id": 1283, "address": "880 Energy Way", "city": "Chula Vista", "state": "CA", "zip": "91911", "distance": 136},
]

PRIMARY_DOMAIN = "https://www.pyp.com"
FALLBACK_DOMAIN = "https://www.lkqpickyourpart.com"
REQUEST_DELAY = 1.0  # seconds between yard requests — be polite
REQUEST_TIMEOUT = 30  # seconds per request
USER_AGENT = "Mozilla/5.0 (compatible; auto-parts-sourcing/1.0)"


@dataclass
class VehicleMatch:
    yard_name: str
    yard_distance: int
    year: str = ""
    make: str = ""
    model: str = ""
    stock_number: str = ""
    vin: str = ""
    color: str = ""
    location: str = ""  # section/row/space
    url: str = ""


def get_yards(max_distance: int) -> list[dict[str, Any]]:
    """Return yards sorted by distance, filtered by max_distance."""
    yards = sorted(YARDS_91204, key=lambda y: y["distance"])
    if max_distance > 0:
        yards = [y for y in yards if y["distance"] <= max_distance]
    return yards


def fetch_yard_inventory(yard: dict[str, Any], domain: str = PRIMARY_DOMAIN) -> str | None:
    """Fetch a yard's inventory page HTML."""
    if requests is None:
        print("ERROR: requests not installed. Run: uv pip install requests", file=sys.stderr)
        return None

    slug = f"{yard['name'].lower().replace(' ', '-')}-{yard['id']}"
    url = f"{domain}/inventory/{slug}/"

    try:
        resp = requests.get(url, timeout=REQUEST_TIMEOUT, headers={"User-Agent": USER_AGENT})
        resp.raise_for_status()
        return resp.text
    except requests.RequestException as e:
        print(f"WARN: {yard['name']} fetch failed: {e}", file=sys.stderr)
        return None


def parse_inventory_html(
    html: str,
    yard: dict[str, Any],
    make_filter: str | None,
    model_filter: list[str] | None,
) -> list[VehicleMatch]:
    """Parse inventory HTML for vehicle matches."""
    matches: list[VehicleMatch] = []
    if BeautifulSoup is None:
        print("ERROR: beautifulsoup4 not installed. Run: uv pip install beautifulsoup4", file=sys.stderr)
        return matches

    soup = BeautifulSoup(html, "html.parser")

    # PYP inventory pages list vehicles in table rows or card divs.
    # The exact structure changes over time — we search for vehicle text
    # in any element that looks like a listing row.
    rows = soup.find_all(["tr", "div"], class_=lambda c: c and any(
        kw in str(c).lower() for kw in ["vehicle", "inventory", "listing", "row"]
    ))

    # Fallback: search all table rows
    if not rows:
        rows = soup.find_all("tr")

    for row in rows:
        text = row.get_text(" ", strip=True)
        text_lower = text.lower()

        # Apply make filter
        if make_filter:
            if make_filter.lower() not in text_lower:
                continue

        # Apply model filter
        if model_filter:
            model_matched = False
            for model in model_filter:
                if model.lower() in text_lower:
                    model_matched = True
                    break
            if not model_matched:
                continue

        match = VehicleMatch(
            yard_name=yard["name"],
            yard_distance=yard["distance"],
        )
        # Try to extract structured fields from the row
        cells = row.find_all(["td", "div", "span"])
        cell_texts = [c.get_text(strip=True) for c in cells]
        for ct in cell_texts:
            if ct and ct[:4].isdigit() and len(ct) == 4:
                match.year = ct
            if "stock" in ct.lower() or ct.startswith(str(yard["id"])):
                match.stock_number = ct
            if "VIN" in ct or (len(ct) == 17 and ct.isalnum()):
                match.vin = ct
        link = row.find("a", href=True)
        if link:
            match.url = link.get("href", "")
        # Extract make/model from the filter if available
        if make_filter:
            match.make = make_filter
        if model_filter:
            for model in model_filter:
                if model.lower() in text_lower:
                    match.model = model
                    break
        matches.append(match)

    return matches


def search_all_yards(
    zip_code: str,
    max_distance: int,
    make: str | None,
    models: list[str] | None,
    dry_run: bool = False,
) -> list[VehicleMatch]:
    """Search all yards within max_distance for the specified vehicle."""
    yards = get_yards(max_distance)

    if dry_run:
        print(f"DRY RUN — would search {len(yards)} yards:", file=sys.stderr)
        for y in yards:
            print(f"  {y['distance']:>3} mi  {y['name']:<20}  ID {y['id']}", file=sys.stderr)
        return []

    all_matches: list[VehicleMatch] = []
    for yard in yards:
        print(f"Searching {yard['name']} ({yard['distance']} mi)...", file=sys.stderr)
        html = fetch_yard_inventory(yard)
        if html is None:
            # Try fallback domain
            html = fetch_yard_inventory(yard, domain=FALLBACK_DOMAIN)
        if html is None:
            continue
        matches = parse_inventory_html(html, yard, make, models)
        all_matches.extend(matches)
        time.sleep(REQUEST_DELAY)

    # Sort by distance (nearest first)
    all_matches.sort(key=lambda m: m.yard_distance)
    return all_matches


def output_text(matches: list[VehicleMatch]) -> None:
    """Print matches as a text table."""
    if not matches:
        print("No matching vehicles found in any California Pick Your Part yard.")
        print("Run again tomorrow — inventory updates daily.")
        return

    print(f"# Pick Your Part Matches — {len(matches)} found\n")
    print(f"{'Rank':<5} {'Yard':<20} {'Dist':<6} {'Year':<6} {'Make':<10} {'Model':<15} {'Stock #':<15} {'VIN':<18}")
    print("-" * 100)
    for i, m in enumerate(matches, 1):
        print(f"{i:<5} {m.yard_name:<20} {m.yard_distance:>3} mi {m.year:<6} {m.make:<10} {m.model:<15} {m.stock_number:<15} {m.vin:<18}")
    print()
    print("Call the yard to confirm the vehicle is still on the lot before visiting.")
    print("Yard phone numbers: https://www.pyp.com/locations/")


def output_json(matches: list[VehicleMatch]) -> None:
    """Print matches as JSON."""
    print(json.dumps([asdict(m) for m in matches], indent=2))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Search Pick Your Part inventory for any vehicle make/model."
    )
    parser.add_argument("--zip", default="91204", help="Zip code for distance sorting (default: 91204)")
    parser.add_argument("--max-distance", type=int, default=100, help="Max travel radius in miles (0 = no filter)")
    parser.add_argument("--make", help="Vehicle make to search (e.g., Toyota, Hyundai, Honda)")
    parser.add_argument("--model", help="Vehicle model(s) to search, comma-separated (e.g., Mirai or 'Mirai,Prius')")
    parser.add_argument("--all", action="store_true", help="List all vehicles at each yard (no make/model filter)")
    parser.add_argument("--dry-run", action="store_true", help="Show which yards would be searched without fetching")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of text table")
    args = parser.parse_args()

    if not args.all and not args.make:
        parser.error("--make is required unless --all is specified")

    models = None
    if args.model:
        models = [m.strip() for m in args.model.split(",")]

    matches = search_all_yards(
        zip_code=args.zip,
        max_distance=args.max_distance,
        make=args.make if not args.all else None,
        models=models,
        dry_run=args.dry_run,
    )

    if args.json:
        output_json(matches)
    else:
        output_text(matches)

    return 0


if __name__ == "__main__":
    sys.exit(main())
