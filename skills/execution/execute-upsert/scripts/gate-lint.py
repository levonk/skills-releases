#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
gate-lint.py — catch mechanically weak gate ledgers at authoring time.

Advisory, non-executing linter for acceptance gate ledgers. Catches gates
that cannot fail honestly before work starts, not at report time.

Checks:
  ERROR: partial runnable gate (CHECK without EXPECT or vice versa)
  ERROR: duplicate gate IDs
  ERROR: zero-gate ledger
  ERROR: malformed abandonment (unknown id, blank reason, indented)
  WARN:  oracle that cannot fail (CHECK is a bare echo/true with matching EXPECT)
  WARN:  absence check without a negative control (heuristic)
  WARN:  supplied number copied into EXPECT as its own proof (heuristic)
  WARN:  unescaped inner slash in regex EXPECT

Usage:
    uv run --script gate-lint.py GATES-story.md
    uv run --script gate-lint.py --strict GATES-story.md   # warnings fail

Exit codes:
    0  — no errors (warnings printed unless --strict)
    1  — errors found, or warnings found with --strict
    2  — usage error
"""
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class LintFinding:
    severity: str  # "ERROR" or "WARN"
    line: int
    gate_id: str
    message: str


@dataclass
class LintGate:
    id: str
    outcome: str
    check: str | None = None
    expect: str | None = None
    cwd: str | None = None
    line: int = 0


@dataclass
class LintLedger:
    gates: list[LintGate] = field(default_factory=list)
    abandons: dict[str, str] = field(default_factory=dict)
    abandon_lines: dict[str, int] = field(default_factory=dict)


def parse_for_lint(path: Path) -> tuple[LintLedger, list[LintFinding]]:
    """Parse the ledger enough to lint it. Returns (ledger, parse_errors)."""
    raw = path.read_text(encoding="utf-8")
    lines = raw.splitlines()
    findings: list[LintFinding] = []
    ledger = LintLedger()

    in_fence = False
    fence_char = ""
    current_gate: LintGate | None = None
    seen_ids: set[str] = set()

    for i, line in enumerate(lines, start=1):
        stripped = line.strip()

        # Track fenced code blocks
        if not in_fence and _is_fence_open(stripped):
            in_fence = True
            fence_char = stripped[0]
            current_gate = None
            continue
        if in_fence and _is_fence_close(stripped, fence_char):
            in_fence = False
            current_gate = None
            continue
        if in_fence:
            continue

        # ABANDON: must be at column 1
        if line.startswith("ABANDON:"):
            rest = line[len("ABANDON:"):].strip()
            parts = rest.split(None, 1)
            if len(parts) < 2 or not parts[1].strip():
                findings.append(LintFinding("ERROR", i, parts[0] if parts else "?",
                                            "ABANDON requires an id and a non-empty reason"))
                continue
            aid, reason = parts[0], parts[1].strip()
            if aid not in seen_ids:
                findings.append(LintFinding("ERROR", i, aid,
                                            f"ABANDON references unknown gate id '{aid}'"))
                continue
            ledger.abandons[aid] = reason
            ledger.abandon_lines[aid] = i
            current_gate = None
            continue

        # Indented ABANDON: is malformed
        if stripped.startswith("ABANDON:") and not line.startswith("ABANDON:"):
            findings.append(LintFinding("ERROR", i, "?",
                                        "ABANDON must be at column 1, not indented"))
            continue

        # Gate header
        m = re.match(r"^-\s+\[([ xX])\]\s+(\S+):\s*(.+)$", line)
        if m:
            gid = m.group(2)
            outcome = m.group(3).strip()
            if gid in seen_ids:
                findings.append(LintFinding("ERROR", i, gid,
                                            f"duplicate gate id '{gid}'"))
            seen_ids.add(gid)
            current_gate = LintGate(id=gid, outcome=outcome, line=i)
            ledger.gates.append(current_gate)
            continue

        # Gate attributes
        if current_gate and line.startswith((" ", "\t")):
            if stripped.startswith("CHECK:"):
                current_gate.check = stripped[len("CHECK:"):].strip()
            elif stripped.startswith("EXPECT:"):
                current_gate.expect = stripped[len("EXPECT:"):].strip()
            elif stripped.startswith("CWD:"):
                current_gate.cwd = stripped[len("CWD:"):].strip()
            continue

        if stripped and not line.startswith((" ", "\t")):
            current_gate = None

    if not ledger.gates and not findings:
        findings.append(LintFinding("ERROR", 0, "-", "ledger has no gates"))

    return ledger, findings


def _is_fence_open(stripped: str) -> bool:
    if not stripped or stripped[0] not in ("`", "~"):
        return False
    return len(stripped) >= 3 and all(c == stripped[0] for c in stripped)


def _is_fence_close(stripped: str, fence_char: str) -> bool:
    if not stripped or stripped[0] != fence_char:
        return False
    return len(stripped) >= 3 and all(c == stripped[0] for c in stripped)


def lint_gates(ledger: LintLedger) -> list[LintFinding]:
    """Run semantic checks on parsed gates."""
    findings: list[LintFinding] = []

    for g in ledger.gates:
        has_check = g.check is not None
        has_expect = g.expect is not None

        # Partial runnable gate
        if has_check and not has_expect:
            findings.append(LintFinding("ERROR", g.line, g.id,
                                        "runnable gate has CHECK without EXPECT"))
        if has_expect and not has_check:
            findings.append(LintFinding("ERROR", g.line, g.id,
                                        "runnable gate has EXPECT without CHECK"))

        if not has_check and not has_expect:
            # Manual gate — no further mechanical checks
            continue

        check = g.check or ""
        expect = g.expect or ""

        # Oracle that cannot fail: bare echo/true with matching EXPECT
        check_simple = re.match(r"^(echo|true|printf)\s+", check.strip())
        if check_simple and expect in check:
            findings.append(LintFinding("WARN", g.line, g.id,
                                        "oracle cannot fail — CHECK is a bare echo/true that always matches EXPECT; "
                                        "the check must read the artifact named by the outcome"))

        # Absence check without negative control (heuristic: check contains
        # "no " or "not " or "absent" but no fixture/control reference)
        outcome_lower = g.outcome.lower()
        is_absence = any(k in outcome_lower for k in ("no ", "not ", "absent", "without", "never"))
        has_control = any(k in check.lower() for k in ("control", "fixture", "positive", "known"))
        if is_absence and not has_control:
            findings.append(LintFinding("WARN", g.line, g.id,
                                        "absence check without a negative control — test the same logic against a "
                                        "known positive fixture and confirm it fails before trusting absence"))

        # Supplied number copied into EXPECT as its own proof (heuristic:
        # EXPECT is a bare number and the outcome mentions that number)
        expect_is_number = expect.strip().rstrip("/").isdigit()
        if expect_is_number:
            # Check if the number appears in the outcome
            num = expect.strip().rstrip("/")
            if num in g.outcome:
                findings.append(LintFinding("WARN", g.line, g.id,
                                            f"number '{num}' copied from the brief into EXPECT as its own proof — "
                                            "make the script measure the value from source and print a success marker instead"))

        # Unescaped inner slash in regex EXPECT
        if expect.startswith("/") and expect.rstrip().endswith("/") and expect.count("/") >= 2:
            inner = expect.strip()[1:expect.rstrip().rfind("/")]
            if "/" in inner and "\\/" not in inner:
                findings.append(LintFinding("WARN", g.line, g.id,
                                            "unescaped inner slash in regex EXPECT — both readings are plausible; "
                                            "escape the inner slashes or drop the wrapping slashes and match a substring"))

    return findings


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Lint an acceptance gate ledger for mechanically weak gates.",
    )
    parser.add_argument("--strict", action="store_true", help="Warnings fail (exit 1)")
    parser.add_argument("ledger", help="Path to the GATES.md ledger file")
    args = parser.parse_args()

    ledger_path = Path(args.ledger)
    if not ledger_path.exists():
        print(f"error: ledger file not found: {ledger_path}", file=sys.stderr)
        return 2

    ledger, parse_findings = parse_for_lint(ledger_path)
    semantic_findings = lint_gates(ledger)
    all_findings = parse_findings + semantic_findings

    errors = [f for f in all_findings if f.severity == "ERROR"]
    warnings = [f for f in all_findings if f.severity == "WARN"]

    for f in all_findings:
        loc = f"line {f.line}" if f.line else "ledger"
        print(f"  {f.severity}: {loc} [{f.gate_id}] {f.message}")

    print(f"\n{len(errors)} error(s), {len(warnings)} warning(s)")

    if errors:
        return 1
    if warnings and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
