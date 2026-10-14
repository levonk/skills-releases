---
type: Practice
title: Pre-Prime and Probe
description: Automate every installation requirement a script can satisfy, probe the target's state for needs already met, and interrupt the human only for the demonstrably unmet remainder. A well-designed installer converges the machine, not the user's attention.
tags: [architecture, provisioning, installation, idempotency, user-experience, automation, handoff, probing]
date:
  created: "2026-10-13"
  knowledge-basis: "2026-10-13"
  last-used: "2026-10-13"
sources:
  - id: infrahub-rustdesk-client-darwin
    resource: shared/active/02-config/ansible/roles/rustdesk-client/tasks/darwin.yml
    title: infrahub — rustdesk-client role Darwin path (one-wizard-pass)
---

# Pre-Prime and Probe

## The General Rule

When installing or provisioning software, classify every requirement the
software needs into three buckets before running:

1. **Automatable** — satisfy it programmatically: install the package, write
   the config file, register the service. Never ask the human to do what a
   script can do reliably and idempotently.
2. **Probed-and-skipped** — before asking for anything, check whether the
   need is already met. A satisfied need produces no prompt, no pane, no
   interruption.
3. **Human-required** — the requirement genuinely needs a person (consent
   dialogs, 2FA, hardware switches). Reduce the ask to exactly the unmet
   delta: open only the panes for the grants still missing, name the
   toggles to flip, then get out of the way.

The interruption budget is spent only on needs the probe cannot confirm.

### Why Probe Instead of Assume

Blind re-prompting trains the user to distrust the installer. If the wizard
demands steps that are already done, the human learns the tool lies — and
the next real prompt gets ignored or fat-fingered. Probing makes the run
idempotent *and* honest: re-runs converge silently until the system truly
needs a decision.

### Probe Hierarchy

1. **Read the authoritative state store** — permission databases (macOS
   `TCC.db`), service registries (`launchctl print`, `systemctl show`),
   config files on disk, API status endpoints. Do not infer state from "we
   installed it earlier" — infer it from the source of truth.
2. **Distinguish "granted" from "unknown"** — an unreadable probe (missing
   Full Disk Access, permission denied, empty output) is not proof of
   absence. Treat unverifiable needs as unmet: reopen the pane rather than
   silently skip a required grant.
3. **Map needs to UI surfaces** — when the human must act, open exactly the
   settings panes, dialogs, or URLs for the unmet subset. Opening all three
   panes when two grants already exist wastes the interruption.

### Where It Applies

- OS permission grants (macOS TCC, Windows UAC, Android runtime permissions)
- App installs with a post-install wizard (services, daemons, agents)
- Account sign-ins and license activations that need a human credential
- Hardware or physical steps (insert key, flip switch) in provisioning flows

## Anti-Patterns

- **Blanket handoff** — dumping the entire wizard on the user because one
  step needs them. Automate the other nine.
- **Assume-absent prompting** — opening settings panes without probing
  first; on re-runs the user sees already-enabled toggles and loses
  confidence in the tool.
- **Assume-granted skipping** — treating an unreadable probe as "granted"
  and silently skipping a required step; the install is broken with no
  signal.
- **Silent automation** — automating everything with no summary, so the
  human can't tell what needs them from what was done. End with a report
  that names the remaining delta.

## See Also

- [Make Operations Idempotent](make-operations-idempotent.md) — probing is
  what makes convergence honest: a re-run that can *detect* the desired
  state can also prove it absent.
- [Fail-Fast Explicit Errors](fail-fast-explicit-errors.md) — when a
  required probe itself fails, surface that instead of degrading.
- [Need-Gated Human Handoff](https://github.com/levonk/skills-releases/blob/main/knowledge/infrastructure-networking-practices/need-gated-handoff.md)
  — the infrastructure instance: an Ansible probe of macOS TCC.db gates
  which privacy panes open for the human.
