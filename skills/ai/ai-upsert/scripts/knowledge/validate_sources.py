#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Validate sources: frontmatter entries in markdown files.

For each markdown file with a `sources:` frontmatter field, check that each
entry's `resource` is accessible:
- URLs (http/https): HTTP HEAD request (10s timeout, follow redirects)
- Local paths (no scheme): check file exists relative to the markdown file's directory
- RFC 2606 reserved domains (example.com, example.org, example.net and
  the .test/.example/.invalid/.localhost TLDs): always treated as
  accessible — they are placeholders, not real sources to validate

Emits warnings (NOT errors) for inaccessible sources. Exit 0 always — this
is advisory, not a gate. Use --strict to exit non-zero on any warning.

Usage:
    uv run --script validate_sources.py <path> [--strict] [--verbose] [--no-network]
    python validate_sources.py <path> [--strict] [--verbose] [--no-network]

    <path> — a file or directory; directories are walked recursively
    --strict — exit non-zero if any warnings are emitted
    --verbose — print every source checked (not just warnings)
    --no-network — skip URL accessibility checks (only check local paths)

Markdown extensions scanned: .md, .md.tmpl, .mmd, .mmd.tmpl, .md.template,
.md.j2, .mmd.j2, .markdown, .mdown, .mdtxt, .mdtext, .mkd, .mdx, .mkdn, .mkdwn
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

try:
    import yaml  # type: ignore[import-not-found]
except ImportError:
    yaml = None  # type: ignore[assignment]


MARKDOWN_EXTENSIONS: tuple[str, ...] = (
    ".md",
    ".md.tmpl",
    ".mmd",
    ".mmd.tmpl",
    ".md.template",
    ".md.j2",
    ".mmd.j2",
    ".markdown",
    ".mdown",
    ".mdtxt",
    ".mdtext",
    ".mkd",
    ".mdx",
    ".mkdn",
    ".mkdwn",
)

SKIP_DIRS: frozenset[str] = frozenset(
    {".git", "build", "node_modules", ".cache", "bin"}
)

USER_AGENT = "ai-upsert-source-validator/1.0"
HTTP_TIMEOUT = 10


# ---------------------------------------------------------------------------
# Frontmatter extraction
# ---------------------------------------------------------------------------
def extract_frontmatter(text: str) -> str | None:
    """Return the raw YAML frontmatter block (between leading --- lines).

    Returns None if the file does not start with a frontmatter block.
    """
    if not text.startswith("---"):
        return None
    lines = text.splitlines(keepends=True)
    if not lines:
        return None
    # First line is "---"
    start = 1
    for idx in range(start, len(lines)):
        stripped = lines[idx].strip()
        if stripped == "---":
            return "".join(lines[1:idx])
    return None


def parse_sources(raw_frontmatter: str) -> list[dict[str, Any]]:
    """Parse the `sources:` field from raw frontmatter text.

    Uses PyYAML if available; otherwise falls back to a simple regex parser
    that extracts `resource` (and `id`) values from the sources list.
    """
    if yaml is not None:
        try:
            data = yaml.safe_load(raw_frontmatter)
            if isinstance(data, dict):
                sources = data.get("sources")
                if isinstance(sources, list):
                    return [
                        entry
                        for entry in sources
                        if isinstance(entry, dict)
                    ]
            return []
        except yaml.YAMLError:
            # Fall through to regex parser
            pass
    return _parse_sources_fallback(raw_frontmatter)


def _parse_sources_fallback(raw: str) -> list[dict[str, Any]]:
    """Minimal regex parser: extract `resource` values from the sources block.

    Only extracts `resource` (and `id` if present) — does not need full YAML.
    """
    sources: list[dict[str, Any]] = []
    in_sources = False
    current: dict[str, Any] | None = None

    for line in raw.splitlines():
        stripped = line.strip()
        # Detect start of sources: block (top-level key)
        if not line.startswith(" ") and not line.startswith("\t"):
            if stripped.startswith("sources:"):
                in_sources = True
                continue
            # Any other top-level key ends the sources block
            if in_sources and stripped and not stripped.startswith("#"):
                in_sources = False
                if current is not None:
                    sources.append(current)
                    current = None
                continue
        if not in_sources:
            continue
        # Inside sources block — look for list items and nested keys
        # List item start:  - id: ...  or  - resource: ...
        list_match = re.match(r"\s*-\s+(id|resource):\s*(.*)$", line)
        if list_match:
            if current is not None:
                sources.append(current)
            current = {}
            key = list_match.group(1)
            value = list_match.group(2).strip().strip('"').strip("'")
            current[key] = value
            continue
        # Nested key under current list item:  resource: ...
        nested_match = re.match(r"\s+(id|resource):\s*(.*)$", line)
        if nested_match and current is not None:
            key = nested_match.group(1)
            value = nested_match.group(2).strip().strip('"').strip("'")
            current[key] = value
            continue
    if current is not None:
        sources.append(current)
    return sources


# ---------------------------------------------------------------------------
# Source validation
# ---------------------------------------------------------------------------
def is_example_domain(url: str) -> bool:
    """Return True if the URL's host is an RFC 2606 reserved domain.

    RFC 2606 reserves:
    - Second-level domains: example.com, example.org, example.net (and
      any subdomain thereof)
    - Top-level domains: .test, .example, .invalid, .localhost

    URLs on these hosts are placeholders, not real sources — always
    treated as accessible without a network check.
    """
    try:
        parsed = urllib.parse.urlparse(url)
        host = parsed.hostname
    except ValueError:
        return False
    if not host:
        return False
    host = host.lower()
    # Reserved second-level domains (and subdomains thereof)
    for reserved in ("example.com", "example.org", "example.net"):
        if host == reserved or host.endswith("." + reserved):
            return True
    # Reserved TLDs
    for reserved_tld in (".test", ".example", ".invalid", ".localhost"):
        if host.endswith(reserved_tld):
            return True
    return False


def check_url(url: str, no_network: bool, verbose: bool) -> tuple[bool, str]:
    """Check URL accessibility. Returns (accessible, reason).

    For RFC 2606 reserved domains, always returns (True, "example domain").
    For --no-network, returns (True, "skipped (no-network)").
    """
    if no_network:
        return True, "skipped (no-network)"
    if is_example_domain(url):
        return True, "example domain"
    try:
        req = urllib.request.Request(
            url,
            method="HEAD",
            headers={"User-Agent": USER_AGENT},
        )
        with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT) as resp:  # noqa: S310
            status = resp.status
            if 200 <= status < 400:
                return True, f"HTTP {status}"
            return False, f"HTTP {status}"
    except urllib.error.HTTPError as exc:
        return False, f"HTTP {exc.code}"
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        return False, str(exc)


def check_local(resource: str, md_dir: Path) -> tuple[bool, Path]:
    """Check a local path relative to the markdown file's directory."""
    resolved = (md_dir / resource).resolve()
    return resolved.exists(), resolved


def validate_file(
    md_path: Path, args: argparse.Namespace
) -> tuple[int, int]:
    """Validate one markdown file. Returns (sources_checked, warnings)."""
    try:
        text = md_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(
            f"WARNING: READ_ERROR: {md_path}: {exc}",
            file=sys.stderr,
        )
        return 0, 1

    raw = extract_frontmatter(text)
    if raw is None:
        return 0, 0

    sources = parse_sources(raw)
    if not sources:
        return 0, 0

    md_dir = md_path.parent
    warnings = 0
    checked = 0

    for idx, entry in enumerate(sources):
        resource = entry.get("resource")
        if resource is None:
            print(
                f"WARNING: MISSING_RESOURCE: {md_path}:{idx}: "
                f"sources entry has no 'resource' field",
                file=sys.stderr,
            )
            warnings += 1
            continue
        if not isinstance(resource, str):
            print(
                f"WARNING: MISSING_RESOURCE: {md_path}:{idx}: "
                f"sources entry 'resource' is not a string",
                file=sys.stderr,
            )
            warnings += 1
            continue

        checked += 1
        lower = resource.lower()
        if lower.startswith("http://") or lower.startswith("https://"):
            accessible, reason = check_url(resource, args.no_network, args.verbose)
            if accessible:
                if args.verbose:
                    print(f"[OK] URL: {md_path}:{idx}: {resource} — {reason}")
            else:
                print(
                    f"WARNING: INACCESSIBLE_URL: {md_path}:{idx}: "
                    f"{resource} — {reason}",
                    file=sys.stderr,
                )
                warnings += 1
        elif "://" in resource:
            # Other schemes (ftp, mailto, etc.) — skip with verbose note
            if args.verbose:
                print(
                    f"[OK] SKIP: {md_path}:{idx}: {resource} "
                    f"— non-http scheme, skipped"
                )
        else:
            exists, resolved = check_local(resource, md_dir)
            if exists:
                if args.verbose:
                    print(
                        f"[OK] LOCAL: {md_path}:{idx}: {resource} "
                        f"(resolved to {resolved})"
                    )
            else:
                print(
                    f"WARNING: MISSING_LOCAL: {md_path}:{idx}: "
                    f"{resource} (resolved to {resolved})",
                    file=sys.stderr,
                )
                warnings += 1

    return checked, warnings


# ---------------------------------------------------------------------------
# File discovery
# ---------------------------------------------------------------------------
def iter_markdown_files(path: Path) -> list[Path]:
    """Yield markdown files under path (recursive if directory)."""
    if path.is_file():
        return [path] if _is_markdown(path) else []
    if path.is_dir():
        results: list[Path] = []
        for root, dirs, files in os.walk(path):
            # Skip excluded directories in-place
            dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
            for name in sorted(files):
                fp = Path(root) / name
                if _is_markdown(fp):
                    results.append(fp)
        return results
    return []


def _is_markdown(path: Path) -> bool:
    name = path.name.lower()
    return any(name.endswith(ext) for ext in MARKDOWN_EXTENSIONS)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate sources: frontmatter entries in markdown files.",
        usage="%(prog)s <path> [--strict] [--verbose] [--no-network]",
    )
    parser.add_argument(
        "path",
        help="A file or directory; directories are walked recursively",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="exit non-zero if any warnings are emitted",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="print every source checked (not just warnings)",
    )
    parser.add_argument(
        "--no-network",
        action="store_true",
        help="skip URL accessibility checks (only check local paths)",
    )
    args = parser.parse_args(argv)

    root = Path(args.path)
    if not root.exists():
        print(f"ERROR: path does not exist: {root}", file=sys.stderr)
        return 2

    files = iter_markdown_files(root)
    total_sources = 0
    total_warnings = 0

    for md_path in files:
        checked, warnings = validate_file(md_path, args)
        total_sources += checked
        total_warnings += warnings

    print(
        f"Checked {len(files)} files, {total_sources} sources, "
        f"{total_warnings} warnings"
    )

    if args.strict and total_warnings > 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
