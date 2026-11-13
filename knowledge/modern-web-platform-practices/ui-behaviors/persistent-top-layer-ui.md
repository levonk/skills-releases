---
type: Practice
title: "Persistent Top Layer UI"
description: "When moving an open <dialog>, popover, or fullscreen element in the DOM using traditional methods like appendChild() or insertBefore(), the browser implicitly removes the element from the DOM and re-inserts it."
tags: [modern-web-platform, "ui-behaviors"]
date:
  created: "2026-11-13"
  knowledge-basis: "2026-11-13"
  last-used: "2026-11-13"
sources:
  - id: "ui-behaviors-persistent-top-layer-ui"
    resource: "https://github.com/GoogleChrome/modern-web-guidance/blob/4dd968349e54ca45a05dd5c818fb035c9054b022/skills/modern-web-guidance/guides/ui-behaviors/persistent-top-layer-ui.md"
    title: "Persistent Top Layer UI — GoogleChrome/modern-web-guidance"
    last_modified: "2026-11-10"
---

# Persistent Top Layer UI

When moving an open `<dialog>`, `popover`, or fullscreen element in the DOM using traditional methods like `appendChild()` or `insertBefore()`, the browser implicitly removes the element from the DOM and re-inserts it. This removal resets the state, causing open modals, popovers, and fullscreen elements to close abruptly.

To reparent top-layer elements without interrupting the user experience or closing them, use the atomic `moveBefore()` API instead.

### Reparenting open top-layer elements

`moveBefore()` takes two arguments: the node to move, and a reference node to insert before (or `null` to append to the end of the new parent).

```javascript
const newParent = document.getElementById('new-container');
const dialogElement = document.getElementById('my-dialog');

// MANDATORY: Use moveBefore to ensure the <dialog> or popover stays open.
// Passing null appends it to the end of newParent.
newParent.moveBefore(dialogElement, null);
```

### Fallback strategies

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

Since `moveBefore()` is a progressive enhancement, you MUST use feature detection before calling it. For older browsers, you will have to fallback to traditional reparenting.

**MANDATORY**: For `<dialog>` elements in unsupported browsers, the traditional move will close the dialog. If you need it to remain open, you must manually re-open it after the move.

```javascript
const targetParent = document.getElementById('target-container');
const popoverOrDialog = document.getElementById('my-top-layer-element');

// Check if moveBefore is supported
if ('moveBefore' in Element.prototype) {
  targetParent.moveBefore(popoverOrDialog, null);
} else {
  // Fallback: traditional move.
  // Note: This WILL close <dialog>, popover, and fullscreen elements.
  const wasOpen = popoverOrDialog.hasAttribute('open') || popoverOrDialog.matches(':popover-open');
  targetParent.insertBefore(popoverOrDialog, null);
  
  // Manually restore state if possible
  if (wasOpen && typeof popoverOrDialog.showModal === 'function') {
    popoverOrDialog.showModal();
  } else if (wasOpen && typeof popoverOrDialog.showPopover === 'function') {
    popoverOrDialog.showPopover();
  }
}
```

<!-- vim: set ft=markdown -->
