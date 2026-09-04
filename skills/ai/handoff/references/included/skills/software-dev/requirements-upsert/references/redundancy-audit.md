# Redundancy Audit

**Date**: 2026-08-30
**Audited by**: redundancy-audit story (execute-upsert)

## Overlaps Checked

1. **EARS linter vs validate-ledger.sh** — NON-OVERLAPPING. validate-ledger.sh
   checks frontmatter dates + orphan history (Checks 1-4). lint-ears.py checks
   EARS pattern syntax (Check 5). Both run from a single validate-ledger.sh
   invocation. No consolidation needed — the concerns are different, the
   invocation is already consolidated.

2. **AgentContract clauses vs quality-gate.sh** — REFERENCED, NOT DUPLICATED.
   The .contract.yaml `must` clauses with `enforcement: machine` reference
   quality-gate.sh and execution-gate.sh as the check implementations in
   their `check:` fields. The contract does not re-implement the checks.

3. **AgentContract LLM-judged clauses vs code-review-guidance** — REFERENCED,
   NOT DUPLICATED. The .contract.yaml `must` clauses with
   `enforcement: llm-judged` reference the code-review-guidance skill as the
   review implementation. The contract does not duplicate the review checklist.

4. **Simplex EXAMPLES vs Gherkin acceptance criteria** — DISTINCT DOMAINS.
   Gherkin is for behavioral paths (state transitions, user interactions).
   EXAMPLES are for data-transform paths (parsing, mapping, conversion).
   The task templates do not require both for the same path. Documented in
   formal-languages-overview.md → Redundancy Watchlist.

5. **FSL scenarios vs task Verify commands** — REFERENCED, NOT DUPLICATED.
   If a requirement has a parallel .fsl spec, task Verify commands should
   reference FSL-generated scenarios, not re-derive them. Documented in
   formal-languages-overview.md → Redundancy Watchlist and in
   fsl-integration.md → Relationship to Other Tools.

## Audit Findings

Overlaps 1, 3, 4, and 5 were already correctly handled by the previous
stories — no changes were needed.

Overlap 2 (AgentContract LLM-judged clauses vs code-review-guidance) required
a minor fix: the `commit-after-story` and `rollback-on-failure` clauses in
`execute-upsert.contract.yaml` had `check:` fields that described the
orchestrator's actions but did not name the `code-review-guidance` skill as
the evaluation mechanism. The `agent-contract.md` documentation stated that
"AgentContract names the review process in the `check` field," but the YAML
did not actually do so. The `check:` fields were updated to explicitly
reference the `code-review-guidance` skill, bringing the YAML in line with
the documented relationship.

## Conclusion

All 5 overlaps were checked. One minor fix was applied (overlap 2: explicit
code-review-guidance reference in LLM-judged clause check fields). No
duplications remain — the multi-tool adoption is non-redundant.
