# Change ID Scheme

Every change the doctor phase surfaces gets a stable ID:

```
<LETTER><NUMBER>
   │        └─ sequential within the cluster, first finding = 1
   └─ cluster letter (one letter per change category)
```

Examples: `D1` (first docs change), `B3` (third build-tooling change),
`S2` (second security change).

## Cluster Letters

Canonical letters (assigned by `onboarding-report.py`; see
doctor-checklist.md for what each cluster audits):

| Letter | Cluster | Mnemonic |
|---|---|---|
| D | docs | Documentation |
| A | ai-guidance | Agent/AI guidance files |
| B | build-tooling | Build & tooling |
| S | security | Security & secrets |
| G | git-hygiene | Git & repo hygiene |
| N | dead | No-longer-needed |
| E | efficiency | Efficiency & performance |
| I | inconsistency | Inconsistency / convention drift |
| M | model-prompting | Model & prompting config |
| X | dependencies | eXternal dependencies |

Clusters outside the canonical map (project-specific) get the next free
letter in alphabetical order of the cluster key — deterministic for a
given findings file.

## Certainty Tiers

Every change carries one of three tiers:

| Tier | Meaning | Appears as |
|---|---|---|
| `applied` | Certain fix already made during the doctor phase | `applied` — listed for transparency; user may say `revert D4` |
| `proposed` | Recommended change awaiting approval | `proposed` — user approves by ID or cluster |
| `optional` | Judgment call / taste / larger refactor | `optional` — user opts in explicitly |

## ID Stability Rules

- IDs are assigned when the report renders and **never renumber** — a
  finding added later gets the next number in its cluster, even if an
  earlier one was applied or rejected.
- Reverting an `applied` change does not free its number.
- Re-running the doctor on a later date starts a new report file —
  `onboarding-report-YYYYMMDD.md`; IDs are unique within a report, so
  always refer to them with the report date when ambiguous.

## Report Format

```
# Onboarding Report — <project> — YYYY-MM-DD

## Summary
| Cluster | Applied | Proposed | Optional |
| D Documentation | 2 | 3 | 1 |
...

## D — Documentation
- [D1] applied — fixed dead link to setup guide (README.md:42)
- [D2] proposed — add "Testing" section; no test docs exist
- [D3] optional — split README into docs/ once it exceeds ~200 lines

## B — Build & Tooling
...
```

## Selection Syntax

The user replies with a compact selection string parsed by
`onboarding-report.py select`:

| Reply | Meaning |
|---|---|
| `D1` | apply change D1 |
| `all-D` | apply every proposed change in cluster D (optional stays opt-in) |
| `all-D+` | apply every change in cluster D including optional |
| `!S2` | explicitly skip S2 |
| `revert D4` | revert applied change D4 |
| `none-B` | skip all of cluster B |

Unmentioned proposed/optional changes default to **skipped** — approval
is opt-in. The `select` subcommand prints the resolved apply/revert/skip
list; confirm it matches intent before applying.
