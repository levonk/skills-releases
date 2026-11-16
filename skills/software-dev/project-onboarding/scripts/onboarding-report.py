#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
onboarding-report.py — deterministic change report for project-onboarding.

Subcommands:
  init                          Emit a findings JSON skeleton to stdout.
  render <findings.json>        Assign letter+number IDs and emit the
                                markdown change report (--out <path> or stdout).
  select <findings.json> <sel>  Resolve a user selection string into the
                                apply/revert/skip sets (JSON on stdout).

Findings schema:
  {"project": str, "date": "YYYY-MM-DD", "findings": [
    {"cluster": "docs", "title": str, "detail": str, "files": [str],
     "tier": "applied"|"proposed"|"optional", "fix": str?}
  ]}
Findings may carry a pre-assigned "id" ("D1") — render preserves it so
IDs never renumber; new findings take the next free number in-cluster.

Selection grammar (comma/space separated):
  D1        apply single change      all-D    apply all proposed in D
  all-D+    apply all in D (incl. optional)   !S2     skip S2
  none-B    skip all of cluster B    revert D4  revert applied D4
Unmentioned proposed/optional findings default to skipped.

Run: uv run --script onboarding-report.py <subcommand> ...
"""

import json
import re
import sys
from pathlib import Path

# Canonical cluster map — letter -> (cluster key, display name).
CLUSTER_MAP: dict[str, tuple[str, str]] = {
    "D": ("docs", "Documentation"),
    "A": ("ai-guidance", "AI Guidance"),
    "B": ("build-tooling", "Build & Tooling"),
    "S": ("security", "Security & Secrets"),
    "G": ("git-hygiene", "Git & Repo Hygiene"),
    "N": ("dead", "No-Longer-Needed"),
    "E": ("efficiency", "Efficiency & Performance"),
    "I": ("inconsistency", "Inconsistency"),
    "M": ("model-prompting", "Model & Prompting"),
    "X": ("dependencies", "External Dependencies"),
}
TIERS = ("applied", "proposed", "optional")


def _walk_up_find(*names: str) -> Path | None:
    """Walk up from cwd looking for any of the given filenames."""
    for d in [Path.cwd(), *Path.cwd().parents]:
        for n in names:
            if (d / n).is_file():
                return d / n
    return None


def ensure_uv() -> None:
    """If 'uv' is missing and a devbox.json exists up-tree, record 'uv' in it."""
    import shutil

    if shutil.which("uv"):
        return
    devbox_json = _walk_up_find("devbox.json")
    if not devbox_json:
        return
    try:
        data = json.loads(devbox_json.read_text())
    except (json.JSONDecodeError, OSError):
        return
    packages = data.get("packages", {})
    if isinstance(packages, dict):
        packages.setdefault("uv", "")
    elif isinstance(packages, list):
        if "uv" not in packages:
            packages.append("uv")
    try:
        devbox_json.write_text(json.dumps(data, indent=2) + "\n")
    except OSError:
        pass


def letter_for(cluster_key: str, assigned: dict[str, str]) -> str:
    """Map a cluster key to its letter; assign next free letter for unknowns."""
    if cluster_key in assigned:
        return assigned[cluster_key]
    for letter, (key, _name) in CLUSTER_MAP.items():
        if key == cluster_key:
            assigned[cluster_key] = letter
            return letter
    used = set(assigned.values())
    for cand in "CDEFHJKLOPQRSTUVWYZ":
        if cand not in used:
            assigned[cluster_key] = cand
            return cand
    raise SystemExit(f"no free cluster letter for {cluster_key!r}")


def assign_ids(findings: list[dict]) -> dict[str, str]:
    """Assign stable letter+number IDs in place; returns cluster->letter."""
    assigned: dict[str, str] = {}
    next_num: dict[str, int] = {}
    for f in findings:
        letter = letter_for(f.get("cluster", "inconsistency"), assigned)
        fid = f.get("id")
        if fid:
            m = re.match(r"^([A-Z])(\d+)$", fid)
            if m:
                next_num[letter] = max(next_num.get(letter, 0), int(m.group(2)) + 1)
            continue
        n = next_num.get(letter, 1)
        f["id"] = f"{letter}{n}"
        next_num[letter] = n + 1
    return assigned


def cluster_name(letter: str, cluster_key: str) -> str:
    for l, (k, name) in CLUSTER_MAP.items():
        if l == letter and k == cluster_key:
            return name
    return cluster_key.replace("-", " ").title()


def render(data: dict) -> str:
    findings = data.get("findings", [])
    assign_ids(findings)
    # Group findings by letter, preserving input order within a cluster.
    groups: dict[str, list[dict]] = {}
    for f in findings:
        groups.setdefault(f["id"][0], []).append(f)

    out = [
        f"# Onboarding Report — {data.get('project', 'project')} — {data.get('date', '')}",
        "",
        "## Summary",
        "",
        "| Cluster | Applied | Proposed | Optional |",
        "|---|---|---|---|",
    ]
    for letter in sorted(groups):
        items = groups[letter]
        key = items[0].get("cluster", "")
        name = cluster_name(letter, key)
        counts = {t: sum(1 for i in items if i.get("tier") == t) for t in TIERS}
        out.append(
            f"| {letter} {name} | {counts['applied']} | {counts['proposed']} | {counts['optional']} |"
        )
    out.append("")

    for letter in sorted(groups):
        items = groups[letter]
        name = cluster_name(letter, items[0].get("cluster", ""))
        out.append(f"## {letter} — {name}")
        out.append("")
        for f in items:
            files = ", ".join(f.get("files", []))
            loc = f" ({files})" if files else ""
            fix = f" — {f['fix']}" if f.get("fix") else ""
            out.append(
                f"- [{f['id']}] {f.get('tier', '?')} — {f.get('title', '')}{fix}{loc}"
            )
            if f.get("detail"):
                out.append(f"  - {f['detail']}")
        out.append("")
    return "\n".join(out)


def parse_selection(sel: str, findings: list[dict]) -> dict:
    """Resolve a selection string into apply/revert/skip ID sets."""
    by_id = {f["id"]: f for f in findings if f.get("id")}
    apply_ids: set[str] = set()
    revert_ids: set[str] = set()
    skip_ids: set[str] = set()

    for tok in re.split(r"[,\s]+", sel.strip()):
        if not tok:
            continue
        m = re.fullmatch(r"revert\s*([A-Z]\d+)", tok, re.I) or re.fullmatch(
            r"revert:([A-Z]\d+)", tok, re.I
        )
        if m:
            revert_ids.add(m.group(1).upper())
            continue
        m = re.fullmatch(r"all-([A-Z])(\+?)", tok, re.I)
        if m:
            letter, incl_opt = m.group(1).upper(), bool(m.group(2))
            for f in findings:
                if f["id"][0] == letter and f.get("tier") == "proposed":
                    apply_ids.add(f["id"])
                elif f["id"][0] == letter and f.get("tier") == "optional" and incl_opt:
                    apply_ids.add(f["id"])
            continue
        m = re.fullmatch(r"none-([A-Z])", tok, re.I)
        if m:
            letter = m.group(1).upper()
            skip_ids |= {
                f["id"]
                for f in findings
                if f["id"][0] == letter and f.get("tier") in ("proposed", "optional")
            }
            continue
        m = re.fullmatch(r"!([A-Z]\d+)", tok)
        if m:
            skip_ids.add(m.group(1))
            continue
        m = re.fullmatch(r"([A-Z]\d+)", tok, re.I)
        if m:
            apply_ids.add(m.group(1).upper())
            continue
        # Handle 'revert' as a bare prefix word: 'revert D4' splits into
        # tokens 'revert' and 'D4' — mark next bare ID as a revert.
        if tok.lower() == "revert":
            continue
        raise SystemExit(f"unparseable selection token: {tok!r}")

    # 'revert' as prefix word — rescan for 'revert <ID>' pairs.
    for m in re.finditer(r"revert\s+([A-Za-z]\d+)", sel):
        rid = m.group(1).upper()
        apply_ids.discard(rid)
        revert_ids.add(rid)

    apply_ids -= skip_ids
    unknown = (apply_ids | revert_ids | skip_ids) - set(by_id)
    if unknown:
        print(f"warning: unknown IDs ignored: {sorted(unknown)}", file=sys.stderr)
    pending = {
        f["id"]
        for f in findings
        if f.get("tier") in ("proposed", "optional") and f.get("id")
    }
    return {
        "apply": sorted(apply_ids & set(by_id)),
        "revert": sorted(revert_ids & set(by_id)),
        "skip": sorted((pending | skip_ids) - apply_ids - revert_ids),
        "applied_unchanged": sorted(
            f["id"]
            for f in findings
            if f.get("tier") == "applied" and f.get("id") not in revert_ids
        ),
    }


def main() -> int:
    ensure_uv()
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    cmd, rest = args[0], args[1:]

    if cmd in ("init", "--init"):
        print(
            json.dumps(
                {
                    "project": "",
                    "date": "",
                    "findings": [
                        {
                            "cluster": "docs",
                            "title": "",
                            "detail": "",
                            "files": [],
                            "tier": "proposed",
                        }
                    ],
                },
                indent=2,
            )
        )
        return 0

    if cmd == "render":
        if not rest:
            raise SystemExit("usage: render <findings.json> [--out <path>]")
        data = json.loads(Path(rest[0]).read_text())
        report = render(data)
        if "--out" in rest:
            out = Path(rest[rest.index("--out") + 1])
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(report)
            print(str(out))
        else:
            print(report)
        return 0

    if cmd == "select":
        if len(rest) < 2:
            raise SystemExit('usage: select <findings.json> "<selection>"')
        data = json.loads(Path(rest[0]).read_text())
        assign_ids(data.get("findings", []))
        print(json.dumps(parse_selection(rest[1], data["findings"]), indent=2))
        return 0

    raise SystemExit(f"unknown subcommand: {cmd!r} (init|render|select)")


if __name__ == "__main__":
    sys.exit(main())
