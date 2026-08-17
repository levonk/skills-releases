---
type: Practice
title: Brand Guide and Design Tokens — Single Source of Truth for Visual Identity
description: Maintain a single source of truth for visual identity — colors, typography, spacing, shadows — that flows from a brand guide into design tokens consumed by code, design tools, and documentation. Tokens are semantic, not raw values; the brand guide is the canonical reference, not a screenshot.
tags: [brand-guide, design-tokens, visual-identity, tailwind, css-custom-properties, figma, frontend, single-source-of-truth]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: w3c-design-tokens-community-group
    resource: "https://www.w3.org/community/design-tokens/"
    title: "W3C Design Tokens Community Group"
  - id: tailwind-css-theme
    resource: "https://tailwindcss.com/docs/theme"
    title: "Tailwind CSS — Theme Configuration"
---

# Brand Guide and Design Tokens — Single Source of Truth for Visual Identity

## Rule

A project's visual identity — colors, typography, spacing, shadows, radii,
gradients — must have **one canonical source of truth**. That source is a
brand guide: a human-readable document (or interactive page) that defines
every visual value, its semantic name, and its approved usage. From the
brand guide, **design tokens** flow into every consumer: CSS custom
properties, Tailwind theme configuration, Figma styles, and documentation
site theming.

Three principles govern the token system:

1. **Semantic naming, not raw values** — tokens are named by purpose
   (`--color-primary`, `--color-surface`, `--font-heading`), not by value
   (`--blue-500`, `--ffffff`). A semantic name survives a rebrand; a raw
   value does not.
2. **One source, many consumers** — the brand guide is the source. Tokens
   are derived from it and consumed by code, design tools, and docs. Never
   hardcode a color in a component when a token exists for it.
3. **Theme-aware** — tokens are defined for the default theme and overridden
   for variants (dark mode, high contrast). The semantic name stays the
   same; only the value changes per theme.

## Why

Without a single source of truth:

- **Drift across surfaces** — the website uses `#3b82f6` for primary, the
  mobile app uses `#2563eb`, the Figma file uses `#1d4ed8`. They are all
  "blue" but they are not the same blue. A rebrand requires hunting every
  hardcoded value across every surface.
- **No semantic meaning** — a component uses `text-blue-500`. Is that
  "primary action text" or "informational badge text"? Without semantic
  tokens, the intent is lost. A theme change (switching primary from blue
  to green) requires touching every component that used `blue-500` for
  primary, even if some used it for a different purpose.
- **Dark mode breakage** — hardcoded colors do not adapt to theme changes.
  A component with `color: #1e293b` (dark text on light background) becomes
  invisible in dark mode. Tokens with theme overrides (`--color-text`)
  adapt automatically.
- **Documentation inconsistency** — the docs site uses different colors
  from the product. The brand looks different depending on where the user
  encounters it.

## How to Apply

### Define the brand guide

Create a single page (or document) that lists every visual value with its
semantic name and approved usage. Include:

- **Color system** — primary, secondary, surface, background, text,
  text-muted, border, success, warning, error. Show the hex/oklch value
  alongside the semantic name.
- **Typography** — font families (sans, mono, heading), font sizes (xs
  through 2xl), font weights, line heights.
- **Spacing** — a spacing scale (1 through 8 or more) in rem.
- **Borders** — radius (sm, md, lg), width.
- **Shadows** — sm, md, lg with their box-shadow values.
- **Gradients** — if the brand uses gradients, define the stops and angle.

The brand guide is the reference. When someone asks "what is our primary
color?" the answer is the brand guide, not a screenshot of the website.

### Derive tokens for each consumer

From the brand guide, derive tokens for each surface that consumes them:

**CSS custom properties** (the lowest level — all other consumers map to
these):

```css
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-surface: #f8fafc;
  --color-background: #ffffff;
  --color-text: #1e293b;
  --color-text-muted: #64748b;

  /* Typography */
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: ui-monospace, 'Cascadia Code', monospace;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;

  /* Spacing */
  --space-1: 0.25rem;
  --space-4: 1rem;
  --space-8: 2rem;

  /* Borders */
  --border-radius-md: 8px;
  --border-width: 1px;

  /* Shadows */
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* Dark theme overrides — semantic names stay the same */
[data-theme="dark"] {
  --color-background: #0f172a;
  --color-surface: #1e293b;
  --color-text: #f1f5f9;
  --color-text-muted: #94a3b8;
}
```

**Tailwind theme** (maps to the CSS custom properties):

```css
@theme {
  --color-primary: var(--color-primary);
  --color-surface: var(--color-surface);
  --font-sans: var(--font-sans);
  --radius-md: var(--border-radius-md);
}
```

**Figma styles** (published as a library that designers consume):
- Color styles named to match the semantic tokens (`Primary`, `Surface`,
  `Text Muted`).
- Text styles named to match the typography tokens (`Heading LG`, `Body
  Base`, `Code MD`).
- Effect styles named to match the shadow tokens (`Shadow MD`).

**Documentation site** (e.g. Astro Starlight, Docusaurus):
- Override the theme variables to map to the brand tokens.
- The docs site should look like the product, not like the default theme.

### Never hardcode values in components

A component should never contain `color: #3b82f6` or `padding: 1rem`. It
should use `color: var(--color-primary)` or `padding: var(--space-4)` (or
the Tailwind utility `text-primary` / `p-4`). The token is the contract
between the brand guide and the component.

## Concrete Instances

### Tailwind design tokens

Tailwind v4's `@theme` directive defines design tokens in CSS that
generate utility classes. The tokens are semantic (`--color-primary`, not
`--blue-500`) and theme-aware. Tailwind's Oxide engine scans the project
and generates only the utilities used. See
[Tailwind v4 Features](tailwind-v4-features.md) for the full configuration
guide.

### CSS custom properties

The lowest-level token system — native to the browser, no build step
required. CSS custom properties cascade, support `calc()`, and can be
overridden at any scope (`:root`, `[data-theme]`, media queries). They are
the foundation that Tailwind tokens and design-tool tokens map to. See
[CSS Fundamentals](css-fundamentals.md) for the full custom properties
guide.

### Figma tokens (Style Dictionary / Tokens Studio)

Figma styles can be exported as design tokens via tools like Style
Dictionary or Tokens Studio. The exported JSON is transformed into
platform-specific outputs: CSS custom properties for web, XML for Android,
Swift for iOS. This closes the loop: the designer changes a Figma style,
the export pipeline updates the CSS custom properties, and the website
reflects the change without a developer manually translating the value.

## See Also

- [CSS Fundamentals](css-fundamentals.md) — CSS custom properties are the
  lowest-level token system; this page covers the full foundation including
  design tokens, dark theme support, and semantic naming.
- [Tailwind v4 Features](tailwind-v4-features.md) — the `@theme` directive
  maps brand tokens to Tailwind utility classes.
- [Code Style Conventions](code-style-conventions.md) — naming conventions
  for token variables (kebab-case CSS custom properties).

## Sources

- W3C Design Tokens Community Group — the emerging standard for
  cross-platform design token format.
- Tailwind CSS theme documentation — `@theme` directive for token-driven
  utility generation.
