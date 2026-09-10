---
type: Taxonomy
title: Authorization Terminology Taxonomy
description: Six-axis classification for authorization terminology — Administration, Model, Policy, Information, Decision, Enforcement. Familiar labels (RBAC, ABAC, PBAC, MAC, DAC, ReBAC, ACL) each answer one axis, not the whole system.
tags: [authorization, access-control, rbac, abac, pbac, mac, dac, rebac, acl, taxonomy, architecture, pep, pdp, pip, pap]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-08-31"
  last-used: "2026-09-04"
sources:
  - id: idpro-2026-authz-terminology
    resource: "https://idpro.org/authorization-terminology-is-a-mess-lets-fix-it/"
    title: "Authorization Terminology is a Mess: Let's Fix It"
    author: "Andrea Chiarelli"
  - id: idpro-2026-pbac-not-model
    resource: "https://idpro.org/is-pbac-an-authorization-model/"
    title: "Is Policy-Based Access Control (PBAC) an Authorization Model?"
    author: "Andrea Chiarelli"
  - id: mohamed-2022-authz-review
    resource: "https://doi.org/10.1108/IJWIS-04-2022-0077"
    title: "A systematic literature review for authorization and access control: definitions, strategies and models"
    author: "Mohamed, Auer, Hofer, Küng"
---


# Authorization Terminology Taxonomy

## Problem

Authorization terminology has accumulated for decades across access control
research, identity vendors, and standards bodies. MAC, DAC, RBAC, ABAC, ReBAC,
ACL, and PBAC are routinely compared as if they were peers on a single flat
list of "authorization models." They are not. Most of these terms answer
**different questions** and do not compete with each other at all. Treating
them as interchangeable alternatives causes category errors — choosing "PBAC
vs RBAC" is like choosing "a kitchen vs a recipe."

## The Six Axes

Every authorization system can be described by answering six independent
questions. Each familiar label is an answer to exactly one axis, not a label
for the whole system. A real system's full description is a **tuple across all
six axes**, not a single word.

| Axis | Question | Familiar labels that live here |
|------|----------|-------------------------------|
| Administration | Who sets the rules? | MAC, DAC, Hybrid |
| Model | What data type drives the decision? | ACL, RBAC, ABAC, ReBAC |
| Policy | What shape does the rule take? | hardcoded, JSON/YAML, XACML/Rego/Cedar, DB row |
| Information | Where does decision-relevant data come from? | wired-in, token-based, looked-up, environmental |
| Decision | How and where is the decision computed? | inline code, dedicated library, centralized engine (PBAC) |
| Enforcement | How and where is the decision enforced? | inline code, dedicated middleware, distributed (gateway/sidecar/proxy) |

### 1. Authorization Administration — who sets the rules?

Before a rule can be evaluated, someone has to have the authority to write it.
This axis is independent of what the rules actually say.

- **Centralized** — a security team or administrator defines rules for
  everyone. This is the pattern behind **MAC** (Mandatory Access Control):
  access is determined by a central authority, not by the resource owner.
- **Decentralized** — the owner of a resource decides who else can access it.
  This is **DAC** (Discretionary Access Control): the classic "share this file
  with these people" pattern.
- **Hybrid** — some rules come from a central authority, others from
  individual resource owners, layered together.

A role-based system can be centrally administered, owner-administered, or both
— it is still RBAC either way. Administration strategy is genuinely
independent of authorization model.

### 2. Authorization Model — what data type drives the decision?

This is the axis most people mean when they say "authorization model." It
describes the specific kind of information a decision checks each time it
runs.

- **Identity-based (ACL)** — the decision checks whether the specific subject
  appears on a list attached to the object.
- **Role-based (RBAC)** — the decision checks whether the subject holds a role
  that has been granted the requested permission.
- **Attribute-based (ABAC)** — the decision checks attributes of the subject,
  object, action, or environment against a rule (department = "finance",
  clearance >= "secret", time between 9 AM and 5 PM).
- **Relationship-based (ReBAC)** — the decision checks the relationship between
  subject and object, often by traversing a graph (is this user a member of
  the team that owns this document?).

Depending on which academic source you read, ACL and RBAC can be described as
special cases of ABAC, where the attribute in question happens to be identity
or role membership. These four categories are the most useful cut for a
working taxonomy, not a claim of mathematical mutual exclusivity.

### 3. Authorization Policy — what shape does the rule take?

Once a model is chosen, it still has to be written down as a concrete
artifact. This axis matters because two systems can share the same
authorization model (both RBAC) while differing completely in maintainability,
auditability, and who is allowed to change the rules.

- Hardcoded conditionals in application code.
- A structured document (JSON, YAML) loaded and interpreted at runtime.
- A declarative policy language purpose-built for authorization — XACML, Rego
  (Open Policy Agent), or Cedar.
- A row in a database table.

### 4. Authorization Information — where does the data come from?

A rule is only as good as the data it is evaluated against. Separate what the
rule depends on from how the system actually gets its hands on it.

- **Wired in** — the data is already available in the application's normal
  request flow, no extra lookup required.
- **Token-based** — the data arrives as claims in a JWT or similar credential,
  populated by the identity provider at issuance time.
- **Looked up** — the application queries a database, directory, or external
  service at decision time.
- **Environmental** — the data describes the context of the request itself
  rather than the subject or object: time, location, device posture, network.

Knowing that a decision depends on "time of day" is a modeling question.
Knowing that the request has to make a network round-trip to a directory
service to get it is an architecture question, with real consequences for
latency and failure modes.

### 5. Authorization Decision — how and where is the decision computed?

**PBAC lives here**, not on the "authorization model" axis. Centralizing the
decision point into a policy engine is an architectural choice about *where*
evaluation happens, and it is compatible with any of the authorization models:
a PBAC engine can evaluate role-based rules, attribute-based rules, or a mix.

- **Wired into application code** — an if statement or a framework-native
  permission check inline with the business logic.
- **A dedicated library or module** — decision logic factored out but still
  running inside the application process.
- **A centralized policy engine** — a separate service that receives context
  and returns a decision, often shared across many applications (PBAC).

### 6. Authorization Enforcement — how and where is the decision enforced?

A decision only matters if something acts on it, and that action does not have
to happen in the same place the decision was made.

- **Wired into application code** — the same code path that made the decision
  also acts on it.
- **Dedicated middleware** — a framework-level component intercepts the
  request based on the decision.
- **Distributed enforcement** — a gateway, sidecar, or proxy enforces
  decisions at the network edge, independent of the application itself.

A system enforcing ABAC decisions through an API gateway and a system
enforcing ABAC decisions through inline middleware are both, unambiguously,
ABAC. They just made different choices about where enforcement lives.

## The PAP/PIP/PDP/PEP Mapping

The five-stage request lifecycle maps onto access control architecture
vocabulary:

| Stage | Vocabulary | Axis above |
|-------|-----------|-----------|
| Someone defines the rules | Policy Administration Point (PAP) | Administration |
| Some data feeds the decision | Policy Information Point (PIP) | Information |
| A decision gets computed | Policy Decision Point (PDP) | Decision |
| The decision gets enforced | Policy Enforcement Point (PEP) | Enforcement |

The Policy axis (rule shape) and Model axis (data type) are split out because
a model can be instantiated by more than one kind of concrete policy artifact.

## Putting It Together

A real authorization system's full description is a tuple across all six axes:

- Centralized administration (MAC)
- Role-based model (RBAC)
- JSON policy documents
- Token-based information
- A shared policy engine (PBAC architecture)
- Gateway-level enforcement

That is a coherent, common real-world setup, and every label in it is accurate
simultaneously, because each one answers a different question. The confusion in
most authorization discussions comes from picking one label per system and
treating it as exhaustive.

## Practical Guidance

- **Pick the authorization model** based on what your access rules naturally
  depend on (roles, attributes, relationships).
- **Separately, pick the architecture** (where decisions get made and
  enforced) based on your operational constraints (how many services need to
  share policy, how much latency you can tolerate, who needs to audit or
  change rules).
- Those are two separate decisions with two separate sets of tradeoffs.
  Bundling them into a single choice ("we're doing PBAC" or "we're doing RBAC")
  hides half of what actually needs deciding.

## Related Concepts

- [Auth Provider Selection](auth-provider-selection.md) — the auth-provider
  decision that determines where identity claims (Information axis) originate
- [Multi-Tenant RLS](multi-tenant-rls.md) — Postgres RLS as a storage-engine
  Enforcement Point (PEP), independent of the Decision axis
- [Encrypted Token Storage](encrypted-token-storage.md) — token-based
  Information axis data protected at rest
- [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security/overview.md) —
  infrastructure-level secret management relevant to the Information axis
