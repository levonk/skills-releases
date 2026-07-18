---
type: Practice
title: CSS Fundamentals
description: Foundational CSS patterns — architecture, reset/base, responsive design, layout systems, positioning, custom properties, animations, BEM naming, preprocessors, CSS-in-JS, performance, and debugging.
tags: [css, frontend, layout, responsive, bem, design-tokens, animations, scss]
timestamp: 2026-07-18T00:00:00Z
---

# CSS Fundamentals

Foundational CSS patterns and best practices for modern web development. This is
the foundation layer to apply before utility frameworks like Tailwind.

## CSS Architecture Principles

### Methodology Selection

- **BEM (Block Element Modifier)**: For component-based architecture
- **CSS Modules**: For scoped styles in component frameworks
- **CSS-in-JS**: For dynamic styling in React/Vue applications
- **Utility-First**: Use Tailwind CSS for rapid development (see:
  [Tailwind v4 Features](tailwind-v4-features.md))

### File Organization

```
styles/
├── base/           # Reset, typography, base elements
├── components/     # Component-specific styles
├── layout/         # Grid, header, footer, sidebar
├── pages/          # Page-specific styles
├── themes/         # Color schemes, design tokens
├── utilities/      # Helper classes, mixins
└── main.scss       # Entry point
```

## Reset and Base Styles

- **Modern CSS Reset**: Use `css-reset` or custom reset
- **Box Model**: Use `box-sizing: border-box` globally
- **Typography**: Set baseline font sizes and line heights
- **Color System**: Define CSS custom properties for colors

```css
/* ✅ Modern reset with CSS custom properties */
:root {
  --color-primary: #3b82f6;
  --color-secondary: #64748b;
  --color-background: #ffffff;
  --color-text: #1e293b;
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: ui-monospace, 'Cascadia Code', monospace;
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html {
  font-family: var(--font-sans);
  line-height: 1.5;
  -webkit-text-size-adjust: 100%;
}

body {
  margin: 0;
  color: var(--color-text);
  background-color: var(--color-background);
}
```

## Responsive Design

- **Mobile-first**: Start with mobile styles, then enhance
- **Fluid typography**: Use clamp() for responsive font sizes
- **Container queries**: Use for component-level responsiveness
- **Relative units**: Prefer rem, em, % over px

```css
/* ✅ Mobile-first responsive design */
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--spacing-md);
}

@media (min-width: 768px) {
  .container {
    padding: 0 var(--spacing-lg);
  }
}

/* ✅ Fluid typography */
.heading {
  font-size: clamp(1.5rem, 4vw, 3rem);
  line-height: 1.2;
}

/* ✅ Container queries */
.card-container {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 1fr 2fr;
  }
}
```

## CSS Layout Systems

### Modern Layout

- **CSS Grid**: For 2D layouts and complex page structures
- **Flexbox**: For 1D layouts and component alignment
- **Logical Properties**: Use `margin-inline` instead of `margin-left`

```css
/* ✅ CSS Grid for page layout */
.page-layout {
  display: grid;
  grid-template-areas:
    "header header"
    "sidebar main"
    "footer footer";
  grid-template-columns: 250px 1fr;
  grid-template-rows: auto 1fr auto;
  min-height: 100vh;
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.footer { grid-area: footer; }

/* ✅ Flexbox for components */
.card {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  padding: var(--spacing-lg);
  border-radius: 8px;
  border: 1px solid var(--color-secondary);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

### Positioning

- **Static/Relative**: Default and simple offset positioning
- **Absolute**: Within positioned parent for overlays
- **Fixed**: Viewport-relative for modals, headers
- **Sticky**: Hybrid behavior for scroll effects

```css
/* ✅ Proper positioning context */
.modal-overlay {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  position: relative;
  background: white;
  border-radius: 8px;
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.sticky-header {
  position: sticky;
  top: 0;
  background: var(--color-background);
  z-index: 100;
  border-bottom: 1px solid var(--color-secondary);
}
```

## CSS Custom Properties (Variables)

### Design Tokens

- **Semantic naming**: Use descriptive names like `--color-primary` not `--blue-500`
- **Systematic organization**: Group related tokens
- **Fallback values**: Provide sensible defaults
- **Theme support**: Structure for multiple themes

```css
/* ✅ Well-organized design tokens */
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-secondary: #64748b;
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-text: #1e293b;
  --color-text-muted: #64748b;

  /* Typography */
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-8: 2rem;

  /* Borders */
  --border-radius-sm: 4px;
  --border-radius-md: 8px;
  --border-radius-lg: 12px;
  --border-width: 1px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
}

/* ✅ Dark theme support */
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #0f172a;
    --color-surface: #1e293b;
    --color-text: #f1f5f9;
    --color-text-muted: #94a3b8;
  }
}

[data-theme="dark"] {
  --color-background: #0f172a;
  --color-surface: #1e293b;
  --color-text: #f1f5f9;
  --color-text-muted: #94a3b8;
}
```

## CSS Animations & Transitions

### Performance

- **Use transform/opacity**: Avoid animating layout properties
- **Will-change**: Hint browsers for complex animations
- **Reduced motion**: Respect user preferences

```css
/* ✅ Performant animations */
.button {
  background: var(--color-primary);
  color: white;
  border: none;
  padding: var(--space-3) var(--space-4);
  border-radius: var(--border-radius-md);
  transition: transform 0.2s ease, background-color 0.2s ease;
}

.button:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.button:active {
  transform: translateY(0);
}

/* ✅ Respect motion preferences */
@media (prefers-reduced-motion: reduce) {
  .button {
    transition: none;
  }

  .animated-element {
    animation: none;
  }
}

/* ✅ Complex animation */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.slide-in {
  animation: slideIn 0.3s ease-out;
}
```

## CSS Methodologies

### BEM Naming

- **Block**: Standalone component (`.card`)
- **Element**: Part of a block (`.card__title`)
- **Modifier**: Variant of block/element (`.card--featured`)

```css
/* ✅ BEM naming convention */
.card {
  padding: var(--space-4);
  border-radius: var(--border-radius-md);
  border: var(--border-width) solid var(--color-secondary);
}

.card__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-3);
}

.card__title {
  font-size: var(--font-size-lg);
  font-weight: 600;
  color: var(--color-text);
}

.card--featured {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
}

.card--featured .card__title {
  color: var(--color-primary);
}
```

### CSS Modules

- **Scoped styles**: Automatic class name scoping
- **Composition**: Combine multiple classes
- **Local imports**: Import styles in components

```css
/* ✅ CSS Modules */
.card {
  composes: base from './base.css';
  padding: var(--space-4);
  border-radius: var(--border-radius-md);
}

.title {
  composes: heading from './typography.css';
  color: var(--color-text);
}
```

## CSS Preprocessors (SCSS/SASS)

### Mixins and Functions

- **Mixins**: Reusable style patterns
- **Functions**: Dynamic value calculation
- **Nesting**: Logical grouping of selectors

```scss
// ✅ SCSS mixins
@mixin button-base {
  padding: var(--space-3) var(--space-4);
  border: none;
  border-radius: var(--border-radius-md);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

@mixin button-variant($bg-color, $text-color: white) {
  background-color: $bg-color;
  color: $text-color;

  &:hover {
    background-color: darken($bg-color, 10%);
  }
}

.button-primary {
  @include button-base;
  @include button-variant(var(--color-primary));
}

// ✅ SCSS functions
@function strip-unit($number) {
  @if type-of($number) == 'number' and not unitless($number) {
    @return $number / ($number * 0 + 1);
  }
  @return $number;
}

@function rem($pixels, $context: 16) {
  @return #{strip-unit($pixels) / strip-unit($context)}rem;
}
```

## CSS-in-JS Patterns

### Styled Components

- **Dynamic styling**: Based on props
- **Theme integration**: Access to design tokens
- **Component-scoped**: No class name conflicts

```javascript
// ✅ Styled components example
import styled, { css } from 'styled-components';

const Button = styled.button`
  padding: var(--space-3) var(--space-4);
  border: none;
  border-radius: var(--border-radius-md);
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;

  background-color: ${({ variant = 'primary', theme }) => {
    switch (variant) {
      case 'secondary':
        return theme.colors.secondary;
      case 'danger':
        return theme.colors.danger;
      default:
        return theme.colors.primary;
    }
  }};

  color: ${({ variant = 'primary', theme }) => {
    return variant === 'secondary' ? theme.colors.text : 'white';
  }};

  &:hover {
    transform: translateY(-2px);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
  }

  ${({ fullWidth }) =>
    fullWidth &&
    css`
      width: 100%;
      display: block;
    `}
`;
```

## Performance & Optimization

### CSS Performance

- **Critical CSS**: Inline above-the-fold styles
- **CSS loading**: Load non-critical CSS asynchronously
- **Selector efficiency**: Avoid deeply nested selectors
- **Bundle size**: Remove unused CSS with PurgeCSS

```css
/* ✅ Efficient selectors */
/* Good: Class-based, shallow specificity */
.card { }
.card__title { }
.card--featured { }

/* Avoid: Overly specific, high specificity */
.container .content .section .card .title { }

/* Avoid: Universal selectors */
* { }
div * { }
```

### Modern CSS Features

- **Container Queries**: Component-based responsiveness
- **CSS Layers**: Control specificity cascade
- **Cascade Layers**: Organize CSS by concern
- **Logical Properties**: Internationalization support

```css
/* ✅ CSS Layers */
@layer reset, base, components, utilities;

@layer reset {
  /* CSS reset styles */
}

@layer base {
  /* Base element styles */
}

@layer components {
  /* Component styles */
}

@layer utilities {
  /* Utility classes */
}

/* ✅ Logical properties */
.content {
  margin-inline: auto;
  padding-block: var(--space-4);
  border-inline-start: var(--border-width) solid var(--color-primary);
}
```

## Debugging & Maintenance

### CSS Debugging

- **Browser DevTools**: Use Elements and Styles panels
- **Visual aids**: Outline layouts during development
- **CSS Stats**: Analyze CSS complexity and usage

```css
/* ✅ Development debugging styles */
/* Add to development environment */
*[data-debug] {
  outline: 2px solid red;
}

.grid-debug {
  background-image:
    linear-gradient(rgba(255, 0, 0, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 0, 0, 0.1) 1px, transparent 1px);
  background-size: 20px 20px;
}
```

### CSS Maintenance

- **Code comments**: Document complex logic
- **Style guides**: Create visual documentation
- **Regular audits**: Remove unused CSS
- **Consistent patterns**: Follow established conventions

## Integration with Frameworks

### React Integration

- **CSS Modules**: Recommended for component scoping
- **Styled Components**: For dynamic styling needs
- **Tailwind CSS**: For utility-first development (see:
  [Tailwind v4 Features](tailwind-v4-features.md))

### Next.js Integration

- **Global CSS**: Import in `_app.js` or `layout.tsx`
- **CSS Modules**: Use `.module.css` files
- **Styled JSX**: Built-in CSS-in-JS solution

## See Also

- [Tailwind v4 Features](tailwind-v4-features.md) — Utility-first CSS framework
  built on these CSS foundations
- [Node.js Frontend Setup](nodejs-frontend-setup.md) — Build tooling and project
  setup for frontend development
- [Code Style Conventions](code-style-conventions.md) — Formatting and naming
  conventions for the broader frontend stack

## Sources

- Migrated from src/current/rules/software-dev/frontend-dev/css-essentials.md
