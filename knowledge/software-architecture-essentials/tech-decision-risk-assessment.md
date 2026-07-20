---
type: Practice
title: Tech Decision Risk Assessment
description: Ordered risk hierarchy for evaluating technology decisions. Risk from highest to lowest: novel work > end-user impact > public API impact > tech-giant-only territory > modifying 3rd-party source > running 3rd-party service > new SaaS integration > others-have-done-it > new internal service > changing integrations > new 3rd-party package > using 3rd-party package directly > using more of an existing package > facade-wrapped package > new internal app > new internal micro-service > updating internal API > new internal package > new internal module > new internal algorithm > new internal class > new data structure > new exception > new interface > new function > nested conditional > new conditional > short circuit > new error/critical assertion > new statement > warning assertion > debug-time assertion > new constant > dependency updates (major > minor; security > capability > drift-avoidance).
tags: [risk, decision-making, architecture, evaluation, dependencies, anti-patterns]
timestamp: 2026-07-18T00:00:00Z
---

# Tech Decision Risk Assessment

## Failure Mode

Evaluating technology choices by gut feel, by "what I'm familiar with", or by
single-axis arguments (cost, DX, speed) without an explicit risk ordering.
This produces decisions where the cheaper option is chosen because its
upfront cost looks small, while its tail risk (migration on a live system,
lock-in, unbounded blast radius) is ignored. It also produces decisions where
a low-risk change is rejected because "it's a change" — flattening the risk
spectrum so a new constant and a new public API integration are treated as
equally scary.

## Practice

When evaluating a technology decision, place the change on the ordered risk
hierarchy below. Higher = more risk = requires more justification, more
verification, and more reluctance. Lower = less risk = should be the default
path when it satisfies the requirement.

The hierarchy is total: a change at level N is riskier than a change at level
N+1, all else equal. When a decision spans multiple levels (e.g., "add a new
3rd-party package AND modify its source"), the decision's risk is the
**highest** level it touches, not the average.

### The risk hierarchy (highest to lowest)

1. **Doing something nobody has ever done before** — novel work. No reference
   implementation, no battle-tested pattern, no prior art to consult. The
   failure mode is unknown unknowns.
2. **End-user / customer UI impact** — changes that affect what users see,
   touch, or sign in to. Auth migration on paying users is the canonical
   example: lockout risk, churn, trust damage, support load. Tail risk is
   unbounded for a small SaaS.
3. **Public API impact** — changes to a published API contract that external
   consumers depend on. Breaking changes cascade beyond your control.
4. **Doing something only tech giants have done** — patterns that exist only
   inside Google / Amazon / Meta whitepapers. You can read about them but
   cannot copy them — the surrounding infrastructure (SRE org, custom
   hardware, internal tooling) does not exist at your scale.
5. **Having to modify 3rd-party software / source code** — forking a library
   to fix or change it. You now own the fork: rebasing upstream, security
   patches, diverging behavior. High maintenance tax.
6. **Having to run a 3rd-party service** — self-hosting an open-source service
   (Postgres, Kafka, Vault, a self-hosted LLM). You own operations: upgrades,
   backups, incident response, scaling, security patching.
7. **Additional 3rd-party as-a-service integrations added** — new vendor
   dependency (Stripe, Plaid, Supabase, OpenAI). Adds a billing, availability,
   and compliance surface. Vendor outage = your outage.
8. **Doing something only others have done** — patterns that exist in the
   wild but outside the tech-giant tier. Reference implementations exist; you
   can copy a known-good pattern. Risk is integration, not novelty.
9. **Creating a new internal service** — a new service your team owns end to
   end. New operational surface, new deploy pipeline, new monitoring.
10. **Changing existing integrations** — modifying how you talk to an existing
    3rd-party (changing Stripe webhook shape, switching OAuth scopes).
    Backward-compat risk, migration risk.
11. **Additional 3rd-party package added** — new dependency in `package.json`
    / `Cargo.toml` / `pyproject.toml`. Supply-chain risk, transitive dep risk,
    drift risk.
12. **Using a 3rd-party package directly** — calling the package's API
    directly in your code. Coupling risk: refactoring upstream leaks into
    your call sites.
13. **Using more of an existing 3rd-party package** — adopting a new feature
    of a package you already depend on. Lower risk than a new package (the
    dependency already exists), but new surface area.
14. **Using a 3rd-party package via a local facade / abstraction** — wrapping
    the package behind your own interface (`PaymentProvider`,
    `StorageProvider`, `AuthProvider`). Contains the coupling; swap cost is
    bounded.
15. **Creating a new internal app** — a new top-level application in the
    monorepo. New deploy target, but no external surface.
16. **Creating a new internal micro-service** — a new internal service with a
    network boundary. Operational surface, but no external consumers.
17. **Updating internal API** — changing an internal contract. Blast radius
    is the codebase, not external consumers.
18. **Creating a new internal package** — a new library in the monorepo. New
    module boundary, but internal consumers only.
19. **Creating a new internal module in our own app** — a new module inside an
    existing app. No new deploy target, no new boundary.
20. **Creating a new internal algorithm** — a complex algorithm (cache, sort,
    scheduler, rate limiter). Correctness risk, edge-case risk, performance
    risk.
21. **Creating a new internal class** — a new class / module / struct. Single
    responsibility, testable in isolation.
22. **Creating a new internal data structure** — a new struct / type / record.
    Shape risk, serialization risk.
23. **Creating a new exception** — a new error type. Naming risk, handling
    risk.
24. **Creating an internal interface** — a new contract. Abstraction risk
    (wrong abstraction is worse than no abstraction).
25. **Creating a new internal function** — a new function. Pure logic, testable.
26. **Creating another nested conditional** — adding a branch inside an
    existing conditional. Cyclomatic complexity risk.
27. **Creating a new internal conditional** — a new `if` / `switch` at the
    current level. Readability risk.
28. **Short circuit** — `||`, `&&`, `??`, optional chaining. Minimal.
29. **Creating a new error / critical breaking production assertion error** —
    `assert(...)` in production code. Fail-loud risk: if the assertion is
    wrong, you break production.
30. **Creating a new statement** — a single line of code. Minimal.
31. **Creating a warning assertion** — `console.warn` / log-only assertion.
    Non-blocking.
32. **Creating a debug-time assertion** — `assert(...)` gated behind
    `NODE_ENV !== 'production'` / `cfg!(debug_assertions)`. Zero production
    risk.
33. **Creating a new constant** — a new `const`. Effectively zero risk.

### Dependency updates (orthogonal axis)

Dependency updates carry risk on a separate axis (version bump severity ×
motivation):

- **Major version update** > **minor version update** (major can break APIs;
  minor should not)
- Within each: **for security** > **for capability** > **to avoid drift**
  (security is non-negotiable; capability is feature-driven; drift avoidance
  is hygiene)

A major-version security update is higher risk than a minor-version
capability update, but the security motivation may justify accepting the
risk. A major-version drift-avoidance update is the weakest justification for
accepting major-version risk — prefer pinning and updating on a real trigger.

### Functional programming style (orthogonal axis)

When choosing how to write a unit of code, the risk ordering is:

- **Pure functions** (no side effects, referentially transparent) — lowest
  risk, most testable
- **Immutable data** (read-only variables, persistent data structures) —
  low risk, no aliasing bugs
- **Static-wide variables** (module-level mutable state) — medium risk,
  shared mutable state across the module
- **Local-only mutable variables** — medium risk, contained to the function
- **Mutable variables with wide scope** — higher risk, aliasing and
  ordering bugs
- **Read-only variables** — lowest risk within their scope

Prefer pure functions and immutable data. Reach for mutable state only when
the performance or clarity case is clear, and keep the scope as narrow as
possible.

### Adding features vs. updating dependencies

- **Adding features** — new code paths, new behavior. Risk per the hierarchy
  above (where does the new code land?).
- **Updating dependencies** — risk per the dependency-update axis above.

These are independent: adding a feature may require a dependency update, in
which case the total risk is the max of the two, plus the integration risk of
the combination.

## How to use this hierarchy

1. **Place the proposed change on the hierarchy.** Identify the highest level
   it touches.
2. **Place the alternative on the hierarchy.** If the alternative touches a
   lower level, it is the lower-risk path — prefer it unless there is a
   concrete reason the higher-risk path is necessary.
3. **Justify deviations.** If you choose the higher-risk path, name the
   specific reason (e.g., "passkey-first onboarding is a product value that
   the lower-risk path cannot provide"). Vague justifications ("it's
   cleaner", "it's more modern") are not sufficient.
4. **Size verification to risk.** Higher-risk changes get more verification:
   tests, contract checks, migration plans, rollback plans. Lower-risk
   changes get lighter verification.
5. **Reassess upfront cost with AI-assisted dev.** A change that was
   expensive in 2022 (writing a session-variable RLS middleware) may be
   cheap in 2026 with AI-assisted dev. The risk hierarchy does not change,
   but the cost axis does — see
   [AI + Human Timeline Estimates](ai-human-timeline-estimates.md).

## Worked example: better-auth vs. Supabase Auth

| Path | Highest level touched | Tail risk |
|------|----------------------|-----------|
| Use Supabase Auth now, migrate to better-auth later for passkey-first | Level 2 (end-user / customer UI impact) — auth migration on paying users | Unbounded: lockout, churn, trust damage |
| Use better-auth now with session-variable RLS middleware | Level 14 (facade / abstraction) + Level 20 (new internal algorithm for the middleware) | Bounded: middleware correctness, verifiable with tests |

The lower-risk path is better-auth now, even though it has more upfront code,
because the higher-risk path (migration) has unbounded tail risk. See
[Auth Provider Selection](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/auth-provider-selection.md)
for the full decision.

## Related Concepts

- [Root-Cause First](root-cause-first.md) — Diagnose before fixing; this
  hierarchy is for choosing between fixes, not for skipping diagnosis
- [Architecture Philosophy](philosophy.md) — Domain-based modular architecture
  keeps changes low on the hierarchy (internal module, not public API)
- [AI + Human Timeline Estimates](ai-human-timeline-estimates.md) — The cost
  axis that interacts with this risk axis
- [Auth Provider Selection](https://github.com/levonk/skills-releases/blob/main/knowledge/api-auth-payment-practices/auth-provider-selection.md)
  — Worked example of this hierarchy in action

## Citations

[1] `internal-docs/feature/2026/07/bookkeeping-saas-mvp/` — bookkeep-saas
    decision dialogue (better-auth vs. Supabase Auth, PocketBase evaluation)
