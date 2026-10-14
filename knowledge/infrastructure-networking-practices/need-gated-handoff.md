---
type: Practice
title: Need-Gated Human Handoff
description: Probe managed-host state for every install requirement before involving a human; automate satisfiable requirements and hand off only the demonstrably unmet delta — open just the settings panes still missing a grant.
tags: [infrastructure, ansible, provisioning, idempotency, tcc, macos, user-handoff, rustdesk]
date:
  created: "2026-10-13"
  knowledge-basis: "2026-10-13"
  last-used: "2026-10-13"
sources:
  - id: infrahub-rustdesk-client-darwin
    resource: shared/active/02-config/ansible/roles/rustdesk-client/tasks/darwin.yml
    title: infrahub — rustdesk-client role Darwin path (one-wizard-pass)
---

# Need-Gated Human Handoff

## Failure Mode

Provisioning flows that involve a human at the keyboard (privacy grants,
sign-ins, 2FA) fail in two shapes:

- **All-manual** — the installer leaves every step to the human, even the
  ones a script can satisfy, so each deploy is a full wizard.
- **Blanket prompt** — the automation finishes, then interrupts the user
  with the full settings tour anyway — including panes whose toggles are
  already enabled — because it never checked which needs were actually met.

Both erode trust and make re-runs noisy: every run looks like a first run.

## Practice

Split each install requirement by who can satisfy it, probe before
interrupting, and hand off only the unmet delta.

1. **Automate the satisfiable** — package install, config files, service
   registration (launchd plists, systemd units). These converge silently
   and idempotently.
2. **Probe the requirement state** — read the authoritative store (TCC.db
   for macOS privacy grants, `launchctl print` for loaded jobs) and map
   each requirement to granted or missing.
3. **Hand off the delta only** — open only the System Settings panes
   lacking an allowed grant, and name each remaining toggle in the run
   summary.
4. **Degrade toward the human** — an unverifiable probe (Full Disk Access
   required, db unreadable) counts as "can't confirm", not "granted".
   Reopening a pane beats silently skipping a needed grant.
5. **Provide an escape flag** — an inventory var (e.g.
   `rustdesk_client_macos_permissions_granted`) lets operators hard-skip
   the handoff on hosts where probing is known-incomplete.

### Reference Implementation

`roles/rustdesk-client/tasks/darwin.yml` (infrahub) — the "one wizard pass"
for RustDesk on macOS:

- installs the Homebrew cask, writes `RustDesk2.toml` for the root daemon
  and the console user's session agent, installs and bootstraps the
  launchd Daemon/Agent
- probes the system and console-user TCC databases for RustDesk clients
  with an allowed grant, per service (`kTCCServiceScreenCapture`,
  `kTCCServiceAccessibility`, `kTCCServiceListenEvent`)
- opens only the privacy panes still missing a grant; skips the handoff
  entirely when all three are detected

### When the Human Really Can't Be Replaced

Some grants are un-automatable by design — TCC writes are SIP-protected,
and PPPC profiles require MDM enrollment. The pattern doesn't fight that:
it removes every requirement *except* the genuinely human ones, then makes
the remaining ask minimal and exactly targeted.

## Related Concepts

- [Infrastructure Variable Consolidation](infrastructure-variable-consolidation.md)
  — consolidated vars keep probe targets (paths, job labels) out of
  hardcoded literals
- [Pre-Prime and Probe](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/pre-prime-and-probe.md)
  — the general principle this page instantiates for managed hosts
