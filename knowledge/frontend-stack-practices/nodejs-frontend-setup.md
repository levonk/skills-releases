---
type: Practice
title: Node.js Frontend Setup
description: Frontend development with Node.js — mise toolchain, webpack bundling, ESLint as the unified linter/formatter (no separate Prettier), Vitest testing, production builds, and deployment pipeline.
tags: [nodejs, frontend, mise, webpack, eslint, vitest, testing, deployment, toolchain]
timestamp: 2026-07-18T00:00:00Z
---

# Node.js Frontend Setup

Guidelines for developing frontend applications using Node.js. Covers toolchain
setup, development workflow, testing, production builds, and deployment.

## Setup

### Toolchain with mise (recommended)

```bash
# Install mise: https://mise.jdx.dev/[install]
# In the project, declare tools and install them
mise use -p node@lts bun@latest
mise install
```

### Initialize a new Node.js project

```bash
bun init --yes
```

### Install essential development dependencies

```bash
bun add -d webpack webpack-cli webpack-dev-server babel-loader @babel/core @babel/preset-env eslint
```

### Set up project structure

```bash
mkdir -p src/{components,styles,utils} public
touch src/index.js src/index.html
```

## Development Workflow

### Create webpack configuration

```bash
touch webpack.config.js
```

### Set up ESLint (unified linter + formatter)

```bash
pnpm dlx eslint --init
```

> **Note:** Formatting (double quotes, 2-space indent, semicolons, kebab-case
> filenames) is enforced **through the ESLint config**, not via a separate
> Prettier step. For ESLint config composition patterns (direct usage,
> options-based, full composition with file-specific rules), see
> [ESLint Composition API](eslint-composition-api.md). For the full style
> rule set, see [Code Style Conventions](code-style-conventions.md).

### Start development server

```bash
bun run dev
```

## Testing

### Install testing framework

```bash
bun add -d vitest @testing-library/react @testing-library/jest-dom
```

### Run tests

```bash
bun run test
```

> **Note:** Vitest is the standard test runner for all TypeScript projects —
> see [Vitest Testing Framework](vitest-testing-framework.md) for the unified
> unit, integration, and E2E testing approach, including the `.test.mts`
> extension rule and project-based testing config. Jest is not used.

## Building for Production

### Build optimized assets

```bash
bun run build
```

### Preview production build

```bash
pnpm dlx serve -s dist
```

## Deployment

1. Set up CI/CD pipeline using GitHub Actions or similar service
2. Configure deployment to your hosting provider
3. Set up monitoring and analytics

## Platform-Specific Guidance

For detailed patterns and best practices, see the platform-specific guides:

- **JavaScript Essentials**: `../platforms/node-dev/javascript-essentials.md` —
  JavaScript fundamentals and patterns
- **TypeScript Essentials**: `../platforms/node-dev/typescript-essentials.md` —
  TypeScript development standards
- **Next.js Essentials**: `../platforms/node-dev/nextjs-essentials.md.tmpl` —
  Complete Next.js development guide
- **Next.js Data Fetching**:
  `../platforms/node-dev/nextjs-data-fetching.md.tmpl` — Modern data fetching
  patterns
- **Tailwind CSS Essentials**: [Tailwind v4 Features](tailwind-v4-features.md)
  — Utility-first CSS framework
- **CSS Essentials**: [CSS Fundamentals](css-fundamentals.md) — Foundational
  CSS knowledge

## Development Standards

- Follow React patterns
- Use Typescript patterns
- Apply CSS guidelines
- Follow testing patterns
- Use linting rules
- Apply troubleshooting approaches

## See Also

- [ESLint Composition API](eslint-composition-api.md) — Three-level ESLint
  config customization for this setup
- [Vitest Testing Framework](vitest-testing-framework.md) — Standard test
  runner for TypeScript frontend projects
- [Code Style Conventions](code-style-conventions.md) — Formatting and naming
  standards enforced by the ESLint config (no separate Prettier step)
- [CSS Fundamentals](css-fundamentals.md) — CSS architecture and patterns for
  the styles directory
- [Tailwind v4 Features](tailwind-v4-features.md) — Utility-first CSS framework
  integration

## Sources

- Migrated from src/current/rules/software-dev/frontend-dev/frontend-node.md
