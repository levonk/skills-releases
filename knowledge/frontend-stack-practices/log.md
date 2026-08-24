# Directory Update Log

## 2026-08-21

* **Ingest**: Added three new concept pages covering cross-platform client
  image loading libraries, researched via parallel subagents against the
  Medium article
  "Android Image Loading Libraries: Glide, Picasso, Fresco, and Coil" (April
  2024) and verified against 2026 GitHub/repository state.
  - [android-image-loading.md](android-image-loading.md) — Coil 3.5.0 as the
    default for Kotlin/Compose, Glide 5.0.9 for legacy/image-heavy, Fresco 3.7.0
    for memory-intensive feeds, Picasso deprecated by Square. Covers Compose
    Multiplatform options (Landscapist, Sketch) and a performance comparison
    table.
  - [ios-image-loading.md](ios-image-loading.md) — Kingfisher 8.10.0 as the
    default for Swift/SwiftUI, Nuke for performance-critical/memory-constrained
    apps, SDWebImage 5.21.7 for legacy ObjC or broad platform support.
  - [cross-platform-image-loading.md](cross-platform-image-loading.md) — Web
    (native `loading="lazy"` + `next/image` + sharp), Flutter
    (`cached_network_image_ce` replacing unmaintained original), React Native
    (`expo-image` replacing `react-native-fast-image`), Desktop (egui_extras,
    tauri-plugin-redb-cache, Electron custom pattern).
  - Updated [index.md](index.md) to list the three new concepts and broaden the
    bundle description to include cross-platform client image loading.
  - Updated [overview.md.tmpl](overview.md.tmpl): added an `Images` phase to the
    stack pipeline and phase table (three rows), broadened the scope statement
    and description to include image loading, added new sources to frontmatter,
    and updated `knowledge-basis` and `last-used` to 2026-08-21.
  - Added six rows to the canonical
    [tech-stack-table.md.tmpl](https://github.com/levonk/skills-releases/blob/main/includes/tech-stack-table.md.tmpl) for
    image loading choices (Android, iOS, Flutter, React Native, Web, Tauri)
    and three "considered and rejected" entries (Picasso, cached_network_image
    original, react-native-fast-image).

## 2026-08-04

* **Update**: Rewrote the Next.js/Turbopack section of
  [explicit-file-extensions.md](explicit-file-extensions.md) from
  "Framework Exception" to **"Forced Workaround"** framing. `.ts` is
  never the right answer — Next.js apps are forced to use it because
  Turbopack is broken. Added a **support matrix table** showing
  Turbopack is the lone outlier (every other tool supports `.mts`).
  Added a "When the issue is fixed, migrate back to `.mts`" callout
  with a direct link to
  [#82945](https://github.com/vercel/next.js/issues/82945). Cross-linked
  to the full workaround details and ESLint configuration in
  [typescript-monorepo-best-practices/explicit-file-extensions.md](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/explicit-file-extensions.md).
  Updated `last-used` to 2026-08-04.

## 2026-07-26
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.

## 2026-07-23

* **Ingest**: Added [htmx-hypermedia-first.md](htmx-hypermedia-first.md) — a new
  concept establishing HTMX server-rendered hypermedia as the default
  interaction model, with client-side JS/React reserved for subtrees that
  genuinely exceed hypermedia's expressiveness. Captures the decision rule
  (HTMX first → JS island only when needed → hybrid is normal), when each is
  justified, pairing with the existing stack (Tailwind/CSS, Vitest, Node.js
  frontend setup), and anti-patterns (duplicating server state on the client,
  promoting a whole page to an SPA for one widget).
  - Updated [index.md](index.md) to list the new concept and mention HTMX in
    the bundle description.
  - Updated [overview.md.tmpl](overview.md.tmpl): added an `Interaction` phase
    to the stack pipeline and phase table, broadened the scope statement to
    include hypermedia-first interaction design, and updated the frontmatter
    description.
  - Cross-linked from [nodejs-frontend-setup.md](nodejs-frontend-setup.md) See
    Also, framing the Node.js/React setup as the fallback for the JS island
    case rather than the default.
* **Elaboration**: Expanded the "When Client-Side JS Is Justified" section of
  [htmx-hypermedia-first.md](htmx-hypermedia-first.md) into a "Recognizing the
  HTMX Boundary" subsection with five concrete failure signals (sub-100ms local
  derivation, fine-grained collaborative state, offline mutation, continuous
  high-frequency interaction, non-decomposable interaction model), a worked-
  examples table (Google Sheets, Figma, Gmail, Stripe Dashboard, offline notes,
  multiplayer game), and the hybrid-island pattern with its over-reach smell.
  Prompted by the observation that the original exception list was too terse to
  let a reader actually tell when HTMX is the wrong choice — a spreadsheet-style
  app is the canonical case where HTMX would be a serious mistake.

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
