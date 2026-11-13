---
type: Practice
title: "Declarative Net Request (Content Filtering)"
description: "Add \"declarativeNetRequestFeedback\" permission to use onRuleMatchedDebug (dev only)."
tags: [modern-web-platform, "chrome-extensions"]
date:
  created: "2026-11-13"
  knowledge-basis: "2026-11-13"
  last-used: "2026-11-13"
sources:
  - id: "chrome-extensions-declarative-net-request"
    resource: "https://github.com/GoogleChrome/modern-web-guidance/blob/4dd968349e54ca45a05dd5c818fb035c9054b022/skills/chrome-extensions/references/extensions/declarative-net-request.md"
    title: "Declarative Net Request (Content Filtering) — GoogleChrome/modern-web-guidance"
    last_modified: "2026-11-10"
---

# Declarative Net Request (Content Filtering)

## Setup

```json
{
  "permissions": ["declarativeNetRequest"],
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "rules/rules.json"
    }]
  }
}
```

Add `"declarativeNetRequestFeedback"` permission to use `onRuleMatchedDebug` (dev only).

## Rule Format

`rules/rules.json`:
```json
[
  {
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "doubleclick.net",
      "resourceTypes": ["script", "image", "xmlhttprequest", "sub_frame"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "google-analytics.com",
      "resourceTypes": ["script", "xmlhttprequest"]
    }
  }
]
```

### Rule Fields

- `id`: Unique integer per rule
- `priority`: Higher priority rules win conflicts
- `action.type`: `"block"`, `"redirect"`, `"allow"`, `"modifyHeaders"`, `"allowAllRequests"`, `"upgradeScheme"`
- `condition.urlFilter`: Pattern matching (supports `*`, `||`, `|`, `^`)
- `condition.resourceTypes`: Array of resource types to match

### URL Filter Patterns

| Pattern | Matches |
|---------|---------|
| `"doubleclick.net"` | Any URL containing "doubleclick.net" |
| `"||doubleclick.net"` | Domain starts with doubleclick.net |
| `"||example.com/ads/*"` | Specific path pattern |
| `*://*.tracking.com/*` | Subdomain matching |

### Resource Types

`main_frame`, `sub_frame`, `stylesheet`, `script`, `image`, `font`, `object`, `xmlhttprequest`,
`ping`, `csp_report`, `media`, `websocket`, `webtransport`, `webbundle`, `other`

## Dynamic Rules (runtime)

```js
// Add rules at runtime
await chrome.declarativeNetRequest.updateDynamicRules({
  addRules: [{
    id: 1000,
    priority: 1,
    action: { type: 'block' },
    condition: { urlFilter: 'ads.example.com' }
  }],
  removeRuleIds: [] // IDs to remove
});
```

## Tracking Blocked Requests

`onRuleMatchedDebug` only works in dev (unpacked) and requires `declarativeNetRequestFeedback`:

```js
chrome.declarativeNetRequest.onRuleMatchedDebug.addListener((info) => {
  // info.request, info.rule
});
```

For production, count via `webRequest` (observe only) or maintain counts with `webNavigation`:

```js
// Alternative: Use webRequest to observe (requires host_permissions)
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    // Count requests to known tracking domains
    if (isTrackerDomain(new URL(details.url).hostname)) {
      incrementBlockCount(details.tabId);
    }
  },
  { urls: ["<all_urls>"] }
);
```

## Limits

- Static rules: 30,000 guaranteed per extension, plus an additional 300,000 from a pool shared between extensions
- Dynamic rules: 30,000
- Session rules: 5,000

<!-- vim: set ft=markdown -->
