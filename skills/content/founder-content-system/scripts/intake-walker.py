#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Founder Content System — Phase 0 intake walker.

Walks a client folder (if one exists) and produces a FOUND / MISSING checklist
for the 13 intake inputs. For each MISSING input, prints:
  - what it is
  - why the system needs it
  - how to get it (URL to paste, file to drop in, call to schedule)

Every input is optional. The system proceeds on what is found while the gaps
get filled asynchronously. The user can skip any input.

Usage:
  uv run --script intake-walker.py [--client-dir <path>] [--json]
  uv run --script intake-walker.py --help

  # pip fallback when uv is not available (script has no external deps):
  python3 intake-walker.py [--client-dir <path>] [--json]

Without --client-dir, prints the full checklist with every item marked
MISSING and exits (first-run mode — the user has not set up a folder yet).
With --client-dir, walks the directory and marks items FOUND when a likely
candidate file is present.

The script is deterministic and side-effect free: it only reads, never writes.
It does not scrape the web, call APIs, or schedule calls. The AI agent that
invokes it is responsible for acting on the gaps (scheduling the insight call,
pasting URLs, dropping files into the folder).
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Devbox detection — use `devbox run --` to execute commands when devbox
# is available and a devbox.json exists, unless already inside a devbox shell.
# This script has no external dependencies and runs no external commands,
# but the detection helpers are included per skill script standards so that
# any future extension (e.g. invoking yt-dlp for transcript extraction) can
# use devbox_run() instead of bare subprocess.run().
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    """Check if devbox is available and not already in a devbox shell."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)

INTAKE_ITEMS: tuple["IntakeItem", ...] = (
    # Defined below after the dataclass.
)


@dataclass(frozen=True)
class IntakeItem:
    """One intake input the system wants."""

    slug: str
    label: str
    what: str
    why: str
    how: str
    """Filenames (relative to client dir) that, if present, mark this FOUND.

    Empty means the walker cannot detect it from the filesystem — the AI must
    ask the user. Glob patterns are supported via Path.match (simple globs).
    """
    detect_files: tuple[str, ...] = field(default_factory=tuple)
    """Substrings that, if found in any .md/.txt/.json file in the client dir,
    mark this FOUND (for URL/handle inputs that may be pasted into a notes file).
    """
    detect_text: tuple[str, ...] = field(default_factory=tuple)


INTAKE_ITEMS = (
    IntakeItem(
        slug="insight-call",
        label="Recorded insight call (45–60 min, transcribed)",
        what="One recorded call with the founder. Carries the origin story, the product in their own words, strong opinions, what they cannot say publicly, who reviews.",
        why="The single richest source of voice, facts, and constraints. Without it, the system is guessing at the persona.",
        how="Schedule a 45–60 min recorded call (Zoom/Granola/Fathom). Ask: origin story, product in their own words, admired writers and WHY, banned topics, nameable customers, who reviews. Paste the transcript path or URL when ready.",
        detect_files=("insight-call*", "transcript*", "call*", "granola*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="social-handles",
        label="Founder social handles (X, LinkedIn, Instagram, TikTok, YouTube, Facebook, blog)",
        what="The founder's own account URLs/handles on each platform the system will produce content for.",
        why="Needed to scrape verbatim posts for the voice corpus (Phase 2) and to know where published posts land.",
        how="Paste each handle or profile URL. Partial answers are fine — the system produces content only for the platforms you provide.",
        detect_files=("handles*", "accounts*", "social*"),
        detect_text=("x.com/", "linkedin.com/in/", "instagram.com/", "tiktok.com/", "youtube.com/", "facebook.com/"),
    ),
    IntakeItem(
        slug="reference-links",
        label="Reference links (accounts and posts the founder admires + WHY)",
        what="A links doc: accounts and specific posts the founder admires, plus the founder's commentary on why each is admired.",
        why="Reference accounts define the structural moves the founder wants to imitate (and what their persona cannot do). Without the WHY, imitation copies surface style, not structure.",
        how="Paste links and a one-line WHY for each. If the insight call mentioned admired accounts but no links exist, name them and the system will search X meanwhile.",
        detect_files=("references*", "links*", "admired*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="existing-posts",
        label="Founder's existing posts (full text, not summaries)",
        what="The founder's existing posts across each platform, full text. Note metrics and which era represents the voice they WANT.",
        why="The voice corpus is built from verbatim samples, never from a description of the voice. This is the single most important input.",
        how="The system scrapes X via `from:handle -filter:replies` and LinkedIn recent activity. For Instagram/TikTok/YouTube, paste captions or export the account. Full text only.",
        detect_files=("posts*", "corpus*", "scrape*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="published-research",
        label="Published research / technical material (papers, benchmarks, technical blog)",
        what="The company's research page, papers, benchmarks, or technical blog that the founder's claims rest on.",
        why="If the product is technical, claims in posts must trace to primary documents, not intermediate summaries. The papers download + index is MANDATORY when research exists.",
        how="Paste the research page URL, arXiv author IDs, Hugging Face org, GitHub org. The system downloads and indexes the actual PDFs. If no papers exist, flag that accuracy rests on calls + site + docs.",
        detect_files=("papers*", "research*", "arxiv*"),
        detect_text=("arxiv.org/", "huggingface.co/", "github.com/"),
    ),
    IntakeItem(
        slug="other-transcripts",
        label="Other transcripts (sales calls, customer calls, roadmap discussions, podcasts, talks)",
        what="Any other recorded and transcribed conversations: sales calls, customer calls, internal roadmap discussions, podcast appearances, conference talks.",
        why="Each is a voice and fact source. Spoken voice is pre-approved material — founders explain their product best out loud.",
        how="Paste transcript paths or URLs. YouTube appearances: the system runs the youtube-content-analysis skill to extract transcripts.",
        detect_files=("sales*", "customer*", "roadmap*", "podcast*", "talk*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="published-content",
        label="Everything the founder has published (blog posts, podcast episodes, talks, newsletters)",
        what="The founder's full published output: blog posts, podcast episodes, talks, newsletter issues.",
        why="Each is a voice and anchor source. Published content is pre-approved — the founder already said it publicly.",
        how="Paste URLs or drop files into the client folder. The system indexes them into the anchor bank.",
        detect_files=("blog*", "newsletter*", "published*"),
        detect_text=("medium.com/", "substack.com/", "newsletter"),
    ),
    IntakeItem(
        slug="customer-quotes",
        label="Verbatim customer quotes and real numbers (pasted, not paraphrased)",
        what="Real customer quotes with attribution and real numbers (revenue, usage, outcomes). Pasted verbatim, never paraphrased.",
        why="Anchored posts need real numbers. A post anchored on a real number cannot say nothing — slop is mostly a substance problem.",
        how="Paste quotes and numbers into a quotes file. Include the customer name (or 'unnamed customer' if NDA) and the date.",
        detect_files=("quotes*", "customers*", "numbers*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="constraints",
        label="Constraints in writing (nameable customers, banned topics, competitor rules, who approves)",
        what="The written constraints: which customers can be named, which topics are banned, competitor naming rules, who must approve before publishing.",
        why="The persona constraints file (Phase 3) is built from these. Without them, a drafted post can contradict the company's own positioning or leak an NDA customer.",
        how="Paste the constraints into a constraints file, or point to the internal doc that holds them. If only verbal, transcribe from the insight call.",
        detect_files=("constraints*", "banned*", "nda*", "approvals*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="admired-accounts",
        label="Reference accounts they admire and specifically WHY",
        what="The accounts the founder admires, plus the founder's commentary on what to imitate structurally vs. what their persona cannot do.",
        why="Defines the structural imitation target. The WHY separates structural imitation (allowed) from surface style copying (banned).",
        how="List the accounts and the WHY for each. This may overlap with the reference-links input — that is fine.",
        detect_files=("admired*", "reference-accounts*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="brand-doc",
        label="Brand or positioning doc",
        what="The company's brand or positioning document.",
        why="Grounds the facts layer (Phase 1) and the persona constraints (Phase 3). A drafted post can contradict published positioning — caught only by checking against this doc.",
        how="Paste the doc path or URL. If it is a Google Doc, the system reads the LIVE version even when a file copy exists.",
        detect_files=("brand*", "positioning*", "messaging*"),
        detect_text=(),
    ),
    IntakeItem(
        slug="research-papers",
        label="Research or technical papers (the actual PDFs)",
        what="The actual PDFs/reports the founder's claims rest on, not just the research page URL.",
        why="Agent summaries and crawl metadata drift from primary sources in BOTH directions. Claims in posts must trace to the primary document.",
        how="Drop the PDFs into a papers/ subfolder. The system verifies they are real PDFs and flags any the site lists that the client did NOT author.",
        detect_files=("papers/*.pdf", "research/*.pdf"),
        detect_text=(),
    ),
    IntakeItem(
        slug="internal-docs",
        label="Internal docs (manifesto-equivalents, launch docs, brand/positioning docs)",
        what="Internal docs: manifesto-equivalents, launch docs, brand/positioning docs in the client folder or Google Drive.",
        why="Internal docs go stale. A live version may have cut something the file copy still carries. Read everything present; list what was promised on calls but never delivered (chase list).",
        how="Drop files into the client folder or paste Google Doc URLs. The system reads the LIVE version of any Google Doc.",
        detect_files=("internal*", "manifesto*", "launch*", "docs*"),
        detect_text=("docs.google.com/", "notion.so/", "confluence"),
    ),
)


def _matches_glob(path: Path, pattern: str) -> bool:
    """Match a glob pattern that may include a subdirectory (e.g. 'papers/*.pdf').

    Path.match does not handle subdirectory globs well, so we split on the
    first '/' and recurse.
    """
    if "/" in pattern:
        head, _, tail = pattern.partition("/")
        for child in path.iterdir():
            if child.is_dir() and child.match(head):
                if any(child.iterdir()) and _matches_glob(child, tail):
                    return True
        return False
    return any(p.match(pattern) for p in path.iterdir()) if path.is_dir() else False


def _detect_text_in_files(path: Path, needles: tuple[str, ...]) -> bool:
    """Return True if any needle appears in any .md/.txt/.json file under path (depth 1)."""
    if not path.is_dir():
        return False
    for child in path.iterdir():
        if not child.is_file() or child.suffix not in (".md", ".txt", ".json"):
            continue
        try:
            text = child.read_text(encoding="utf-8", errors="ignore").lower()
        except OSError:
            continue
        if any(n.lower() in text for n in needles):
            return True
    return False


def _evaluate_item(item: IntakeItem, client_dir: Optional[Path]) -> bool:
    """Return True if the item is FOUND in client_dir."""
    if client_dir is None or not client_dir.is_dir():
        return False
    for pattern in item.detect_files:
        try:
            if _matches_glob(client_dir, pattern):
                return True
        except OSError:
            continue
    if item.detect_text and _detect_text_in_files(client_dir, item.detect_text):
        return True
    return False


def _build_checklist(client_dir: Optional[Path]) -> list[dict]:
    rows = []
    for item in INTAKE_ITEMS:
        found = _evaluate_item(item, client_dir)
        rows.append(
            {
                "slug": item.slug,
                "label": item.label,
                "status": "FOUND" if found else "MISSING",
                "what": item.what,
                "why": item.why,
                "how": item.how,
            }
        )
    return rows


def _print_text(rows: list[dict], client_dir: Optional[Path]) -> None:
    found_count = sum(1 for r in rows if r["status"] == "FOUND")
    missing_count = len(rows) - found_count
    print(f"# Founder Content System — Phase 0 Intake Inventory\n")
    if client_dir is not None:
        print(f"Client folder: `{client_dir}`\n")
    else:
        print("Client folder: (not set — first run)\n")
    print(f"**{found_count} FOUND · {missing_count} MISSING**\n")
    print("Every input is optional. The system proceeds on what is found while the gaps get filled.\n")
    print("| # | Input | Status |")
    print("|---|-------|--------|")
    for i, r in enumerate(rows, 1):
        print(f"| {i} | {r['label']} | {'FOUND' if r['status'] == 'FOUND' else 'MISSING'} |")
    missing = [r for r in rows if r["status"] == "MISSING"]
    if missing:
        print("\n## Missing inputs — collection guidance\n")
        for r in missing:
            print(f"### {r['label']}\n")
            print(f"**What:** {r['what']}\n")
            print(f"**Why the system needs it:** {r['why']}\n")
            print(f"**How to get it:** {r['how']}\n")
    else:
        print("\nAll inputs found. Proceed to Phase 1 (Facts layer).\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Founder Content System Phase 0 intake walker.",
    )
    parser.add_argument(
        "--client-dir",
        type=Path,
        default=None,
        help="Path to the client folder. If omitted, every item is MISSING (first-run mode).",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of markdown.",
    )
    args = parser.parse_args(argv)

    client_dir: Optional[Path] = None
    if args.client_dir is not None:
        client_dir = args.client_dir.expanduser().resolve()
        if not client_dir.is_dir():
            print(f"error: --client-dir does not exist or is not a directory: {client_dir}", file=sys.stderr)
            return 2

    rows = _build_checklist(client_dir)
    if args.json:
        json.dump({"client_dir": str(client_dir) if client_dir else None, "items": rows}, sys.stdout, indent=2)
        sys.stdout.write("\n")
    else:
        _print_text(rows, client_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
