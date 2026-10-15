#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
gate-check.py — parse and run an acceptance gate ledger.

A gate ledger is a markdown file with runnable and manual gates. Each runnable
gate has a CHECK (shell command), EXPECT (success-only marker), optional CWD,
and EVIDENCE. The checker runs the command, checks exit 0 + EXPECT match, and
records evidence (resolved shell, CWD, exit status, match, output fingerprint).

Modes:
  --status    Parse and report ledger state without executing anything.
  (default)   Run every runnable gate that is not yet met; record evidence.
  --reverify  Re-execute EVERY runnable gate, including already-met ones.

A gate passes only when the process exits 0 AND EXPECT matches combined
stdout+stderr. Old evidence is not re-execution — --status alone is not
reverification.

Abandonment (ABANDON: <id> <reason>) is terminal and never successful: the
checker exits 1 with HANDOFF_REQUIRED.

Usage:
    uv run --script gate-check.py GATES-story.md
    uv run --script gate-check.py --status GATES-story.md
    uv run --script gate-check.py --reverify GATES-story.md
    uv run --script gate-check.py --reverify --shell /bin/bash GATES-story.md

Exit codes:
    0  — ALL_MET (every gate met with current evidence)
    1  — UNMET or HANDOFF_REQUIRED (gates failed or abandoned)
    2  — parse error (malformed ledger, zero gates, duplicate IDs, etc.)
    3  — usage error

Output:
    Prints a per-gate status line to stdout. The last line is a JSON summary:
    {"status":"ALL_MET|UNMET|HANDOFF_REQUIRED","met":N,"unmet":N,"abandoned":N,
     "gates":[{"id":"G1","met":true,"evidence":"..."},...]}
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

OUTPUT_CAP = 1024 * 1024  # 1 MiB combined output
DEFAULT_TIMEOUT = 120  # seconds


@dataclass
class Gate:
    id: str
    outcome: str
    check: str | None = None
    expect: str | None = None
    cwd: str | None = None
    evidence: str = "pending"
    is_runnable: bool = False
    met: bool = False
    abandoned: bool = False
    abandon_reason: str = ""
    line: int = 0  # 1-based line number of the gate header


@dataclass
class Ledger:
    path: Path
    owns: str = ""
    scope: str = ""
    gates: list[Gate] = field(default_factory=list)
    abandons: dict[str, str] = field(default_factory=dict)  # id -> reason
    raw_lines: list[str] = field(default_factory=list)


class ParseError(Exception):
    pass


def parse_ledger(path: Path) -> Ledger:
    """Parse a gate ledger file. Raises ParseError on malformed structure."""
    raw = path.read_text(encoding="utf-8")
    # Preserve newline style
    lines = raw.splitlines(keepends=True)
    ledger = Ledger(path=path, raw_lines=lines)

    in_fence = False
    fence_char = ""
    fence_len = 0
    current_gate: Gate | None = None
    seen_ids: set[str] = set()

    for i, line_with_nl in enumerate(lines, start=1):
        line = line_with_nl.rstrip("\r\n")
        stripped = line.strip()

        # Track fenced code blocks — ignore their contents
        if not in_fence and _is_fence_open(stripped):
            in_fence = True
            fence_char = stripped[0]
            fence_len = len(stripped)
            current_gate = None
            continue
        if in_fence and _is_fence_close(stripped, fence_char, fence_len):
            in_fence = False
            fence_char = ""
            fence_len = 0
            current_gate = None
            continue
        if in_fence:
            continue

        # OWNS: header (before first gate)
        if stripped.startswith("OWNS:") and not current_gate:
            ledger.owns = stripped[len("OWNS:"):].strip()
            continue

        # Scope: header (before first gate)
        if stripped.lower().startswith("scope:") and not current_gate:
            ledger.scope = stripped[len("scope:"):].strip() if stripped.lower().startswith("scope:") else stripped[6:].strip()
            continue

        # ABANDON: file-level statement (column 1, not indented)
        if line.startswith("ABANDON:"):
            rest = line[len("ABANDON:"):].strip()
            # Split into id + reason on first whitespace
            parts = rest.split(None, 1)
            if len(parts) < 2 or not parts[1].strip():
                raise ParseError(
                    f"line {i}: ABANDON requires an id and a non-empty reason"
                )
            aid, reason = parts[0], parts[1].strip()
            if aid not in seen_ids:
                raise ParseError(
                    f"line {i}: ABANDON references unknown gate id '{aid}'"
                )
            ledger.abandons[aid] = reason
            current_gate = None
            continue

        # Gate header: - [ ] G1: outcome  or  - [x] G1: outcome
        m = re.match(r"^-\s+\[([ xX])\]\s+(\S+):\s*(.+)$", line)
        if m:
            check_mark = m.group(1).lower()
            gid = m.group(2)
            outcome = m.group(3).strip()
            if gid in seen_ids:
                raise ParseError(
                    f"line {i}: duplicate gate id '{gid}'"
                )
            seen_ids.add(gid)
            current_gate = Gate(
                id=gid,
                outcome=outcome,
                met=(check_mark == "x"),
                line=i,
            )
            ledger.gates.append(current_gate)
            continue

        # Gate attributes (indented)
        if current_gate and line.startswith((" ", "\t")):
            attr_stripped = stripped
            if attr_stripped.startswith("CHECK:"):
                current_gate.check = attr_stripped[len("CHECK:"):].strip()
                current_gate.is_runnable = True
            elif attr_stripped.startswith("EXPECT:"):
                current_gate.expect = attr_stripped[len("EXPECT:"):].strip()
            elif attr_stripped.startswith("CWD:"):
                current_gate.cwd = attr_stripped[len("CWD:"):].strip()
            elif attr_stripped.startswith("EVIDENCE:"):
                current_gate.evidence = attr_stripped[len("EVIDENCE:"):].strip()
            continue

        # Non-indented, non-gate, non-header line: close current gate context
        if stripped and not line.startswith((" ", "\t")):
            current_gate = None

    if not ledger.gates:
        raise ParseError("ledger has no gates — a zero-gate ledger is a parse error")

    # Validate runnable gates have both CHECK and EXPECT; manual have neither
    for g in ledger.gates:
        has_check = g.check is not None
        has_expect = g.expect is not None
        if has_check and not has_expect:
            raise ParseError(
                f"line {g.line}: gate {g.id} has CHECK without EXPECT — "
                "a runnable gate needs both"
            )
        if has_expect and not has_check:
            raise ParseError(
                f"line {g.line}: gate {g.id} has EXPECT without CHECK — "
                "a runnable gate needs both"
            )
        # Mark abandonment on the gate
        if g.id in ledger.abandons:
            g.abandoned = True
            g.abandon_reason = ledger.abandons[g.id]

    return ledger


def _is_fence_open(stripped: str) -> bool:
    if not stripped:
        return False
    if stripped[0] not in ("`", "~"):
        return False
    return len(stripped) >= 3 and all(c == stripped[0] for c in stripped)


def _is_fence_close(stripped: str, fence_char: str, fence_len: int) -> bool:
    if not stripped or stripped[0] != fence_char:
        return False
    if len(stripped) < fence_len:
        return False
    return all(c == fence_char for c in stripped[:fence_len]) and stripped[fence_len:].strip() == ""


def expect_matches(expect: str, output: str) -> bool:
    """Check if EXPECT matches combined output. Supports /pattern/flags or substring."""
    if expect.startswith("/") and expect.rstrip().endswith("/") and expect.count("/") >= 2:
        # Regex form: /pattern/flags
        parts = expect.rsplit("/", 1)
        pattern = parts[0][1:]
        flags_str = parts[1] if len(parts) > 1 else ""
        flags = 0
        if "i" in flags_str:
            flags |= re.IGNORECASE
        if "m" in flags_str:
            flags |= re.MULTILINE
        if "s" in flags_str:
            flags |= re.DOTALL
        try:
            return re.search(pattern, output, flags) is not None
        except re.error:
            return False
    return expect in output


def run_gate(gate: Gate, ledger_dir: Path, shell: str, timeout: int) -> tuple[bool, str, int, str, str]:
    """Run a runnable gate. Returns (met, resolved_cwd, exit_code, resolved_shell, fingerprint)."""
    if not gate.is_runnable:
        return (gate.met, gate.cwd or "", 0, shell, "")

    resolved_cwd = ledger_dir
    if gate.cwd:
        resolved_cwd = (ledger_dir / gate.cwd).resolve()

    try:
        result = subprocess.run(
            gate.check,
            shell=True,
            executable=shell,
            cwd=str(resolved_cwd),
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return (False, str(resolved_cwd), -1, shell, "")
    except Exception:
        return (False, str(resolved_cwd), -1, shell, "")

    combined = (result.stdout + result.stderr)[:OUTPUT_CAP]
    matched = expect_matches(gate.expect, combined)
    met = (result.returncode == 0) and matched
    fingerprint = hashlib.sha256(combined.encode("utf-8")).hexdigest()[:16] if combined else "empty"
    fp_full = f"sha256:{fingerprint}/{len(combined)}b"
    return (met, str(resolved_cwd), result.returncode, shell, fp_full)


def update_evidence_in_file(ledger: Ledger, gate: Gate, evidence_str: str) -> None:
    """Update the EVIDENCE: line for a gate in the ledger file, preserving newline style."""
    lines = ledger.raw_lines
    # Find the gate header line, then scan forward for EVIDENCE:
    gate_line = gate.line - 1  # 0-based
    for i in range(gate_line + 1, len(lines)):
        stripped = lines[i].rstrip("\r\n").strip()
        if stripped.startswith("EVIDENCE:"):
            nl = "\r\n" if lines[i].endswith("\r\n") else ("\n" if lines[i].endswith("\n") else "")
            indent = lines[i][: len(lines[i]) - len(lines[i].lstrip())]
            lines[i] = f"{indent}EVIDENCE: {evidence_str}{nl}"
            break
        # If we hit another gate header or non-indented line, stop
        if stripped and not lines[i].startswith((" ", "\t")):
            break
    ledger.path.write_text("".join(lines), encoding="utf-8")


def format_evidence(met: bool, exit_code: int, resolved_cwd: str, shell: str, fingerprint: str) -> str:
    status = "met" if met else "unmet"
    return f"{status} exit={exit_code} cwd={resolved_cwd} shell={shell} fp={fingerprint}"


def cmd_status(ledger: Ledger) -> int:
    """Report ledger state without executing anything."""
    met = 0
    unmet = 0
    abandoned = 0
    gate_results = []
    for g in ledger.gates:
        if g.abandoned:
            abandoned += 1
            gate_results.append({"id": g.id, "met": False, "abandoned": True, "evidence": g.evidence})
        elif g.met and g.evidence != "pending":
            met += 1
            gate_results.append({"id": g.id, "met": True, "abandoned": False, "evidence": g.evidence})
        else:
            unmet += 1
            gate_results.append({"id": g.id, "met": False, "abandoned": False, "evidence": g.evidence})
        print(f"  {g.id}: {'ABANDONED' if g.abandoned else ('MET' if g.met and g.evidence != 'pending' else 'UNMET')} — {g.outcome}")

    status = "ALL_MET" if (unmet == 0 and abandoned == 0 and met == len(ledger.gates)) else (
        "HANDOFF_REQUIRED" if abandoned > 0 else "UNMET"
    )
    summary = {
        "status": status,
        "met": met,
        "unmet": unmet,
        "abandoned": abandoned,
        "gates": gate_results,
    }
    print(json.dumps(summary))
    return 0 if status == "ALL_MET" else 1


def cmd_run(ledger: Ledger, shell: str, timeout: int, reverify: bool) -> int:
    """Run gates and record evidence. If reverify, re-run all runnable gates."""
    ledger_dir = ledger.path.parent.resolve()
    met = 0
    unmet = 0
    abandoned = 0
    gate_results = []

    for g in ledger.gates:
        if g.abandoned:
            abandoned += 1
            gate_results.append({"id": g.id, "met": False, "abandoned": True, "evidence": g.evidence})
            print(f"  {g.id}: ABANDONED — {g.abandon_reason}")
            continue

        if not g.is_runnable:
            # Manual gate — keep existing evidence, do not execute
            is_met = g.met and g.evidence != "pending"
            if is_met:
                met += 1
            else:
                unmet += 1
            gate_results.append({"id": g.id, "met": is_met, "abandoned": False, "evidence": g.evidence, "manual": True})
            print(f"  {g.id}: {'MET' if is_met else 'UNMET'} (manual) — {g.outcome}")
            continue

        # Runnable gate
        should_run = reverify or not g.met or g.evidence == "pending"
        if should_run:
            ran_met, resolved_cwd, exit_code, resolved_shell, fp = run_gate(g, ledger_dir, shell, timeout)
            g.met = ran_met
            evidence_str = format_evidence(ran_met, exit_code, resolved_cwd, resolved_shell, fp)
            g.evidence = evidence_str
            update_evidence_in_file(ledger, g, evidence_str)
        else:
            # Already met, not reverifying — keep existing evidence
            pass

        if g.met:
            met += 1
            print(f"  {g.id}: MET — {g.outcome}")
        else:
            unmet += 1
            print(f"  {g.id}: UNMET (exit/fingerprint in evidence) — {g.outcome}")
        gate_results.append({"id": g.id, "met": g.met, "abandoned": False, "evidence": g.evidence})

    status = "ALL_MET" if (unmet == 0 and abandoned == 0 and met == len(ledger.gates)) else (
        "HANDOFF_REQUIRED" if abandoned > 0 else "UNMET"
    )
    summary = {
        "status": status,
        "met": met,
        "unmet": unmet,
        "abandoned": abandoned,
        "gates": gate_results,
    }
    print(json.dumps(summary))
    if status == "ALL_MET":
        return 0
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Parse and run an acceptance gate ledger.",
        usage="gate-check.py [--status | --reverify] [--shell SHELL] [--timeout N] GATES.md",
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--status", action="store_true", help="Parse and report without executing")
    mode.add_argument("--reverify", action="store_true", help="Re-execute every runnable gate, including already-met")
    parser.add_argument("--shell", default="/bin/sh", help="Shell to run CHECK commands (default: /bin/sh)")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help="Per-gate timeout in seconds (default: 120)")
    parser.add_argument("ledger", help="Path to the GATES.md ledger file")
    args = parser.parse_args()

    ledger_path = Path(args.ledger)
    if not ledger_path.exists():
        print(f"error: ledger file not found: {ledger_path}", file=sys.stderr)
        return 3

    try:
        ledger = parse_ledger(ledger_path)
    except ParseError as e:
        print(f"parse error: {e}", file=sys.stderr)
        return 2

    if args.status:
        return cmd_status(ledger)
    return cmd_run(ledger, args.shell, args.timeout, args.reverify)


if __name__ == "__main__":
    sys.exit(main())
