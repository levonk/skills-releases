---
type: Deny List
title: IP Logger Deny List
description: Stable IP logger domains denied in the Devin CLI config to prevent IP harvesting via fetched URLs.
tags: ['deny-list', 'ip-logger', 'security', 'anti-tracking']
timestamp: 2026-07-11T16:30:00Z
---

# IP Logger Deny List

Stable IP logger domains denied in the Devin CLI config to prevent IP harvesting via fetched URLs.

## Denied Domains

The following 22 IP logger domains are denied in
the Devin CLI configuration:

```toon
[22]: 2no.co,blackscreen.app,blasze.com,blasze.tk,countertracker.com,grabify.com,grabify.link,ip-tracker.org,ip-tracking.com,ipfingerprint.com,ipgrab.org,ipgrabber.com,ipgrabber.org,iplogger.com,iplogger.info,iplogger.net,iplogger.org,iplogger.ru,iptrackeronline.com,ps3cfw.com,trackip.net,yourmonstersize.com
```

## Rationale

IP loggers are stable, well-known domains used for IP harvesting via
unsolicited URL fetches. Unlike general malware/phishing domains (which are
dynamic and better handled by DNS-level filtering), IP logger domains are
stable enough to maintain a static deny list.

## Notes

- This is a deny list, not an allow list — these domains are explicitly blocked
- General malware/phishing domains are NOT included here; they are too dynamic
  for a static list and are better handled by DNS-level filtering
- See [Overview](overview.md) for format details and maintenance workflow

# Citations

[1] [TOON Format](https://toonformat.dev/)
[2] [Devin CLI config](https://github.com/levonk/dotfiles/blob/main/home/current/dot_config/devin/config.json)
