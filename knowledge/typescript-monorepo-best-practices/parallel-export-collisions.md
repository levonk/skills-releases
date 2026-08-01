---
type: Practice
title: Parallel Export Collisions — Subagent Symbol Conflicts on Barrel Files
description: When parallel subagents independently choose export names and modify barrel files (src/index.ts), they collide on merge — TS2308 errors and duplicate symbol errors. Prevent by forbidding subagents from modifying barrel exports; resolve by renaming the newer module's colliding symbol with a module-specific prefix.
tags: [typescript, monorepo, parallel, subagents, barrel-exports, merge-conflicts, ts2308, symbol-collision, orchestrator]
date:
  created: "2026-07-30"
  knowledge-basis: "2026-07-30"
  last-used: "2026-07-30"
sources:
  - id: seodata-execute-workflow-2c23734
    resource: https://github.com/levonk/seodata/commit/2c23734
    title: 'seodata-execute.md: parallel dispatch, merge reconciliation, and export collision guidance'
  - id: execute-upsert-parallel-dispatch
    resource: https://github.com/levonk/skills-src/blob/main/src/current/skills/execution/execute-upsert/references/parallel-dispatch.md
    title: 'execute-upsert skill: parallel-dispatch reference (merge reconciliation protocol)'
---

# Parallel Export Collisions — Subagent Symbol Conflicts on Barrel Files

## Failure Mode

When an orchestrator dispatches parallel subagents to implement stories in
separate git worktrees, each subagent independently chooses symbol names
(export names, function names, class names) and modifies barrel export files
(`src/index.ts`, `src/lib.ts`) to register its exports. On merge, two
failure modes appear:

1. **Barrel file merge conflicts** — multiple stories add export lines to
   the same barrel file. Git cannot auto-merge additive changes to the same
   region, so the merge conflicts on the barrel file.
2. **Export name collisions** — two subagents independently choose the same
   symbol name (e.g., both export `FetchFn`). After merging both branches,
   TypeScript reports `TS2308: Module '...' has already exported a member
   named 'FetchFn'` or duplicate identifier errors.

### Symptoms

```typescript
// After merging two story branches:
// src/index.ts (barrel)
export { FetchFn } from './story-04/fetch';   // from story 04
export { FetchFn } from './story-07/fetch';   // from story 07 — COLLISION

// tsc --noEmit output:
// src/index.ts:12:8 - error TS2308: Module '"./story-07/fetch"' has already
//   exported a member named 'FetchFn'.
```

```bash
$ git merge story-07
# Auto-merging src/index.ts
# CONFLICT (content): Merge conflict in src/index.ts
```

### Root Cause

Parallel subagents have no shared state — they cannot see each other's
choices. When two subagents both need a fetch function, they both reach for
the obvious name (`FetchFn`, `fetch`, `createClient`). Without coordination,
they collide. The barrel file (`src/index.ts`) is the merge point where the
collision becomes visible.

This is distinct from **dependency version merge conflicts** (covered in
[pnpm and Nx Monorepo](pnpm-nx-monorepo.md)), which arise from `package.json`
version bumps across packages. Export collisions arise from independent
naming choices in parallel work.

## Practice

### Prevention: Forbid Subagents from Modifying Barrel Files

The orchestrator should tell every subagent:

> Do NOT modify `src/index.ts` (the barrel export file). The orchestrator
> will add your exports during merge reconciliation.

This eliminates the barrel file merge conflict entirely — each subagent
exports from its own module file, and the orchestrator reconciles the barrel
file once, after all merges, with full visibility into every story's chosen
names.

### Resolution: Rename with a Module-Specific Prefix

When a collision is detected after merge (TS2308 or duplicate identifier
errors), rename the **newer** module's colliding symbol with a
module-specific prefix:

```typescript
// Before (collision):
export { FetchFn } from './story-04/fetch';
export { FetchFn } from './story-07/fetch';

// After (renamed newer module):
export { FetchFn } from './story-04/fetch';
export { ActorFetchFn } from './story-07/fetch';  // prefixed with module context
```

Update all references to the renamed symbol **within that module only** —
do not touch the other story's module. The rename is scoped to the colliding
module's files.

### Decision: Which Symbol to Rename

| Situation | Rename |
|-----------|--------|
| Two stories collide on a generic name (`FetchFn`, `Client`) | Rename the newer (higher story ID) module's symbol |
| One name is domain-specific (`ActorFetchFn`) and one is generic (`FetchFn`) | Rename the generic one to be domain-specific |
| Both names are equally specific | Rename the one with fewer internal references (cheaper rename) |
| A story's name matches an existing exported name in the codebase (pre-parallel) | The new story's name must change — it's the addition, not the existing code |

### Merge Reconciliation Protocol

After all parallel subagents complete:

1. **Merge each story branch sequentially** with `git merge --no-ff`.
2. **Resolve barrel file conflicts by keeping BOTH sides' additions.** Never
   delete a story's export to resolve a conflict — if a story added an
   export, that export is needed.
3. **Run typecheck** across the entire project (not just individual modules).
4. **If TS2308 or duplicate identifier errors appear**, rename the newer
   module's colliding symbol with a module-specific prefix and update
   references within that module.
5. **Run full validation** (typecheck + tests + lint) across all packages
   affected by the merge.
6. **Commit the reconciliation** as a single merge commit documenting which
   symbols were renamed.

### When Parallel Dispatch Is Not Safe

Parallel dispatch is safe when stories touch **different files**. It is
unsafe when:

- Multiple stories modify the same barrel file (`src/index.ts`,
  `src/lib.ts`) — even with the "don't modify barrel" rule, stories may
  need to add types or utilities to shared files.
- Stories add to the same config file (e.g., route registrations, plugin
  registrations).
- Stories modify the same shared utility or test helper.

In these cases, serialize the stories — run them one at a time so each
subagent sees the prior story's changes in the barrel file.

## Prevention

1. **Tell subagents not to modify barrel files.** The orchestrator
   reconciles exports during merge. This is the single highest-impact
   prevention — it eliminates the barrel merge conflict and centralizes
   naming visibility.
2. **Design stories to be module-isolated.** Each story should add a new
   module file with its own exports, not modify a shared file. The barrel
   file is the only shared touchpoint, and the orchestrator owns it.
3. **Use domain-specific names from the start.** `ActorFetchFn` is better
   than `FetchFn` — it's unlikely to collide with another story's fetch
   function. Encourage subagents to prefix names with their module's domain.
4. **Run typecheck after every merge**, not just at the end. Catching a
   collision after merging 2 stories is cheaper than after merging 8.

## Detection

```bash
# After merging all parallel branches, run typecheck:
pnpm exec tsc --noEmit

# Look for:
# - TS2308: Module '...' has already exported a member named 'X'
# - error TS2451: Cannot redeclare block-scoped variable 'X'
# - error TS2440: Import declaration conflicts with local declaration of 'X'

# Check barrel file for duplicate exports:
grep -E '^export \{.*\}' src/index.ts | sort | uniq -d
```

## Related Concepts

- [pnpm and Nx Monorepo](pnpm-nx-monorepo.md) — covers dependency version
  merge conflicts (a different merge-conflict family). The `catalog:`
  protocol there prevents version drift; this concept prevents symbol name
  drift.
- [Explicit File Extensions](explicit-file-extensions.md) — the `.mts`/
  `.cts`/`.tsx` convention that makes module files unambiguous. Clear
  extensions reduce the chance of accidental cross-module name resolution
  during a merge.
- [Code Style](code-style.md) — the kebab-case file naming and named-export
  preference that this concept builds on for the module-specific prefix
  pattern.
