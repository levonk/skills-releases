# Triage Heuristic — Assessing Request Size and Shape

The triage heuristic determines two things about a user request:

1. **Size** — is the request large enough to warrant the full
   PRD → tasks → execute pipeline, or should it be handled with direct
   execution?
2. **Shape** — does the request produce code changes (a **ship** task)
   or an investigation report (a **scout** task)?

The size determination uses the decision matrix below. The shape
determination uses the ship/scout classification. Both are made during
Phase 2 (Assess) and recorded in the task index so the execution loop
routes each story correctly.

## Ship vs Scout Classification

Not every task produces code. The shape classification determines the
execution pipeline:

| Shape | Output | Pipeline | Worktree |
|-------|--------|----------|----------|
| **Ship** | Code changes (or config, or behavior-changing docs) | Full dev → review → commit → ship cycle | Feature branch, not scratch |
| **Scout** | Investigation report at a known path | Investigate → write report → completion gate → tear down | Declared scratch |

### How to Classify

Classify as **scout** if the request asks any of:

- "Should we adopt X or Y?" (comparison/evaluation)
- "Can we migrate from A to B?" (feasibility investigation)
- "Why is X happening?" (root-cause investigation)
- "What would it take to..." (effort estimation)
- "Investigate..." or "Explore..." or "Research..." (explicit
  investigation language)

Classify as **ship** if the request asks to:

- "Add..." or "Implement..." or "Build..." (new functionality)
- "Fix..." or "Repair..." (bug fix)
- "Refactor..." or "Migrate..." (code change)
- "Update..." or "Change..." (modification)

### Scout Task Pipeline

Scout tasks skip the dev → review → commit → ship cycle. Instead:

1. Work in a worktree **declared scratch** (the branch is not a PR
   candidate; do not push it).
2. Investigate — read code, run experiments, build prototypes, gather
   evidence.
3. Write `report.md` at a known path (e.g.
   `internal-docs/feature/todo/{slug}/report.md`).
4. Feed the report into the **decision inventory** — a tracked list of
   open investigations and their findings.
5. Completion gate — verify the report exists and meets a minimum
   structure (problem statement, findings, recommendation, evidence).
6. Tear down the worktree (discardable after the report exists and the
   gate passes).

### Scout-to-Ship Conversion

If a scout task discovers a fix during investigation, the conversion to
a ship task must be **explicit**: change the task shape from scout to
ship, create a new worktree on a feature branch, and run the ship
pipeline. Do not implicitly merge investigation code.

See the
[ship-scout-task-shapes](../../knowledge/agent-orchestration-practices/ship-scout-task-shapes.md)
knowledge bundle page for the full pattern.

## Size Decision Matrix

The request is "large" (warrants the full pipeline) if it meets **2 or more**
of the following criteria:

| Criterion | Question | Large if... |
|-----------|----------|-------------|
| File scope | How many files will this touch? | More than 3 files |
| Module scope | Does this span multiple modules/services? | Yes — different modules |
| Phases | Does this require sequential phases? | Yes — e.g., schema → API → UI → tests |
| Functionality type | Is this new functionality or a fix? | New functionality |
| Scope clarity | Is the scope clear from the request? | No — needs clarifying questions |
| User intent | Does the user reference a PRD/feature/project? | Yes |

## Examples

### Large (run the full pipeline)

- "Add user authentication with OAuth, session management, and role-based
  access control" — touches auth, middleware, database, UI; multiple phases;
  new functionality; scope needs clarification.
- "Build a reporting dashboard with data aggregation, chart rendering, and
  export functionality" — touches data layer, API, UI; multiple phases; new
  functionality.
- "Migrate the database from SQLite to PostgreSQL" — touches config,
  migrations, data layer, tests; multiple phases; scope needs clarification.

### Small (direct execution)

- "Fix the typo in the login button label" — 1 file, fix to existing code,
  clear scope.
- "Add a `maxLength` validator to the name field" — 1-2 files, small feature,
  clear scope.
- "Update the dependency version of lodash" — 1 file, fix, clear scope.

### Borderline (confirm with user)

- "Add a password reset flow" — touches 3-4 files, new functionality, but
  scope is relatively clear. Confirm with the user.
- "Refactor the API client to use async/await instead of promises" — touches
  many files but is a mechanical change. Confirm with the user.

## Confirmation Protocol

When the request is small (fails the heuristic), confirm with the user:

> "This looks like a focused change. I can implement it directly, or run the
> full PRD → tasks → execute pipeline. Which would you prefer?"

When the request is borderline (meets exactly 2 criteria but barely), confirm:

> "This request is moderate in scope. I can run the full PRD → tasks →
> execute pipeline for thorough tracking, or implement it directly. Which
> would you prefer?"

When the request is large (meets 3+ criteria), proceed with the pipeline but
briefly summarize your assessment:

> "This request warrants the full pipeline because it [reasons]. I'll start
> by creating/locating the PRD."

## Anti-Rationalization

| Rationalization | Reality |
|---|---|
| "This is simple, I do not need the pipeline" | Simple tasks do not need the full pipeline, but they still need acceptance criteria. If the heuristic says large, run the pipeline. |
| "I can hold the plan in my head" | Context windows are finite. Written plans survive session boundaries and compaction. |
| "The user knows what they want" | Even clear requests have implicit assumptions. The PRD surfaces those assumptions before code. |
| "Planning is overhead" | Planning is the task. Implementation without a plan is just typing. A 15-minute PRD prevents hours of rework. |
| "Requirements will change anyway" | That is why the PRD is a living document. An outdated PRD is still better than no PRD. |
| "I'll just fix this one thing" | If it touches 3+ files or spans modules, it is not "one thing." The heuristic catches scope creep the agent does not self-detect. |
