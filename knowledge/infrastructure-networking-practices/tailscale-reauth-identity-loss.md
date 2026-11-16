---
type: Practice
title: Tailscale Re-Auth Identity Loss
description: Interactive re-login after a tailscaled outage registers a NEW user-owned node instead of reviving the tagged one — silently losing ACL grants while `tailscale ping` still succeeds.
tags: [tailscale, tailnet, acl, tags, reauth, connectivity, diagnosis]
date:
  created: "2026-11-15"
  knowledge-basis: "2026-11-15"
  last-used: "2026-11-15"
sources:
  - id: infrahub-postiz-deploy-20261115
    resource: levonk/infrahub postiz deployment session 2026-11-15
    title: observed incident
---

# Tailscale Re-Auth Identity Loss

## Failure Mode

A `tailscaled` daemon dies and its saved profile is stale (`NeedsLogin` — the
machine key is no longer valid server-side). An interactive browser re-auth
registers a **brand-new node** (`<host>-1`, user-owned `user@`) rather than
reviving the old one. Tags live on the node object in the control server, so
the new node has **none** — and tailnet ACLs drop all TCP to/from tagged
devices.

The trap: `tailscale ping <peer>` **still succeeds** (TSMP/ICMP isn't ACL-gated
like TCP), so the host looks "reachable" while every service on it times out.

## Diagnostic

All-TCP-fails-but-ping-works is the signature. Confirm the identity column:

```bash
tailscale status        # new node shows 'user@', peers show 'tagged-devices'
nc -z -w4 <peer-ip> 22  # FAIL on every tagged peer, not just one host
```

If TCP fails to *all* tagged peers, the problem is the local node's
identity/tags — not the remote host's firewall. Do NOT start reconfiguring
remote firewalls on this evidence.

## Practice

1. **Re-auth with a tagged auth key when possible** — `tailscale up --auth-key <key>`
   (a key minted for the right `tag:*` devices) preserves tagging instead of
   creating a user-owned node. Interactive login always produces a user-owned
   registration.
2. **If interactive re-auth already happened**: in the admin console, tag the
   `<host>-1` node with the old node's tags, rename it back, and delete the
   stale orphan. Grants return immediately.
3. **After any re-auth**: verify `tailscale status` shows the expected
   identity (`tagged-devices`) before assuming connectivity is back.
4. **Housekeeping**: stale offline nodes accumulate and hold the old name —
   delete them so renames don't collide.

## Notes

- Windows/Linux service rules can be perfectly correct (`Profile: Any`) while
  traffic still dies at the tailnet layer — check tailnet identity first.
- This incident surfaced during the Postiz deployment: LAN IP worked, tailnet
  FQDN timed out on every port; the Windows firewall had never been the issue.
