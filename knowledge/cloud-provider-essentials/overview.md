---
type: Synthesis
title: Cloud Provider Essentials Overview
description: Synthesis of cloud provider best practices across AWS, Azure, GCP, and OCI — covering the shared landscape of storage, database, networking, compute, and security services, plus IaC implementation patterns with Pulumi and Terraform.
tags: [cloud, aws, azure, gcp, oci, infrastructure, best-practices, pulumi, terraform, iac, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-18"
  last-used: "2026-07-18"
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


# Cloud Provider Essentials Overview

This bundle documents best practices for the four major cloud providers —
AWS, Azure, GCP, and OCI — along with Infrastructure as Code (IaC)
implementation patterns for AWS using both Pulumi and Terraform. Each concept
page provides detailed, environment-tiered (prototyping / testing / production)
guidance for storage, database, networking, compute, and security services.

## The Cloud Provider Landscape

```
aws-essentials ──┬── aws-pulumi-patterns
                 └── aws-terraform-patterns

azure-essentials ── gcp-essentials ── oci-essentials
```

The four provider-specific concept pages cover the same service categories
(storage, database, networking, compute, security) but with provider-native
terminology and tooling. The two IaC pattern pages provide concrete
implementations for the AWS best practices described in `aws-essentials.md`.

## Cross-Provider Patterns

Despite different terminology and tooling, all four providers share a common
set of architectural patterns:

| Pattern | AWS | Azure | GCP | OCI |
|---------|-----|-------|-----|-----|
| Object storage | S3 | Blob Storage | Cloud Storage | Object Storage |
| Managed SQL | RDS / Aurora | Azure SQL | Cloud SQL | Autonomous Database |
| NoSQL | DynamoDB | Cosmos DB | Firestore | — |
| Virtual network | VPC | VNet | VPC | VCN |
| Virtual machines | EC2 | VMs | Compute Engine | Compute Instances |
| Private service access | VPC Endpoints | Service Endpoints | Private Google Access | Service Gateway |
| Load balancing | ELB / ALB | Load Balancer | Cloud Load Balancing | Network Load Balancer |
| DDoS protection | Shield | Azure DDoS | Cloud Armor | OCI DDoS Protection |
| Key management | KMS | Key Vault | Cloud KMS | OCI KMS |
| IAM | IAM | Azure AD / RBAC | Cloud IAM | OCI IAM |

### Shared Best Practices Across Providers

1. **Cost optimization via tiering**: All providers offer storage tiers (hot /
   cool / archive) with significant cost savings at the expense of retrieval
   latency. Lifecycle policies automate transitions.

2. **Private service access**: Every provider offers a mechanism to access
   managed services without traversing the public internet — VPC Endpoints
   (AWS), Service Endpoints (Azure), Private Google Access (GCP), and Service
   Gateways (OCI). These avoid NAT Gateway data transfer charges.

3. **Environment-tiered configurations**: Each concept page provides
   prototyping (minimize cost), testing (full observability), and production
   (reliability & compliance) configurations with estimated monthly costs.

4. **Security hardening**: All providers support least-privilege IAM,
   customer-managed encryption keys, audit logging, and MFA enforcement.
   Production environments require all of these.

5. **Spot/preemptible instances**: All providers offer significant discounts
   (70%+) for interruptible workloads, suitable for batch processing and
   fault-tolerant testing.

6. **Always Free tiers**: AWS, Azure, GCP, and OCI all offer free tiers for
   prototyping — small VMs, limited storage, and minimal database capacity.

### AWS-Specific IaC Patterns

The AWS best practices in `aws-essentials.md` are accompanied by two parallel
IaC implementations:

- **[AWS Pulumi Patterns](aws-pulumi-patterns.md)** — TypeScript-based IaC,
  recommended for TypeScript projects. Covers VPC endpoints, cost anomaly
  detection, Organizations setup, resource tagging, tag enforcement with AWS
  Config, and more.

- **[AWS Terraform Patterns](aws-terraform-patterns.md)** — HCL-based IaC,
  for teams using the Terraform ecosystem. Provides identical implementations
  of the same patterns, allowing teams to choose their preferred IaC tool.

Both files implement the same patterns described in `aws-essentials.md`,
including:

- VPC Gateway Endpoints for S3 (avoiding NAT Gateway charges)
- Cost Anomaly Detection setup
- AWS Organizations with Service Control Policies
- Resource tagging with common tag schemas
- Tag enforcement with AWS Config rules

## How the Concepts Fit Together

```
                    ┌─────────────────────────────────────┐
                    │       Cloud Provider Landscape       │
                    └───────────┬─────────────────────────┘
                                │
           ┌────────────────────┼────────────────────┐
           │                    │                    │
     ┌─────▼─────┐      ┌──────▼──────┐      ┌──────▼──────┐
     │    AWS     │      │   Azure     │      │    GCP      │
     │ Essentials │      │ Essentials  │      │ Essentials  │
     └─────┬──────┘      └─────────────┘      └─────────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐ ┌───▼────────┐
│ Pulumi  │ │  Terraform  │
│ Patterns│ │  Patterns   │
└─────────┘ └────────────┘

           ┌─────────────────────┐
           │       OCI           │
           │    Essentials       │
           └─────────────────────┘
```

The provider-specific pages (`aws-essentials.md`, `azure-essentials.md`,
`gcp-essentials.md`, `oci-essentials.md`) each provide self-contained guidance
for their respective platforms. The IaC pattern pages (`aws-pulumi-patterns.md`,
`aws-terraform-patterns.md`) provide concrete code implementations for the AWS
best practices, referencing back to `aws-essentials.md` for the architectural
context.

## Scope

This bundle covers **cloud provider infrastructure best practices** —
storage, database, networking, compute, and security service configurations
across AWS, Azure, GCP, and OCI, plus IaC implementation patterns for AWS
using Pulumi and Terraform. It does **not** cover:

- Container deployment patterns — see
  [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md).
- Networking patterns for VPN/zero-trust infrastructure — see
  [infrastructure-networking-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/infrastructure-networking-practices/overview.md).
- Application-level security — see
  [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md).

## Related Knowledge Bundles

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) — Container
  deployment patterns for cloud (base image selection, multi-stage builds,
  runtime hardening, registry cache strategy).
- [infrastructure-networking-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/infrastructure-networking-practices/overview.md)
  — Networking patterns (zero-trust platforms, multi-exit node architecture,
  backup connectivity, infrastructure variable consolidation).

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

