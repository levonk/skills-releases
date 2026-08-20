# Phased Pipeline Details

## Table of Contents

1. [Phase 0: Pre-flight (Clean Repository Check)](#phase-0-pre-flight-clean-repository-check)
2. [Phase 1: Self-Update](#phase-1-self-update)
3. [Phase 2: Establish Technologies](#phase-2-establish-technologies)
4. [Phase 4: Review & Verify](#phase-4-review--verify)
5. [Phase 5: Commit](#phase-5-commit)

## Phase 0: Pre-flight (Clean Repository Check)

Before any upsert work, check the target repository's git state. A dirty
working tree risks sweeping unrelated changes into the upsert commit and
makes it impossible to attribute changes to this upsert cleanly.

1. **Initialize the run log** (see `references/skill/run-log.md`). Create
   `.agents/log/YYYYMMDDHHmm-ai-upsert-{slug}.md` with the header and an empty
   phase log. This is the crash-safe record — every subsequent phase appends
   to it.
2. **Reconcile human handoffs** — scan `.agents/handoffs/human/todo/` for
   files with `github_issue` frontmatter. For each, check if the issue is
   closed:
   ```bash
   gh issue view {number} --json state --jq '.state'
   ```
   If the issue is `CLOSED`, archive the human handoff file from
   `human/todo/` to `human/archive/YYYY/MM/` via `git mv` (per the
   `work-lifecycle` include's archive protocol). The blocker was resolved.
   If the issue is still `OPEN`, leave the file in `todo/` — the human has
   not yet acted. Log the reconciliation result in the run log:
   `Phase 0: reconciled {N} human handoff(s) — {M} archived, {K} still open`.
   If there are no human handoffs in `todo/`, skip this step silently.
3. **Run the clean-repo check** using the bundled `git-repository-management`
   skill (materialized at
   `references/included/skills/software-dev/git-repository-management/`).
   Read its `SKILL.md` and follow the "Full Repository Cleanup" entry point's
   collect phase to get the current change set.
4. **If the working tree is clean** (no uncommitted changes): append
   `Phase 0: CLEAN` to the run log, proceed to Phase 1.
5. **If the working tree is dirty**: do NOT abort. The
   `skill-src-upsert.md` workflow stages only the files touched by this
   upsert, so unrelated dirty files are not swept in. Instead:
   - Note the pre-existing dirty files for the user.
   - Append `Phase 0: WARN — dirty tree, {N} pre-existing files noted` to the
     run log.
   - Proceed, but in Phase 5 (Commit) stage **only** the files this upsert
     touched — never `git add -A` or `git add .`.
6. **If the target is not a git repo** (e.g., creating a skill in a fresh
   `~/.agents/skills/` directory): skip Phase 0 and Phase 5. Note that the
   artifact will not be under version control; offer to `git init` if the user
   wants history. Append `Phase 0: SKIP — not a git repo` to the run log.

## Phase 1: Self-Update

Before any upsert work, ensure this skill and its siblings are at the latest
version. This prevents stale skill logic from driving the upsert — especially
important when resuming from a handoff created by an older skill version.

**Command:**

```bash
devbox run -- pnpm dlx skills add levonk/skills-releases --all
```

This installs/updates all skills from the public distribution repo. The
command uses `pnpm dlx` (never `npx`) per the canonical tech-stack table
inlined above — pnpm is the package manager, `pnpm dlx` is the ad-hoc
package execution tool. This is canonical skills-tooling, independent of the
target project's tech stack: the target project may use `npm`, but the
skills tooling still uses `pnpm dlx`.

**Skip conditions:**

- **`SKIP_SELF_UPDATE=1`** — environment variable to skip self-update entirely
  (useful in CI or air-gapped environments where the latest version is already
  installed).
- **Upserting inside `skills-src` itself** — when the target is a skill in
  this repo (`src/current/skills/...`), the source IS the latest version by
  definition; skip self-update and proceed to Phase 2.

**After self-update:** if any skill versions changed, re-invoke this skill
(ai-upsert) to pick up the new logic — do not continue with the old skill
instance loaded in context. If no versions changed, proceed to Phase 2.
Append `Phase 1: CLEAN|SKIP|UPDATED` to the run log.

## Phase 2: Establish Technologies

Detect the target project's tech stack and establish it as a binding constraint
on the generated/updated artifact. This prevents the upsert from emitting
references to the wrong tools (e.g., `npm`/`npx` in a pnpm project, `jest` in a
Vitest project, `pip install` when `uv` is canonical).

**Why this phase exists:** without explicit tech establishment, the upsert
defaults to whatever it "remembers" — frequently `npm`/`npx` for Node
projects. The canonical tech-stack table (inlined above) declares pnpm as the
package manager and `pnpm dlx` as the ad-hoc runner, but the table is in the
orchestrator's context, not the generated artifact's. This phase produces a
**tech context block** that constrains every tool reference in the generated
or updated skill/bundle/agent.

**Detection:** run the bundled `project-detection` skill (materialized at
`references/included/skills/software-dev/project-detection/`):

```bash
./references/included/skills/software-dev/project-detection/scripts/detect-all-systems.sh . --json
```

If `project-detection` is separately installed as a skill, invoke it through
the skill registry instead. The bundled copy is the fallback for standalone
ai-upsert installs.

**Branch — upserting inside `skills-src`:** when the target is a skill in this
repo, the tech stack is known and fixed (pnpm, just, devbox, uv, rust,
chezmoi templating). Skip detection and use the known stack as the tech
context block.

**Tech context block** (produced from detection results; constrains the
generated artifact's tool references):

```text
## Tech Context (Binding Constraint)

This project uses the following tools. The generated/updated artifact MUST
reference these, not alternatives.

- Package manager: <pnpm|npm|yarn|bun|uv|pip|cargo|go mod>
- Ad-hoc runner: <pnpm dlx|npx|yarn dlx|bunx|uvx|cargo binstall|go install>
  (per the tech-stack table: pnpm dlx for Node, uvx for Python,
  cargo binstall for Rust, go install for Go — never npx)
- Build system: <Nx|Turbo|cargo|go|just|Make|Maven|Gradle>
- Test runner: <Vitest|Jest|cargo test|go test|pytest|bats>
- Linter: <ESLint|Biome|clippy|golangci-lint|shellcheck>
- Container runtime: <Docker|podman>
- CI/CD: <GitHub Actions|GitLab CI|CircleCI>

System tools run via: devbox run -- <command>
Never reference: npm, npx, yarn, jest, biome (unless the project explicitly uses them)
```

**Devbox remediation:** if a required tool is missing (e.g., `pnpm` not
found, `just` not found), follow the devbox remediation protocol (inlined
above from `includes/devbox-remediation.md`): add the tool to `devbox.json`
via `devbox add <package>` and run via `devbox run -- <command>`. Do NOT
install tools on the host via `npm`, `brew`, `apt`, `pip install --user`,
`pipx`, `cargo install`, or `go install` — add them to `devbox.json` instead.

**After establishment:** carry the tech context block into Phase 3 (Decision
+ Mode). Every tool reference written into the generated/updated artifact
must agree with it. If the tech stack changes during the upsert (e.g., the
new skill introduces a dependency), update the tech context block and
re-check the artifact's references. Append `Phase 2: CLEAN — {tech stack
summary}` to the run log.

## Phase 4: Review & Verify

After the artifact-type decision tree and Mode A/B/C/D work completes, run a
structured review pass before committing. This phase catches issues that the
per-mode verification steps miss — especially cross-cutting concerns like
script-standards compliance, tech-context drift, and identity leaks.

**CRITICAL — Phase 4 Concurrency Lock.** Before running any test/lint/build
sub-phase (4.1-4.6), acquire a concurrency lock to prevent overlapping runs
from corrupting build output and test results. Two concurrent ai-upsert runs
targeting the same repo and the same skill will happily run overlapping
`just test` / `just bats` / `just validate` / `just catalog` — the lock
serializes Phase 4 so only one run executes the quality gate at a time.

**Acquire the lock:**

```bash
# Resolve the target repo root and the skill being upserted
REPO_ROOT="$(git rev-parse --show-toplevel)"
TARGET_SKILL="{artifact-slug}"  # the skill/bundle/agent being upserted
RUN_SLUG="{run-slug}"            # from the run log filename

LOCK_FILE="$(devbox run -- bash scripts/lock/acquire-lock.sh \
    --repo "$REPO_ROOT" \
    --skill "$TARGET_SKILL" \
    --slug "$RUN_SLUG")"
ACQUIRE_STATUS=$?
```

**Interpret the exit code:**

- `0` — lock acquired. `LOCK_FILE` contains the path to the lock file.
  Proceed with 4.1-4.6, then release the lock at the end.
- `2` — lock is active (another run holds it). The stdout is
  `LOCKED:<path>` or `CANCELLED:<path>`. Apply the **skip policy** (below).
- `3` — action failed (kill failed, wait timed out). Append
  `Phase 4: FAIL — lock action failed` to the run log and present the
  error to the user.

**Skip policy (non-interactive default):** when the lock is active and
`AI_UPSERT_LOCK_ACTION` is unset (or set to `skip`), skip Phase 4 entirely:

1. Do NOT run 4.1-4.6.
2. Append `Phase 4: SKIP — concurrent run holds lock ($LOCK_FILE)` to the
   run log.
3. Proceed to Phase 5 (Commit) — commit the upsert changes to the story
   branch.
4. The workflow (skill-src-execute.md) will create the PR but will NOT
   auto-merge. The PR body must include the note:
   "Phase 4 skipped due to concurrent run — tests deferred."
5. A later run can check out the story branch, acquire the lock, run
   Phase 4, and merge.

**Interactive options:** when the lock is active and the user is
interactive, present these options via the clarifying-questions protocol
(see `references/skill/concurrency-lock.md` for the full policy):

1. **Wait** — block until the active run finishes (`--action wait`), then
   run full Phase 4.
2. **Kill and start** — preempt the active run (`--action kill`), take the
   lock, run full Phase 4.
3. **Skip and commit** — skip Phase 4, commit to story branch, no merge
   (the non-interactive default).
4. **Cancel** — abort this run (`--action cancel`).

**Release the lock** (at the end of Phase 4, after 4.6 passes):

```bash
devbox run -- bash scripts/lock/release-lock.sh --lock-file "$LOCK_FILE"
```

If Phase 4 was skipped (lock active), do NOT call release — there is no
lock file to release. See `references/skill/concurrency-lock.md` for the
full lock lifecycle, PID + start-time reuse guard, config key
(`concurrency.lock_dir`), and archive layout.

### 4.1 Structured Code Review

Run the bundled `code-review-guidance` skill (materialized at
`references/included/skills/software-dev/code-review-guidance/`). Read its
`SKILL.md` and follow the review checklist on the generated/updated artifact.
Alternatively, use the consolidated checklist at
`references/skill/upsert-review-checklist.md` which covers the same criteria
in a single file. Check:

- Frontmatter validity (`name`, `description`, `version`, `date`, `tags`,
  `see-also`)
- Structure and progressive disclosure — SKILL.md and INSTRUCTIONS.md (if
  present) are step overviews, not monolithic. INSTRUCTIONS.md source body
  must not exceed ~500 lines.
- Step numbering — sequential integers, no lettered sub-steps (`5a`, `5b`).
  If found, fix before proceeding.
- Reference file naming — files named by topic, not by step number
- Context Declaration completeness
- Bundled resources (scripts, references, assets) are coherent
- Includes resolve at build time (no leaked delimiters)
- The artifact honors the local project override layer (includes
  `base-ai-guidance` which bundles `project-overrides`, OR includes
  `project-overrides` directly, OR has a materialized section documenting the
  override behavior)
- Tech-context agreement: every tool reference in the artifact agrees with
  the tech context block from Phase 2 (no `npm`/`npx` in a pnpm project, no
  `jest` in a Vitest project, no `pip install` when `uv` is canonical)

### 4.2 Script-Standards Validation

If the artifact bundles scripts, validate them against the directly bundled
knowledge bundles (materialized under `references/included/knowledge/`):

- **Shell scripts** (`*.sh`): check against
  `references/included/knowledge/dev-environment-practices/shell-scripting-best-practices.md`
  — strict mode (`set -euo pipefail`), PATH guards, `command -v` checks,
  quoting, `exec` for final commands. Run `shellcheck` and `shfmt -d` on every
  shell script if available (via `devbox run --`).
- **Python scripts** (`*.py`): check against
  `references/included/knowledge/python-services-practices/standalone-scripts.md`
  — PEP 723 inline metadata header, `uv run --script` shebang, devbox/rtk
  detection, `uv` fallback to `pip`. Run `ruff check` and `ruff format --check`
  on every Python script if available (via `devbox run --`).
- **Rust code** (`*.rs`): check against
  `references/included/knowledge/rust-development-practices/rustfmt-clippy-config.md`
  and `references/included/knowledge/rust-development-practices/quality-gates.md`.
  Run `cargo fmt --check` and `cargo clippy -- -D warnings` if available (via
  `devbox run --`).

### 4.3 Existing Verification (preserved)

Run the existing per-mode verification steps — these are not replaced by 4.1
and 4.2, they are complemented:

- **Skills**: `scripts/skill/package_skill.py` to validate structure. If any
  markdown file has a `sources:` frontmatter field, run
  `scripts/knowledge/validate_sources.py <path>` to verify sources are
  accessible.
- **Knowledge bundles**: OKF v0.2 self-check (see OKF Version Self-Check
  in the main instructions), `validate_sources.py` on any file with a `sources:` field.
- **All artifacts**: run `scripts/scan-artifacts.sh` (if the artifact generates
  scripts/files that will be committed) to catch identity leaks — the scanner
  resolves this machine's actual identity values (`$HOME`, `whoami`,
  `hostname`, WiFi SSID, DNS domain) and scans for those specific strings.

### 4.4 Substantial-Script Gate

If the artifact bundles more than a handful of substantial scripts (more than
~5 scripts, or any script over ~100 lines), also invoke the
`code-quality-validation` skill at runtime (not bundled — it is a heavy
validation runner) on the artifact's `scripts/` directory. This runs lint,
format, and test checks appropriate to the detected languages. Skip if the
artifact has only trivial scripts.

### 4.5 Task List + Definition of Done Section Verification

If the artifact is a skill (`INSTRUCTIONS.md`), verify it has both a
`## Task List` section and a `## Definition of Done` section that match
the standardized pattern (documented in `references/skill/anatomy.md` —
Task List + Definition of Done Sections, inlined from
`includes/definition-of-done.md`):

**Task List:**
- The section exists between Current Process and Definition of Done
- Items are checkbox-tracked with status marks (`[ ]`/`[~]`/`[x]`/`[!]`)
- The mark legend is present
- The maintenance protocol is present

**Definition of Done:**
- The section exists between Task List and References
- Items are tagged `[script]` or `[manual]`
- Items are grouped into subsections by deliverable category
- A "Not Done (common false-completion signals)" anti-checklist is present
- If the skill produces deterministic outputs (scripts, builds, configs),
  `[script]` items are present for the verifiable checks

If either section is missing or non-standard, add or fix it before
proceeding. Use the scaffolds in `references/skill/instructions-template.md`
as the starting point, and populate them with skill-specific items derived
from the skill's Outcome, Guardrails, and Current Process sections. The
Task List items are derived from the Current Process steps; the DoD items
are the verification checks that confirm each task was done right.

### 4.6 Gate

Do not proceed to Phase 5 until 4.1, 4.2, 4.3, and 4.5 pass. 4.4 is a warning
gate (reported, but does not block unless the user opts in). If any check
fails, fix the root cause (per the root-cause-first policy — no band-aids)
and re-run the failing check until it passes. Append `Phase 4: CLEAN|WARN|FAIL`
to the run log with a one-line summary of each sub-check's status.

## Phase 5: Commit

Commit the upsert result using the bundled `git-repository-management` skill
(materialized at
`references/included/skills/software-dev/git-repository-management/`). Read
its `SKILL.md` and follow the commit workflow.

**Critical — stage only touched files:** the repository may have unrelated
dirty files (noted in Phase 0). Stage **only** the files this upsert touched —
never `git add -A` or `git add .`. Use the `git-repository-management`
skill's batch-commit workflow with explicit file paths.

**Commit conventions:** follow the `commit-tagging-standard` include (inlined
above) and the `git-repository-management` skill's commit templates. No AI
attribution boilerplate (no "Generated with", no "Co-Authored-By: Devin"
trailers) — per the global rules.

**Pre/post auto-tags:** the `git-repository-management` skill auto-creates
pre/post tags for rollback safety; let it.

**Skip if not a git repo:** if Phase 0 determined the target is not under
version control, skip this phase. Offer to `git init` if the user wants
history.

**After commit:** update `date.last-used` in this skill's frontmatter (the
date-management include is wired in above) to reflect that ai-upsert was used
today. Append `Phase 5: CLEAN — commit {sha}` to the run log. Commit the run
log file itself (`.agents/log/YYYYMMDDHHmm-ai-upsert-{slug}.md`) so the
record is durable.
