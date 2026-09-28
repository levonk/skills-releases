#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
lint-ears.py — EARS pattern linter for the requirements ledger.

Checks that every sentence in the `## Statement` (first paragraph) and
`## Constraints` (each `- ` bullet) sections of a requirement file uses a
valid EARS pattern with SHALL as the modal verb.

EARS (Easy Approach to Requirements Syntax) templates:
  1. Ubiquitous   — The {system} shall {response}.
  2. Event-driven — When {trigger}, the {system} shall {response}.
  3. State-driven — While {state}, the {system} shall {response}.
  4. Unwanted     — If {condition}, then the {system} shall {response}.
  5. Optional     — Where {feature is included}, the {system} shall {response}.

Usage:
  # Lint every requirement under <root>/internal-docs/reqs/current/
  uv run --script lint-ears.py --root /path/to/repo

  # Lint a single file
  uv run --script lint-ears.py --file /path/to/req.md

Exits 0 if all sentences pass, 1 if any fail.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


# ── EARS pattern matching ──────────────────────────────────────────────
#
# Each pattern is anchored at the start of the sentence (case-insensitive).
# "shall" is required in every pattern.  We keep the matching deliberately
# simple — regex is enough; a full NLP parser is out of scope.

_SHALL = r"\bshall\b"

# Order matters: conditional patterns are checked first so that a sentence
# starting with "When" is not mis-classified as Ubiquitous.
_PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("Event-driven", re.compile(
        r"^when\b.+?,\s*the\b.+" + _SHALL + r"\b.+\.?$",
        re.IGNORECASE | re.DOTALL,
    )),
    ("State-driven", re.compile(
        r"^while\b.+?,\s*the\b.+" + _SHALL + r"\b.+\.?$",
        re.IGNORECASE | re.DOTALL,
    )),
    ("Unwanted", re.compile(
        r"^if\b.+?,\s*then\s+the\b.+" + _SHALL + r"\b.+\.?$",
        re.IGNORECASE | re.DOTALL,
    )),
    ("Optional", re.compile(
        r"^where\b.+?,\s*the\b.+" + _SHALL + r"\b.+\.?$",
        re.IGNORECASE | re.DOTALL,
    )),
    ("Ubiquitous", re.compile(
        r"^the\b.+" + _SHALL + r"\b.+\.?$",
        re.IGNORECASE | re.DOTALL,
    )),
]

# Forbidden modal verbs that should be "shall".
_BAD_MODALS = re.compile(
    r"\b(should|must|will|may|would)\b",
    re.IGNORECASE,
)


def split_sentences(text: str) -> list[str]:
    """Split a block of text into sentences.

    Splits on '. ' (period + space) or newlines, preserving content.  Each
    returned sentence is stripped; empty fragments are dropped.
    """
    # Normalise whitespace inside the block but keep sentence boundaries.
    raw = re.split(r"(?<=[.!?])\s+|\n+", text.strip())
    return [s.strip() for s in raw if s.strip()]


def classify(sentence: str) -> tuple[str | None, str | None]:
    """Return (pattern_name, error_reason).

    pattern_name is set when the sentence matches a valid EARS pattern.
    error_reason is set when it does not, explaining why.
    """
    # Reject sentences using forbidden modal verbs even if they otherwise
    # look like EARS — gives a clearer error message.
    bad = _BAD_MODALS.search(sentence)
    if bad and not re.search(_SHALL, sentence, re.IGNORECASE):
        return None, (
            "uses '" + bad.group(0) + "' instead of 'shall' "
            "(EARS requires SHALL as the modal verb)"
        )

    for name, pat in _PATTERNS:
        if pat.match(sentence):
            return name, None

    if not re.search(_SHALL, sentence, re.IGNORECASE):
        return None, "missing 'shall' (EARS requires SHALL as the modal verb)"

    # Has "shall" but no pattern matched — wrong structure.
    lower = sentence.lower()
    if lower.startswith("if "):
        return None, "If-pattern must be 'If {condition}, then the {system} shall {response}.' (missing 'then'?)"
    if lower.startswith(("when ", "while ", "where ")):
        return None, "conditional EARS pattern is malformed (expected keyword + clause + ', the {system} shall {response}.')"
    return None, "does not match any of the 5 EARS templates (Ubiquitous/When/While/If-then/Where)"


# ── Markdown section extraction ────────────────────────────────────────


def _strip_frontmatter(lines: list[str]) -> list[str]:
    """Drop YAML frontmatter (leading --- ... --- block) if present."""
    if not lines or lines[0].strip() != "---":
        return lines
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            return lines[i + 1:]
    return lines  # no closing ---; return as-is


def extract_sections(text: str) -> tuple[str | None, list[str]]:
    """Extract the Statement (first paragraph) and Constraints (bullets).

    Returns (statement_text, constraint_texts).  Either may be empty/None
    if the section is missing.
    """
    lines = text.splitlines()
    lines = _strip_frontmatter(lines)

    statement: str | None = None
    constraints: list[str] = []

    current_section: str | None = None
    statement_lines: list[str] = []

    for line in lines:
        heading = re.match(r"^##\s+(.+?)\s*$", line)
        if heading:
            # Flush any accumulated statement lines.
            if current_section == "Statement" and statement is None:
                joined = " ".join(s.strip() for s in statement_lines if s.strip())
                if joined:
                    statement = joined
                statement_lines = []
            current_section = heading.group(1).strip().lower()
            continue

        if current_section == "statement":
            # First paragraph: collect until we hit a blank line after content.
            stripped = line.strip()
            if stripped:
                # Skip HTML comments and template placeholder lines.
                if stripped.startswith("<!--") or stripped.startswith("Use one of"):
                    continue
                statement_lines.append(line)
            elif statement_lines:
                # Blank line ends the first paragraph.
                joined = " ".join(s.strip() for s in statement_lines if s.strip())
                if joined:
                    statement = joined
                statement_lines = []
                current_section = None  # done with statement
        elif current_section == "constraints":
            m = re.match(r"^-\s+(.+)$", line)
            if m:
                constraints.append(m.group(1).strip())

    # Flush trailing statement lines (file ended without blank line).
    if statement is None and statement_lines:
        joined = " ".join(s.strip() for s in statement_lines if s.strip())
        if joined:
            statement = joined

    return statement, constraints


# ── Linting driver ─────────────────────────────────────────────────────


def lint_file(path: Path, lines_index: dict[str, int] | None = None) -> list[str]:
    """Lint a single requirement file.  Return list of error strings."""
    errors: list[str] = []
    text = path.read_text(encoding="utf-8")
    statement, constraints = extract_sections(text)

    # Build a line-number lookup for nicer error messages.
    file_lines = text.splitlines()

    def find_line(needle: str) -> int:
        for i, ln in enumerate(file_lines, start=1):
            if needle[:40] in ln:
                return i
        return 0

    if statement is None:
        errors.append(str(path) + ":0: WARNING — no ## Statement section found (skipped)")
    else:
        for sent in split_sentences(statement):
            name, reason = classify(sent)
            if reason:
                ln = find_line(sent)
                errors.append(
                    str(path) + ":" + str(ln) + ": ERROR — invalid EARS sentence: " + repr(sent)
                    + " (" + reason + ")"
                )

    if not constraints:
        # Constraints are optional — warn only if the section header exists
        # but has no bullets.  We detect by re-scanning for the header.
        if re.search(r"^##\s+Constraints\b", text, re.MULTILINE):
            errors.append(str(path) + ":0: WARNING — ## Constraints section is empty (no bullets)")
    else:
        for c in constraints:
            for sent in split_sentences(c):
                name, reason = classify(sent)
                if reason:
                    ln = find_line(sent)
                    errors.append(
                        str(path) + ":" + str(ln) + ": ERROR — invalid EARS constraint: " + repr(sent)
                        + " (" + reason + ")"
                    )

    return errors


def find_requirement_files(root: Path) -> list[Path]:
    """Return sorted list of requirement .md files under current/."""
    base = root / "internal-docs" / "reqs" / "current"
    if not base.is_dir():
        return []
    return sorted(base.rglob("*.md"))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Lint EARS patterns in requirements ledger files.",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=None,
        help="Repository root (defaults to git root or PWD).",
    )
    parser.add_argument(
        "--file",
        type=Path,
        default=None,
        help="Lint a single requirement file instead of scanning --root.",
    )
    args = parser.parse_args(argv)

    if args.file is not None:
        files = [args.file.resolve()]
        if not files[0].is_file():
            print("ERROR: file not found: " + str(files[0]), file=sys.stderr)
            return 1
    else:
        root = args.root
        if root is None:
            # Try git root, else PWD.
            import subprocess
            try:
                root = Path(
                    subprocess.check_output(
                        ["git", "rev-parse", "--show-toplevel"],
                        stderr=subprocess.DEVNULL,
                    ).decode().strip()
                )
            except Exception:
                root = Path.cwd()
        root = root.resolve()
        files = find_requirement_files(root)
        if not files:
            print(
                "WARNING: no requirement files found under "
                + str(root / "internal-docs" / "reqs" / "current"),
                file=sys.stderr,
            )
            return 0

    all_errors: list[str] = []
    for f in files:
        all_errors.extend(lint_file(f))

    warnings = [e for e in all_errors if " WARNING " in e]
    errors = [e for e in all_errors if " ERROR " in e]

    for e in all_errors:
        print(e)

    print("")
    print("EARS lint: " + str(len(errors)) + " error(s), " + str(len(warnings)) + " warning(s)")

    if errors:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
