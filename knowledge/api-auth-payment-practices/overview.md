---
type: Synthesis
title: API Auth Payment Practices Overview
description: Synthesis of SaaS authentication, payment processing, multi-tenant isolation, encrypted token storage, tier-based feature gating, and webhook handling practices.
tags: [auth, payment, stripe, supabase, multi-tenant, rls, saas, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: feat-202607170936-bookkeeping-saas-mvp
    resource: "internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md"
    title: "bookkeep-saas"
  - id: tasks-bookkeeping-saas-mvp-06-002-auth
    resource: "internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-06-002-auth.md"
    title: "bookkeep-saas"
  - id: tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial
    resource: "internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md"
    title: "bookkeep-saas"
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.



# API Auth Payment Practices Overview

This bundle documents practices for SaaS authentication, payment processing, and
multi-tenant data isolation. Each concept was extracted from the bookkeep-saas
PRD and task specifications — the hard constraints and architectural decisions
that ensure secure auth, reliable billing, and tenant data isolation.

## The Auth-Payment Stack

```
auth-provider-selection → multi-tenant-rls → payment-provider → token-storage → tier-gating → webhooks
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Auth | [Auth Provider Selection](auth-provider-selection.md) | Auth migration on paying users, missing passkey-first onboarding, vendor lock-in |
| Isolation | [Multi-Tenant RLS](multi-tenant-rls.md) | Cross-tenant data leakage, shared schema contamination |
| Payment | [Payment Provider Interface](payment-provider-interface.md) | Stripe lock-in, billing rewrite for new providers |
| Secrets | [Encrypted Token Storage](encrypted-token-storage.md) | Token leakage, credential exposure in logs/client |
| Tiers | [Tier Feature Gating](tier-feature-gating.md) | Ungated features, no trial flow, missing dunning |
| Webhooks | [Webhook Idempotency](webhook-idempotency.md) | Duplicate processing, missing audit trail, unverified signatures |

> **Note**: [supabase-auth-pattern.md](supabase-auth-pattern.md) is the
> historical auth pattern. It has been superseded by
> [auth-provider-selection.md](auth-provider-selection.md), which chooses
> better-auth as the auth provider while keeping Supabase Postgres for
> storage-engine RLS via session variables. The historical page is retained
> for context on why the original PRD specified Supabase Auth.

## Hard Constraints

- **No third-party AI APIs** for client financial data (FTC Safeguards Rule)
- **Multi-tenant from day one** — Postgres RLS on every table, enforced at the
  storage engine via session variables (see
  [Auth Provider Selection](auth-provider-selection.md))
- **Plaid/Stripe access_tokens encrypted at rest**, never logged, never exposed to client
- **No CPA-reserved activities** — no audited/certified financial statements
- **Auth method preference** — passkey-first > passkey > Google > Apple >
  magic link > username/password + 2FA; email always collected for recovery
  (see [Auth Provider Selection](auth-provider-selection.md))

## Scope

This bundle covers **SaaS auth, payment, and tenant isolation**. It does **not**
cover:

- Frontend stack conventions — see
  [frontend-stack-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/frontend-stack-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md).
- Secret management infrastructure — see
  [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md).

## Sources

- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/feat-202607170936-bookkeeping-saas-mvp.md` — bookkeep-saas PRD (1325 lines)
- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-06-002-auth.md` — auth story (174 lines)
- `internal-docs/feature/2026/07/bookkeeping-saas-mvp/tasks/tasks-bookkeeping-saas-mvp-09-001-billing-tiers-trial.md` — billing story (236 lines)

## Related Knowledge Bundles

- [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md) —
  Infrastructure-level secret management
- [frontend-stack-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/frontend-stack-practices/overview.md) —
  Frontend conventions for auth/payment UI
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — Security audit
  practices for auth/payment code
- [software-architecture-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/overview.md)
  — Tech decision risk hierarchy and AI + human timeline estimates that
  drove the auth-provider-selection decision

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

