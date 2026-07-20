---
type: Practice
title: Java Security — Dependency Scanning, SAST, and Deprecated Security APIs
description: Scan dependencies with OWASP Dependency-Check or Snyk, run SAST with SpotBugs/FindSecBugs, avoid Security Manager for new code (JEP 411), and never ship hardcoded secrets.
tags: [java, security, dependency-scan, sast, spotbugs, jep-411, secrets]
timestamp: 2026-07-17T00:00:00Z
---

# Java Security

## Failure Mode

Java applications ship with known-vulnerable dependencies, insecure
deserialization, or hardcoded credentials because security checks are manual and
run too late in the pipeline.

## Symptoms

- `log4j` or `spring-core` CVEs are discovered in production images.
- `ObjectInputStream.readObject()` is used on untrusted data.
- Credentials appear in `application.properties` committed to git.
- The Java Security Manager is used as a sandbox (deprecated in JEP 411).

## Practice

### Dependency Scanning

- Run OWASP Dependency-Check, Snyk, or Mend in CI on every build.
- Fail builds on CVSS ≥ 7.0 unless explicitly suppressed with rationale.
- Pin base image tags and rebuild images when base images are patched.

### SAST

- Use SpotBugs with the FindSecBugs plugin.
- Enable in CI and treat new high-severity findings as build failures.
- Run `mvn spotbugs:check` or `./gradlew spotbugsMain`.

### Secrets

- Use Spring Cloud Config, AWS Secrets Manager, Vault, or environment variables
  loaded at runtime — never commit secrets to source.
- For container builds, use BuildKit secret mounts (`--mount=type=secret`) to
  inject credentials without baking them into layers.

### Deprecated Security Manager

- JEP 411 deprecated the Security Manager for removal.
- Do not write new code that relies on `System.setSecurityManager`.
- Use OS-level sandboxing (containers, seccomp, AppArmor) instead.

## Citations

[1] [JEP 411: Deprecate the Security Manager for Removal](https://openjdk.org/jeps/411)
[2] [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
[3] [FindSecBugs](https://find-sec-bugs.github.io/)
