# Doctor Checklist

The whole-project audit sweep, organized by change cluster. Every cluster
appears in the report — including ones found clean. The letter is assigned
by `onboarding-report.py` from the cluster key; the letters listed here
are the canonical map.

## Cluster Map

| Letter | Cluster key | What the doctor looks for |
|---|---|---|
| D | `docs` | README/docs drift from code reality, stale sections, dead links, missing setup steps, contradictory instructions |
| A | `ai-guidance` | AGENTS.md/rules/skills/prompts that are stale, contradictory, missing, or written for a different tool/model |
| B | `build-tooling` | broken or missing build/test/lint targets, dead scripts, package-manager drift (npm in a pnpm repo), missing lockfiles |
| S | `security` | hardcoded secrets, permissive configs, missing secret scanning, unsafe defaults, committed credentials |
| G | `git-hygiene` | ignore-file gaps, committed artifacts, stale branches-as-files (TODO dumps), missing hooks the project expects |
| N | `dead` | no-longer-needed files, dead code, unused deps/exports, orphaned configs, superseded docs |
| E | `efficiency` | inefficient patterns, redundant work in hot paths, wasteful CI, duplicated build steps |
| I | `inconsistency` | convention drift — mixed styles the project itself has standardized on one of, duplicate logic in two places |
| M | `model-prompting` | project AI config that violates the model brief — wrong prompt structure, oversized single-shot requests, missing reasoning-mode settings, stale model pins |
| X | `dependencies` | outdated/vulnerable/unused dependencies, version drift between lockfile and manifest, license issues |

Clusters the project genuinely lacks (e.g. no CI → nothing under B's CI
items) still appear in the report with `clean` or `n/a`, never silently
omitted.

## Sweep Procedure

1. Run `repository-health-review.sh` on the project root first — its six
   categories (outdated info, conflicting rules, undocumented standards,
   lessons from failures, missing tool docs, security/access) seed
   clusters D, I, S, G.

2. Walk the project top-down: root config → build files → CI → docs →
   AI/agent config → source tree. Record every finding with:
   `cluster`, `title`, `detail`, `files`, `tier`, and (for applied fixes)
   `fix` — a one-line description of what was changed.

3. Cross-cut checks beyond repository-health-review:
   - Does every documented command actually exist (justfile/package.json
     targets, scripts referenced in docs)?
   - Do config files contradict each other (two tools configured for the
     same job, conflicting pins)?
   - Is anything present that a fresh clone wouldn't need (build output,
     local state, editor files not ignored)?
   - Cluster M: does every prompt/rule/agent config agree with the model
     brief (structure, context budget, reasoning mode, model pin)?

4. Triage per the Certainty Tiers in INSTRUCTIONS.md. When a finding
   straddles tiers, pick the more conservative one.

## Sub-request phrasing (model-aware)

When delegating sweep chunks (per-directory or per-cluster) to subagents
or splitting the audit across context limits, phrase each sub-request per
the model brief:

- Use the brief's preferred structure for the request itself.
- Cap each sub-request under the brief's practical input limit — split by
  directory or cluster, never mid-file.
- Ask for findings in the findings-JSON shape directly when the brief
  says structured output is reliable; otherwise ask for markdown and
  convert.
