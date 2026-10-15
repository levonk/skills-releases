# Gates: {story-slug}

OWNS: {repository-relative globs this story may write, e.g. src/api/**, tests/api/**}

Scope: {one sentence describing the complete deliverable}

- [ ] G1: {observable outcome measured directly from the artifact}
  CHECK: {command that exits 0 and prints the EXPECT marker only on success}
  EXPECT: {success-only marker}
  EVIDENCE: pending

- [ ] G2: {integration outcome in a subproject}
  CHECK: {command}
  EXPECT: {marker}
  CWD: packages/{module}
  EVIDENCE: pending

- [ ] G3: {manual outcome that no command can decide}
  EVIDENCE: pending

<!--
Replace every placeholder before running the checker.

Strict format:
- Use a unique explicit id (G1, G2, ...) for every gate.
- Indent CHECK, EXPECT, CWD, and EVIDENCE beneath their gate.
- Give a runnable gate both CHECK and EXPECT; give a manual gate neither.
- Success requires process exit 0 AND EXPECT matches combined stdout+stderr.
- Make EXPECT a success-only marker produced after every assertion passes.
- For an absence or negative assertion, test the same checker against a known
  positive fixture and record that control in the gate's manual review.
- Measure supplied figures from source. Do not copy a supplied number into
  EXPECT as its own proof.
- Use repository-owned scripts for portable checks. Declare any non-default
  shell or external tool requirement explicitly.
- OWNS paths must be repository-relative, complete, and disjoint from every
  concurrently dispatched story. Claims coordinate writers; they do not sandbox.

If a gate becomes genuinely impossible, keep the gate and add:

  ABANDON: G{n} {non-empty reason and handoff}

ABANDON must be at column 1 (not indented). Surface every abandonment as a
non-successful handoff in the final report; an abandoned story is not complete.

Run the linter before working the ledger:

  uv run --script scripts/gate-lint.py GATES-{story-slug}.md

Run the checker after the subagent returns:

  uv run --script scripts/gate-check.py --reverify GATES-{story-slug}.md
-->
