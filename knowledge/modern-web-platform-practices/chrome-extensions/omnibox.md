---
type: Practice
title: "Omnibox Integration"
description: "chrome.omnibox — register an address-bar keyword, supply suggestions on onInputChanged, and dispatch the chosen result on onInputEntered."
tags: [modern-web-platform, "chrome-extensions"]
date:
  created: "2026-11-13"
  knowledge-basis: "2026-11-13"
  last-used: "2026-11-13"
sources:
  - id: "chrome-extensions-omnibox"
    resource: "https://github.com/GoogleChrome/modern-web-guidance/blob/4dd968349e54ca45a05dd5c818fb035c9054b022/skills/chrome-extensions/references/extensions/omnibox.md"
    title: "Omnibox Integration — GoogleChrome/modern-web-guidance"
    last_modified: "2026-11-10"
---

# Omnibox Integration

## Setup

```json
{
  "omnibox": { "keyword": "wiki" }
}
```

User types `wiki` + Space in the address bar to activate.

## Providing Suggestions

```js
chrome.omnibox.onInputChanged.addListener(async (text, suggest) => {
  if (text.length < 2) return;

  try {
    const response = await fetch(
      `https://en.wikipedia.org/w/api.php?action=opensearch&search=${encodeURIComponent(text)}&limit=5&format=json`
    );
    const [, titles, , urls] = await response.json();

    const suggestions = titles.map((title, i) => ({
      content: urls[i],
      description: `${title} - <url>${urls[i]}</url>`
    }));

    suggest(suggestions);
  } catch (err) {
    console.error('Search failed:', err);
  }
});
```

## Handling Selection

```js
chrome.omnibox.onInputEntered.addListener((text, disposition) => {
  const url = text.startsWith('http') ? text
    : `https://en.wikipedia.org/wiki/${encodeURIComponent(text)}`;

  switch (disposition) {
    case 'currentTab':
      chrome.tabs.update({ url });
      break;
    case 'newForegroundTab':
      chrome.tabs.create({ url });
      break;
    case 'newBackgroundTab':
      chrome.tabs.create({ url, active: false });
      break;
  }
});
```

## Description Formatting

Suggestions support XML-like formatting:
- `<url>text</url>` — renders as URL style
- `<match>text</match>` — bold match highlighting
- `<dim>text</dim>` — dimmed/secondary text

## Default Suggestion

```js
chrome.omnibox.onInputChanged.addListener((text, suggest) => {
  chrome.omnibox.setDefaultSuggestion({
    description: `Search Wikipedia for "<match>${text}</match>"`
  });
  // ... fetch and suggest
});
```

## Required host_permissions

If fetching suggestions from an API, declare:
```json
{
  "host_permissions": ["https://en.wikipedia.org/*"]
}
```

<!-- vim: set ft=markdown -->
