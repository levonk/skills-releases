---
type: Practice
title: Tailwind v4 Features
description: Tailwind CSS v4 guidance — Oxide engine, @theme directive, container queries, 3D transforms, arbitrary values, data attributes, and project-wide configuration.
tags: [tailwind, css, utility-first, oxide, container-queries, design-tokens, frontend]
timestamp: 2026-07-18T00:00:00Z
---

# Tailwind v4 Features

Tailwind CSS v4 guidance for consistent, utility-first styling across frontend
projects. Build on the [CSS Fundamentals](css-fundamentals.md) foundation before
reaching for utilities.

## General Guidelines

- **Consistent Styling:** Use Tailwind utility classes for consistent styling,
  with custom CSS only for special cases.
- **Logical Organization:** Organize classes logically (layout, spacing, color,
  typography).
- **Responsive & State Variants:** Use responsive and state variants (e.g.,
  `sm:`, `md:`, `lg:`, `hover:`, `focus:`, `dark:`) in markup.
- **Tailwind v4 Features:** Embrace Tailwind v4 features like container queries
  and CSS variables.
- **Configuration:** Keep `tailwind.config.ts` updated with design tokens and
  purge paths.
- **Unified Design Language:** Rely on Tailwind classes rather than inline
  styles or external CSS files.

## Configuration (CSS Files)

- **Theme Directive:** Use the `@theme` directive to define custom design tokens
  like fonts, breakpoints, and colors.
- **Modern Color Formats:** Prefer modern color formats such as `oklch` for
  better color gamut support, defining them in the `:root` scope.
- **Automatic Content Detection:** Take advantage of automatic content
  detection, which eliminates the need for a `content` array in configuration.
- **Oxide Engine:** Rely on Oxide engine to scan project files, excluding those
  in `.gitignore` and binary extensions.
- **Specific Sources:** Add specific sources with `@source` only when necessary.
- **Custom Utilities:** Extend Tailwind with custom utilities using the
  `@utility` directive in CSS files.

## Styling (CSS Files)

- **3D Transforms:** Incorporate 3D transform utilities like `rotate-x-*`,
    `rotate-y-*`, and `scale-z-*` for advanced visual effects.
- **Container Queries:** Implement container queries with `@container`,
  `@max-*`, and `@min-*` utilities for adaptive layouts.
- **Arbitrary Values:** Use arbitrary values and properties with square bracket
  notation (e.g., `[mask-type:luminance]` or `top-[117px]`).
- **Modifiers:** Apply modifiers like `hover` or `lg` with arbitrary values for
  flexible styling.
- **Advanced Variants:** Use the `not-*` variant for `:not()` pseudo-classes and
  the `starting` variant for `@starting-style`.
- **Browser Support:** Check browser support for advanced features like
  `@starting-style` using resources like caniuse.

## Components (HTML)

- **Utility First:** Apply Tailwind utility classes directly in HTML for styling
  components.
- **Dynamic Values:** Use dynamic arbitrary values like
  `grid-cols-[1fr_500px_2fr]` for flexible layouts.
- **Data Attributes:** Implement data attribute variants like
  `data-current:opacity-100` for conditional styling.
- **Accessibility:** Ensure accessibility by pairing Tailwind utilities with
  appropriate ARIA attributes.
- **Hidden Elements:** Use `aria-hidden="true"` or `role="presentation"` when
  applying utilities like `hidden` or `sr-only`.

## Components (TypeScript/JavaScript)

- **TypeScript Preference:** Prefer TypeScript over JavaScript for component
  files to ensure type safety when applying Tailwind classes.
- **Dynamic Classes:** Use dynamic utility classes with template literals or
  arrays (e.g., `` className={`p-${padding} bg-${color}`} ``).
- **Type Validation:** Validate dynamic values with TypeScript types.
- **Framework Integration:** Integrate Tailwind with modern frameworks by
  applying utilities in component logic.
- **Functional Components:** Favor functional components over class-based ones
  in frameworks like React.

## Project-Wide Systems

- **Performance:** Leverage the Oxide engine's fast build times for performance
  optimization.
- **Content Configuration:** Avoid manual content configuration unless
  explicitly required.
- **Theme Variables:** Maintain consistency by using theme variables defined in
  CSS configuration files.
- **Variable Usage:** Reference theme variables in both utility classes and
  custom CSS (e.g., `text-[--color-primary]`).
- **Updates:** Update rules regularly to reflect Tailwind v4's evolving feature
  set.
- **Deprecations:** Be aware of deprecated options from v3.x like
  `text-opacity`.

## See Also

- [CSS Fundamentals](css-fundamentals.md) — Foundational CSS knowledge to apply
  before using Tailwind
- [Node.js Frontend Setup](nodejs-frontend-setup.md) — Build tooling and project
  setup that includes Tailwind
- [Code Style Conventions](code-style-conventions.md) — Formatting and naming
  conventions for component files

## Sources

- Migrated from src/current/rules/software-dev/platforms/node-dev/tailwind-essentials.md
