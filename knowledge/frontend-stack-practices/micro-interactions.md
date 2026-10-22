---
type: Practice
title: Micro-Interactions
description: Purposeful single-task feedback animations — anatomy (trigger, rules, feedback, loops & modes), when to add them, implementation standards (duration, easing, transform/opacity, reduced motion, keyboard parity), the 11-category TypeUI pattern catalog, and anti-patterns.
tags: [micro-interactions, animation, interaction-design, ux, feedback, frontend, motion, accessibility]
date:
  created: "2026-10-22"
  knowledge-basis: "2026-10-22"
  last-used: "2026-10-22"
sources:
  - id: typeui-micro-interactions
    resource: "https://www.typeui.sh/micro-interactions"
    title: "TypeUI — Micro Interactions catalog (113 interactions across 11 categories, live previews + implementation prompts)"
  - id: saffer-microinteractions
    resource: "Microinteractions: Designing with Details — Dan Saffer, O'Reilly 2013"
    title: "Anatomy model — trigger, rules, feedback, loops & modes"
  - id: mdn-prefers-reduced-motion
    resource: "https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion"
    title: "MDN — prefers-reduced-motion media feature"
  - id: web-dev-animations-guide
    resource: "https://web.dev/articles/animations-guide"
    title: "web.dev — animations guide (composited transform/opacity properties)"
---

# Micro-Interactions

## Failure Mode

Two failure shapes dominate. The first is the **dead UI**: an interface where
actions produce no visible acknowledgment — a button that gives no press
feedback, a form that silently autosaves, a delete that removes a row with no
chance to undo. Users repeat actions, distrust state, and file "did it work?"
support tickets. The second is **gratuitous motion**: animations added for
decoration that slow task completion, play on every render, ignore
`prefers-reduced-motion`, or animate layout properties and jank the page. Both
failures come from the same root — treating motion as ornament instead of
communication.

## Practice

**Every state change that matters gets a micro-interaction; every
micro-interaction earns its place.** A micro-interaction is a single-task,
contained feedback loop tied to one user action or one state change — not a
page transition, not a loading screen, not decoration. If you cannot name the
user action it answers and the information it communicates, cut it.

### Anatomy

Every micro-interaction has four parts (Saffer's model):

1. **Trigger** — what starts it: a user action (click, hover, type, drag) or a
   system event (save completes, validation fails, new data arrives).
2. **Rules** — what happens while it runs: the logic (hold ≥600ms to confirm,
   shake only when the action is blocked, undo window is 5s).
3. **Feedback** — what the user perceives: the animation, sound, haptic, or
   state change that communicates the rule outcome.
4. **Loops & Modes** — what happens over time: does it repeat (spinner while
   pending), does it change the rules permanently (after first use, shorten
   the delay), does it expire (undo toast fades and the action commits).

Spec all four before implementing. Most micro-interaction bugs are rule bugs
— the animation is fine but the trigger or the mode is wrong.

### When to Add One

- **Acknowledgment** — the action registered: press states, hold-to-confirm,
  copy-to-clipboard confirmation.
- **State change** — something the user caused is now different: toggles,
  selection updates, derived-value recalculation.
- **Wayfinding** — the user needs to know where they are or what changed:
  stepper progress, list reorder, expanding panels.
- **Error prevention and recovery** — stop a mistake before it happens or make
  it cheap to undo: denied-action shake, invalid-submit shake, undo countdown
  toasts, block-unsafe-dismissal modals.
- **Waiting** — work is in progress and the user should not retry: loading
  spinners, upload progress, promise toasts that morph pending → result.

If a candidate interaction serves none of these, it is decoration — decline
it or demote it to a static visual detail.

### Implementation Standards

- **Duration**: 100–200ms for small feedback (press, hover, icon swap);
  200–300ms for state changes (expand, fade, slide); 300–500ms only for
  larger spatial moves (drawer snap, shared-element transitions). Never exceed
  ~500ms — feedback that takes longer reads as a page transition and blocks
  the user.
- **Easing**: `ease-out` for elements arriving (start fast, land soft);
  `ease-in` for elements leaving; short springs
  (`cubic-bezier(0.34, 1.56, 0.64, 1)` at ≤200ms) only for playful,
  reversible feedback. Linear easing is for progress bars and spinners only.
- **Properties**: animate `transform` and `opacity` — they composite on the
  GPU. Never animate `width`, `height`, `top`, `left`, or `margin` in the
  hot path; use FLIP transforms instead (see
  [Micro-Interaction Patterns](micro-interaction-patterns.md)). Follow the
  performance rules in [CSS Fundamentals](css-fundamentals.md).
- **Reduced motion**: gate every animation behind
  `@media (prefers-reduced-motion: reduce)` — replace motion with instant
  state changes or opacity-only fades. Reduced motion never means reduced
  *feedback*; the state change must still be visible.
- **Input parity**: whatever pointer users can trigger, keyboard users must
  reach — focus-visible states mirror hover, `Esc` dismisses what `Esc` should
  dismiss, drag has a keyboard alternative.
- **Restraint budget**: one micro-interaction per element per moment. Two
  simultaneous animations on one control reads as a glitch.

### The TypeUI Pattern Catalog

[TypeUI's Micro Interactions](https://www.typeui.sh/micro-interactions) is the
canonical external catalog: 113 named micro-interactions across 11 categories,
each with a live preview (light/dark, mobile layouts) and a copyable
implementation prompt for AI coding tools. Previews are free; copying prompts
requires TypeUI Creative. Use it to pick the right named pattern before
writing your own — the vocabulary ("denied action shake", "warm delay group",
"select-all cascade") is worth more than any single implementation.

| Category | Answers | Representative patterns |
|----------|---------|-------------------------|
| [Buttons](https://www.typeui.sh/micro-interactions/buttons) | Did my action register? What is happening? | Press, denied action shake, hold to confirm, swap state icon, toggle reaction state, bounce dots / dual ring / bar wave loading, count ramp, upload progress |
| [Inputs](https://www.typeui.sh/micro-interactions/inputs) | Is my input valid? Did it save? | Adornments, prefix reveal, inline validation, invalid submit shake, autosave status, strength fill, mask fill, chip pop-in, build derived value |
| [Selection](https://www.typeui.sh/micro-interactions/selection-controls) | What did my choice change? | Checkbox, select-all cascade, recalculate derived value, update derived progress, filter chips, enable dependent action, enforce selection threshold, animate completed item |
| [Modals](https://www.typeui.sh/micro-interactions/modals) | Is my work safe? | Block unsafe dismissal, confirmation, validation, drag dismissal, unsaved-changes guard |
| [Drawers](https://www.typeui.sh/micro-interactions/drawers) | How much of this panel do I need? | Snap points, drag-linked backdrop, expand shared surface, collapse persistent panel |
| [Toasts](https://www.typeui.sh/micro-interactions/toasts) | Did it work? Can I undo it? | Undo countdown toast, promise toast morph, swipe dismissal |
| [Cards](https://www.typeui.sh/micro-interactions/cards) | What is inside this item? | Flip card, expandable, action reveal, stacked deck cycle, shared-element transition |
| [Lists](https://www.typeui.sh/micro-interactions/lists) | Where did that item go? | Accordion, reorder, move between groups, archive item with undo, insert, preview |
| [Sliders](https://www.typeui.sh/micro-interactions/sliders) | What value am I on? | Stepped snap, tooltip thumb, tick highlights, dual-thumb range, before/after compare, snap carousel, rubber band overdrag, scrubber preview, magnetic detents |
| [Tooltips](https://www.typeui.sh/micro-interactions/tooltips) | What is this thing? | Hover card, link preview, warm delay group |
| [Step navigation](https://www.typeui.sh/micro-interactions/navigation) | Where am I in this flow? | Stepper progress, step validation, return to completed steps, remaining time |

Canonical implementations for each category live in
[Micro-Interaction Patterns](micro-interaction-patterns.md) — embedded so they
work offline; use TypeUI for the full set, the live previews, and the
ready-made implementation prompts.

### Pairing With the Interaction Model

Micro-interactions sit *below* the page-level interaction model decision in
[HTMX Hypermedia-First](htmx-hypermedia-first.md). Most micro-interactions
answer a need for feedback faster than a server round-trip allows —
locally-derived, sub-100ms *perceived* feedback — the exact "Signal 1" case
where a round-trip is the wrong tool, so they live in client-side CSS/JS
regardless of whether the page is HTMX or SPA. They do not argue for an SPA:
an HTMX page still needs press states, invalid-submit shakes, and toast undo,
all of which are local DOM/CSS work layered on top of hypermedia swaps. Scope
any JS to the element that needs the interaction; do not let feedback code
expand into client-side state management.

## Anti-Patterns

- **Animation without information** — motion that communicates nothing the
  user needed to know (the cut test above).
- **Animating layout properties** — `width`/`height`/`top` transitions that
  force reflow; use `transform` + `opacity` or FLIP.
- **Hardcoded `max-height` accordions** — eases wrongly and breaks the moment
  content changes; measure `scrollHeight` or use `grid-template-rows: 0fr→1fr`.
- **Instant or absent undo** — destructive actions that commit immediately
  with no recovery affordance; prefer an undo countdown over a confirm dialog.
- **Modal for every mistake** — blocking the user to report an error the UI
  could have prevented (denied shake, inline validation) or could let them
  undo (toast).
- **Keyboard-black-hole interactions** — hover-only reveals, drag-only
  dismissal, pointer-only confirmation with no focus/keyboard path.
- **Reduced-motion = no feedback** — removing the animation and the
  information with it; keep the state change, drop the motion.
- **Spinner forever** — async feedback with no timeout, no error state, and
  no way to cancel or retry.
- **Decorating slow work** — adding motion to mask a slow operation instead
  of showing honest progress; if it takes >1s, show progress, not vibes.

## Related Concepts

- [Micro-Interaction Patterns](micro-interaction-patterns.md) — embedded
  canonical implementations for all 11 categories
- [HTMX Hypermedia-First](htmx-hypermedia-first.md) — page-level interaction
  model; micro-interactions are the local-feedback layer beneath it
- [CSS Fundamentals](css-fundamentals.md) — animation primitives, performance
  rules, and `prefers-reduced-motion` mechanics
- [Tailwind v4 Features](tailwind-v4-features.md) — transition/transform
  utilities used to express these patterns in utility-first styling
- [Code Style Conventions](code-style-conventions.md) — conventions for the
  JS/TS the interaction logic is written in
