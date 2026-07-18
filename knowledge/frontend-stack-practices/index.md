---
okf_version: "0.1"
---

# Frontend Stack Practices

A compounding knowledge base documenting practices for the TypeScript/React
frontend stack — file extensions, path aliases, ESLint composition, testing with
Vitest, code style conventions, CSS fundamentals, Tailwind v4 features, and
Node.js frontend setup. Each concept captures specific standards sourced from
real project ADRs and rule files.

## Concepts

* [Overview](overview.md) - Synthesis of the full frontend stack practice set
* [explicit-file-extensions](explicit-file-extensions.md) - .mts/.cts/.tsx over ambiguous .ts/.js for module system clarity
* [path-alias-safety](path-alias-safety.md) - Category-based aliases over ambiguous @/* to prevent npm scope conflicts
* [eslint-composition-api](eslint-composition-api.md) - Three-level ESLint config customization: direct, options, full composition
* [vitest-testing-framework](vitest-testing-framework.md) - Vitest for unit, integration, and E2E test running with Stagehand/Playwright
* [code-style-conventions](code-style-conventions.md) - Double quotes, 2-space indent, semicolons, kebab-case filenames, type over interface
* [css-fundamentals](css-fundamentals.md) - CSS architecture, reset/base, responsive design, layout systems, positioning, custom properties, animations, BEM, preprocessors, performance
* [tailwind-v4-features](tailwind-v4-features.md) - Tailwind v4 guidance: Oxide engine, @theme directive, container queries, 3D transforms, arbitrary values, data attributes
* [nodejs-frontend-setup](nodejs-frontend-setup.md) - Node.js frontend setup with mise toolchain, webpack, ESLint, Prettier, testing, building, and deployment
