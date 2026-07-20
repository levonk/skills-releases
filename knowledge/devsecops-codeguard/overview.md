---
type: Synthesis
title: DevSecOps Codeguard Overview
description: Synthesis of DevSecOps codeguard practices — C memory safety, credential detection, crypto governance, certificate validation, SSH hardening, and infrastructure security audits. Container-specific hardening and Dockerfile practices live in the container-best-practices bundle.
tags: [devsecops, security, codeguard, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# DevSecOps Codeguard Overview

This bundle documents practices that prevent the most common security defects
from reaching production. Each concept was extracted from real codeguard rules
and security audit playbooks — banned C functions that cause buffer overflows,
hardcoded credentials that leak secrets, deprecated crypto algorithms that
break confidentiality, misconfigured certificates that fail TLS, and SSH
daemons that accept weak authentication. Container-specific hardening and
Dockerfile practices have been moved to the
[container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) bundle,
which covers runtime hardening, Node.js in containers, and Dockerfile best
practices in greater depth.

## The DevSecOps Pipeline

```
source-code → crypto → certificates → credentials → runtime → audit
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Source code | [Safe C Functions](safe-c-functions.md) | Buffer overflows from unbounded memory/string operations |
| Crypto | [Crypto Algorithm Governance](crypto-algorithm-governance.md) | Broken confidentiality from MD5, SHA-1, RC4, DES, deprecated OpenSSL APIs |
| Certificates | [Digital Certificate Validation](digital-certificate-validation.md) | TLS failures from expired certs, weak keys, SHA-1 signatures, self-signed certs in prod |
| Secrets | [Hardcoded Credentials Detection](hardcoded-credentials-detection.md) | Credential leaks from AWS/Stripe/Google/GitHub/JWT keys committed to source |
| Runtime | [SSH Hardening](ssh-hardening.md) | Brute-force attacks, root login via password, weak key types |
| Audit | [Security Audit Playbook](security-audit-playbook.md) | Drift from hardening baseline, stale container images, unenforced firewall |

## Scope

This bundle covers **code-level security and runtime security audits** — the
practices that ship in source code, SSH configurations, and Ansible audit
playbooks. Container-specific hardening (runtime controls, Dockerfile
patterns, Node.js in containers) lives in the
[container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) bundle. It
does **not** cover:

- Container runtime hardening, Dockerfile best practices, or Node.js container
  production hardening — see
  [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md).
- Application-level authentication and authorization patterns (OAuth flows,
  RBAC design) — separate bundle.
- Network security architecture (zero-trust, segmentation) — separate bundle.
- Security monitoring and incident response (SIEM, SOAR) — separate bundle.
- Cloud provider security services (GuardDuty, Security Hub) — separate bundle.

## Relationship to Source Rules

The codeguard rules in job-aide (`.devin/rules/codeguard-*.md`) are
always-on AI agent rules that enforce these practices during code generation
and review. This bundle provides the **generalizable knowledge** behind those
rules — the "why" that explains what each rule prevents and how to apply it
correctly in context.

The infrahub `final-audit.yml` playbook operationalizes these practices as
post-deployment validation. This bundle's [Security Audit Playbook](security-audit-playbook.md)
captures the pattern so it can be reapplied to new environments.

## Sources

The initial concepts were extracted from:

- job-aide `.devin/rules/` codeguard rules (safe C functions, hardcoded
  credentials, crypto algorithms, digital certificates)
- infrahub `shared/active/02-config/ansible/playbooks/final-audit.yml` security
  audit playbook (SSH hardening, firewall, fail2ban, Docker daemon hardening)
- infrahub `AGENTS.md` security audit guidelines and SSH hardening best
  practices

See each concept's `# Citations` section for the specific source files.

## Compounding

New lessons from future security work — CVE post-mortems, audit findings,
new tooling, or new attack vectors — should be filed as new concept pages.
The trigger for adding a concept is: a security incident, a failed audit, a
new CVE that reveals a practice the bundle doesn't yet cover, or a new
codeguard rule added to job-aide. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `secrets-management.md` — vault patterns, KMS integration, runtime secret
  retrieval vs. baked-in credentials
- `dependency-supply-chain.md` — lockfile pinning, integrity verification,
  private registries, SLSA provenance
- `ci-cd-pipeline-security.md` — protected branches, signed commits,
  ephemeral runners, security gates (SAST/SCA/DAST)
- `virtual-patching.md` — WAF/IPS/ModSecurity for temporary CVE mitigation
- `c-toolchain-hardening.md` — compiler flags (PIE, RELRO, CFI), linker
  hardening, checksec verification in CI

## Related Knowledge Bundles

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) —
  Dockerfile best practices and container runtime hardening that complement
  the codeguard container rules.
- [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)
  — TypeScript project conventions that interact with credential detection,
  crypto usage, and ESLint security rules.
- [java-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/java-best-practices/overview.md) — Java security
  practices (dependency scanning, SAST, JEP 411) that complement codeguard rules.

## Citations

[1] `.devin/rules/codeguard-1-safe-c-functions.md` — job-aide
[2] `.devin/rules/codeguard-1-hardcoded-credentials.md` — job-aide
[3] `.devin/rules/codeguard-1-crypto-algorithms.md` — job-aide
[4] `.devin/rules/codeguard-1-digital-certificates.md` — job-aide
[5] `shared/active/02-config/ansible/playbooks/final-audit.yml` — infrahub
[6] `AGENTS.md` (Security Audit Guidelines) — infrahub
