# Directory Update Log

## 2026-07-18

* **DRY**: Converted [overview.md](overview.md.tmpl) to `overview.md.tmpl` and
  added `{{{ include "includes/tech-stack-table.md" . }}}` so the canonical
  tech-stack choices table is inlined from a single source of truth at
  `src/current/includes/tech-stack-table.md.tmpl`. See the
  typescript-monorepo-best-practices log entry for the full rationale.

* **Update**: Brought [nodejs-frontend-setup.md](nodejs-frontend-setup.md) in
  line with the documented TypeScript standard. Removed the `prettier` install
  and the `touch .prettierrc` step — formatting is enforced through the ESLint
  config (antfu-based), per [code-style-conventions.md](code-style-conventions.md)
  and the typescript-monorepo [code-style.md](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/code-style.md).
  Replaced the Jest install with Vitest as the primary install step (previously
  Jest was installed and Vitest was only a "prefer" footnote). Updated the
  frontmatter description, tags, and the See Also links to match. Biome was
  considered and rejected for this monorepo because the ESLint composition API
  and plugin ecosystem (Drizzle, Tailwind, Prisma, antfu framework support)
  cannot be replaced by Biome's static JSON config; Biome remains mentioned
  only in passing in `upstream-contribution-practices/`.

## 2026-07-17

* **Initialization**: Created the `frontend-stack-practices` knowledge bundle to consolidate frontend TypeScript/React practices from four ADRs across job-aide and levonk-base-boilerplate.
* **Creation**: Authored 5 concept pages covering the frontend stack.
  - [explicit-file-extensions.md](explicit-file-extensions.md) — .mts/.cts/.tsx over ambiguous .ts/.js
  - [path-alias-safety.md](path-alias-safety.md) — category-based aliases over @/*
  - [eslint-composition-api.md](eslint-composition-api.md) — three-level ESLint config customization
  - [vitest-testing-framework.md](vitest-testing-framework.md) — Vitest for all TypeScript testing
  - [code-style-conventions.md](code-style-conventions.md) — formatting, naming, and documentation standards
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251019001 (file extensions, 204 lines), ADR-20251019002 (path aliases, 253 lines), ADR-20251019003 (ESLint composition, 266 lines) in job-aide, and ADR-20251106002 (Vitest, 83 lines) in levonk-base-boilerplate.
