---
type: Practice
title: Micro-Interaction Patterns
description: Canonical embedded implementations for the 11 TypeUI micro-interaction categories — buttons, inputs, selection, modals, drawers, toasts, cards, lists, sliders, tooltips, and step navigation — each offline-usable with TypeUI cited as the pattern catalog.
tags: [micro-interactions, animation, patterns, css, javascript, frontend, implementation]
date:
  created: "2026-10-22"
  knowledge-basis: "2026-10-22"
  last-used: "2026-10-22"
sources:
  - id: typeui-micro-interactions
    resource: "https://www.typeui.sh/micro-interactions"
    title: "TypeUI — Micro Interactions catalog (113 interactions across 11 categories)"
  - id: mdn-prefers-reduced-motion
    resource: "https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion"
    title: "MDN — prefers-reduced-motion media feature"
  - id: web-dev-flip
    resource: "https://web.dev/articles/animations-guide"
    title: "web.dev — FLIP / composited-property animation techniques"
---

# Micro-Interaction Patterns

Canonical implementations for the 11 categories of the
[TypeUI Micro Interactions catalog](https://www.typeui.sh/micro-interactions),
embedded so they work offline. Snippets are framework-free CSS/JS — adapt to
the project's component model. The discipline for *when* to use each pattern
lives in [Micro-Interactions](micro-interactions.md); the animation
performance rules live in [CSS Fundamentals](css-fundamentals.md).

Every snippet below assumes the shared reduced-motion gate:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Buttons

**Press** — same-frame tactile feedback on activation.

```css
.button {
  transition: transform 80ms ease-out, background-color 150ms ease-out;
}
.button:active {
  transform: scale(0.96);
}
```

**Denied action shake** — signal a blocked action inline instead of opening a
dialog.

```css
@keyframes denied-shake {
  0%, 100% { transform: translateX(0); }
  20%, 60% { transform: translateX(-6px); }
  40%, 80% { transform: translateX(6px); }
}
.button.is-denied {
  animation: denied-shake 400ms ease-in-out;
}
```

```ts
// Apply the class, remove it on animationend so it can retrigger.
button.classList.add("is-denied");
button.addEventListener("animationend",
  () => button.classList.remove("is-denied"), { once: true });
```

**Hold to confirm** — destructive actions require a sustained press; early
release cancels.

```ts
const HOLD_MS = 600;
let timer: number;
button.addEventListener("pointerdown", () => {
  button.classList.add("is-holding"); // drives progress ring/fill via CSS
  timer = window.setTimeout(confirmAction, HOLD_MS);
});
["pointerup", "pointerleave", "pointercancel"].forEach((e) =>
  button.addEventListener(e, () => {
    clearTimeout(timer);
    button.classList.remove("is-holding");
  }));
```

**Loading states** (bounce dots / dual ring / bar wave) — swap the label for a
spinner and mark the control busy so assistive tech announces the work.

```html
<button class="button" aria-busy="true" disabled>
  <span class="spinner" aria-hidden="true"></span>
  <span class="sr-only">Saving…</span>
</button>
```

## Inputs

**Inline validation** — flag errors on blur/commit, not while typing.

```css
.field input:user-invalid {
  border-color: var(--color-danger);
}
.field .error-text {
  display: none;
}
.field input:user-invalid ~ .error-text {
  display: block;
}
```

**Invalid submit shake** — reuse `denied-shake` on the form's first invalid
field on submit, then move focus to it.

```ts
form.addEventListener("submit", (e) => {
  const firstInvalid = form.querySelector<HTMLElement>(":invalid");
  if (firstInvalid) {
    e.preventDefault();
    firstInvalid.classList.add("is-denied");
    firstInvalid.focus();
  }
});
```

**Autosave status** — debounce edits, show "Saving…" then "Saved" with a
timestamp; never save silently.

```ts
let saveTimer: number;
input.addEventListener("input", () => {
  clearTimeout(saveTimer);
  status.textContent = "Editing…";
  saveTimer = window.setTimeout(async () => {
    status.textContent = "Saving…";
    await persist(input.value);
    status.textContent = `Saved ${new Date().toLocaleTimeString()}`;
  }, 800);
});
```

**Strength fill / counter tick** — meter whose width and color derive from a
score; animate `transform: scaleX()` on a fill bar, not `width`.

## Selection

**Select-all cascade** — parent checkbox reflects and drives children;
`indeterminate` is a JS-only property, not an attribute.

```ts
function syncParent() {
  const boxes = [...group.querySelectorAll<HTMLInputElement>("input")];
  const checked = boxes.filter((b) => b.checked).length;
  parent.checked = checked === boxes.length;
  parent.indeterminate = checked > 0 && checked < boxes.length;
}
```

**Enable dependent action / enforce selection threshold** — disable the submit
control and show "0 selected · minimum 2" until the rule is met; animate the
count change so the feedback is noticed.

**Recalculate derived value** — totals and previews update on toggle; animate
the number change (brief highlight or count-tween) so the user connects the
cause (their click) to the effect (the new total).

**Filter chips** — toggling a chip filters the list immediately; the chip
itself gets a pressed state (`aria-pressed` + filled style), not a page
reload.

## Modals

**Block unsafe dismissal** — closing a dirty form loses work; intercept the
dismissal and demand intent.

```ts
function requestClose() {
  if (!isDirty) return close();
  dialog.classList.add("is-denied"); // shake, not close
  dismissGuard.hidden = false;       // inline "Discard changes?" confirm
}
backdrop.addEventListener("click", requestClose);
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") requestClose();
});
```

**Focus discipline** — trap focus inside while open, restore it to the
invoking element on close, mark the modal `role="dialog" aria-modal="true"`.
The shake only substitutes for the *close* — once the user confirms discard,
close immediately.

## Drawers

**Snap points** — drag is direct-manipulation; release settles to the nearest
stop.

```ts
const STOPS = [0, 0.5, 1]; // closed, half, full — fractions of drawer height
onDragEnd(offsetFraction) {
  const target = STOPS.reduce((a, b) =>
    Math.abs(b - offsetFraction) < Math.abs(a - offsetFraction) ? b : a);
  drawer.style.transition = "transform 250ms ease-out";
  drawer.style.transform = `translateY(${(1 - target) * 100}%)`;
  if (target === 0) close();
}
```

**Drag-linked backdrop** — backdrop opacity tracks open fraction continuously
during the drag (`backdrop.style.opacity = String(fraction * 0.5)`), so the
scrim never pops in ahead of the sheet.

**Keyboard alternative** — every drag affordance needs a button path:
chevron/close controls that drive the same snap function.

## Toasts

**Undo countdown** — the action commits when the countdown ends; "Undo" during
the window restores state. Prefer this over confirm-before dialogs for
reversible destructive actions.

```ts
function toastWithUndo(message: string, commit: () => void, undo: () => void) {
  const toast = render(`<div class="toast">${message}
    <button data-undo>Undo</button><div class="toast-bar"></div></div>`);
  const WINDOW_MS = 5000;
  let remaining = WINDOW_MS;
  let startedAt = Date.now();
  let timer = window.setTimeout(finish, remaining);
  function finish() { commit(); dismiss(toast); }
  // Pause the countdown on hover/focus so the undo window is real —
  // track remaining time, keyed by pause source so overlapping
  // hover + keyboard focus can't double-decrement or orphan a timer.
  const pauseSources = new Set<string>();
  function pause(source: string) {
    pauseSources.add(source);
    if (pauseSources.size > 1) return; // already paused
    clearTimeout(timer);
    remaining -= Date.now() - startedAt;
  }
  function resume(source: string) {
    pauseSources.delete(source);
    if (pauseSources.size > 0) return; // still held by another source
    startedAt = Date.now();
    timer = window.setTimeout(finish, remaining);
  }
  toast.addEventListener("pointerenter", () => pause("pointer"));
  toast.addEventListener("pointerleave", () => resume("pointer"));
  toast.addEventListener("focusin", () => pause("focus"));
  toast.addEventListener("focusout", () => resume("focus"));
  toast.querySelector("[data-undo]")!.addEventListener("click", () => {
    clearTimeout(timer); undo(); dismiss(toast);
  });
}
```

```css
.toast-bar {
  animation: toast-countdown 5s linear forwards;
  transform-origin: left;
}
/* Keep the visual countdown in sync with the paused JS timer. */
.toast:hover .toast-bar,
.toast:focus-within .toast-bar {
  animation-play-state: paused;
}
@keyframes toast-countdown {
  from { transform: scaleX(1); }
  to { transform: scaleX(0); }
}
```

**Promise toast morph** — one toast mutates pending → success/error; never
stack a second toast for the same operation.

**Swipe dismissal** — horizontal drag dismisses; a close button is the
keyboard/AT path. Toasts live in an `aria-live="polite"` region.

## Cards

**Flip card** — rotate on `transform` only; keep both faces in the DOM and
toggle `aria-hidden` so the back is reachable.

```css
.flip-inner { transition: transform 300ms ease-out; transform-style: preserve-3d; }
.flipped .flip-inner { transform: rotateY(180deg); }
.face { backface-visibility: hidden; }
.face.back { transform: rotateY(180deg); }
```

**Expandable / shared-element** — use FLIP (First, Last, Invert, Play): record
the rect, apply the layout change, invert with a transform, transition to
identity.

```ts
const first = card.getBoundingClientRect();
card.classList.add("is-expanded");
const last = card.getBoundingClientRect();
const dy = first.top - last.top, sx = first.width / last.width;
card.style.transformOrigin = "top left";
card.style.transform = `translateY(${dy}px) scaleX(${sx})`;
requestAnimationFrame(() => {
  card.style.transition = "transform 250ms ease-out";
  card.style.transform = "";
});
```

**Action reveal** — actions appear on hover *and* on focus-within; touch
layouts show them persistently — never bury the only path to an action behind
hover.

## Lists

**Accordion** — never animate a hardcoded `max-height`; it eases wrongly and
breaks when content changes. Measure `scrollHeight`, or animate a grid row.

```css
.accordion { display: grid; grid-template-rows: 0fr;
  transition: grid-template-rows 200ms ease-out; }
.accordion.open { grid-template-rows: 1fr; }
.accordion > .inner { overflow: hidden; }
```

**Reorder** — drag the item; on drop, FLIP the *siblings* so they slide out
of the way instead of teleporting.

**Archive item with undo** — animate the row collapsing (transform + opacity),
then hand the undo contract to the [undo countdown toast](#toasts). The item
is not removed from the model until the countdown commits.

## Sliders

**Stepped snap / magnetic detents** — free scrub while dragging, snap to the
nearest stop on release; detents within ~4px pull the value.

```ts
// Convert the ~4px detent into value units via the track's px-per-unit ratio.
function snap(value: number, stops: number[], pxPerUnit: number) {
  const DETENT_PX = 4;
  const nearest = stops.reduce((a, b) =>
    Math.abs(b - value) < Math.abs(a - value) ? b : a);
  return Math.abs(nearest - value) * pxPerUnit <= DETENT_PX ? nearest : value;
}
```

**Tooltip thumb** — the value label follows the thumb via `transform`, visible
during drag and on focus.

**Rubber band overdrag** — past the ends, apply diminishing resistance
(`offset / 3`), then spring back on release; overdrag must never accumulate
into the value.

**Keyboard parity** — `role="slider"` with `aria-valuemin/max/now`; arrow keys
step, PageUp/PageDown jump. Native `<input type="range">` gets all of this
free — style it, don't rebuild it.

## Tooltips

**Warm delay group** — first hover waits (~400ms intent check); once one
tooltip in a group is open, siblings open instantly — the group "stays warm"
until the pointer leaves the region entirely.

```ts
let groupWarm = false, warmTimer: number;
function show(tip: HTMLElement) {
  clearTimeout(warmTimer);
  const open = () => { tip.hidden = false; groupWarm = true; };
  groupWarm ? open() : (warmTimer = window.setTimeout(open, 400));
}
function hide(tip: HTMLElement) {
  tip.hidden = true;
  warmTimer = window.setTimeout(() => (groupWarm = false), 300); // cool-down
}
```

**Link preview / hover card** — same intent delay; cards must be hoverable
themselves (pointer can move onto them) and focusable (keyboard users get the
card on focus, dismiss with `Esc`). Tooltip content is supplementary — never
put the only copy of required information inside one.

## Step Navigation

**Stepper progress** — the bar tweens between steps; completed steps show a
check and remain clickable for return; future steps are disabled; the current
step is `aria-current="step"`.

```css
.stepper .bar {
  transition: transform 300ms ease-out;
  transform-origin: left;
}
.stepper[data-step="2"] .bar { transform: scaleX(0.5); }
.stepper[data-step="3"] .bar { transform: scaleX(1); }
```

**Step validation** — advancing past a step validates it first; a failed step
gets the denied shake and an inline error, not a block on the whole flow.
**Return to completed** — revisiting a completed step preserves its data;
never wipe later steps just because the user went back to look.

## Reduced-Motion & Input-Parity Checklist

- [ ] Every animation gated behind `prefers-reduced-motion` — motion removed,
  feedback kept (instant state change or opacity-only fade).
- [ ] Every hover trigger has a focus equivalent; `Esc` dismisses overlays.
- [ ] Every drag has a keyboard alternative (buttons, arrows, menu items).
- [ ] Every async loop has a terminal state (success, error, timeout) — no
  infinite spinners.
- [ ] `aria-live` regions announce toasts/status; `aria-busy` marks working
  controls; `aria-current` marks stepper position.

## Related Concepts

- [Micro-Interactions](micro-interactions.md) — when and why to use these
  patterns; the catalog map and selection discipline
- [CSS Fundamentals](css-fundamentals.md) — animation/transition primitives
  and performance rules these snippets build on
- [Tailwind v4 Features](tailwind-v4-features.md) — utility classes for the
  same transitions and transforms
- [HTMX Hypermedia-First](htmx-hypermedia-first.md) — these patterns are the
  local-feedback layer; page state still swaps via hypermedia where possible
