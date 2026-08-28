<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 3.4.0

Create and maintain three types of compounding AI artifacts — skills, OKF knowledge bundles, and agents. Determines which type the user needs, recommends the best fit if they ask for the wrong one, and asks the user to choose before implementing. For skills: create from scratch, convert workflows (preserving git history via git mv), update existing skills, run evals, benchmark performance, and optimize descriptions. For knowledge bundles: create OKF-compliant bundles, ingest new sources, query bundles for answers, and lint for contradictions. For agents: recognize agent creation/update requests and route to the dedicated agent-upsert skill, which handles scaffolding, frontmatter customization, design focus, verification, and auditing. Use when users want to create a skill, create a knowledge bundle, create an agent, convert a workflow to a skill, edit/optimize an existing skill, run skill evals, benchmark skill performance, organize structured knowledge into a compounding markdown wiki, create OKF bundles, add sources to bundles, query bundles, health-check bundles, scaffold a new agent, or audit an existing agent definition. Make sure to use this skill whenever the user mentions skill creation, skill development, skill testing, skill evaluation, skill benchmarking, skill optimization, workflow-to-skill conversion, knowledge bundles, OKF, Open Knowledge Format, concept documents, bundle ingest, bundle query, bundle lint, agent creation, agent design, agent scaffolding, agent updating, agent auditing, agent optimization, or wants to package/distribute skills, even if they don't explicitly ask for a "skill creator," "knowledge bundle creator," or "agent creator." Do NOT trigger on general coding questions, bug fixes, feature implementation, code review, general documentation questions, one-off markdown files, or README creation (use readme-upsert) — this skill is for skill, knowledge bundle, and agent lifecycle management, not general development or writing.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ai-upsert` |
| Category | `ai` |
| Version | `3.4.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving (also used by ai-guidance-improver, ai-workflow-upsert, and creation workflows)
- **project-comparison** (skill, complement) — Shares comparison methodology via comparison-methodology include; project-comparison compares software projects, this skill compares AI skills
- **cli-tool-upsert** (skill, complement) — Creates CLI scripts and tools optimized for AI agents — ai-upsert includes its embedded-script-standards reference so skills inherit CLI script best practices at build time
- **data-pipeline-upsert** (skill, sibling) — Same upsert family — creates and updates data pipeline code (Airflow, Spark, dbt)
- **java-app-upsert** (skill, sibling) — Same upsert family — creates and updates Java applications
- **ai-workflow-upsert** (skill, sibling) — Same upsert family — handles AI workflow creation and updates
- **agent-file-upsert** (skill, sibling) — Same upsert family — handles agent file creation and updates
- **prompt-upsert** (skill, sibling) — Same upsert family — handles prompt creation and updates
- **readme-upsert** (skill, sibling) — Same upsert family — handles README.md creation and updates
- **template-upsert** (skill, sibling) — Same upsert family — handles template creation and updates
- **rule-upsert** (skill, sibling) — Same upsert family — handles rule creation and updates
- **agent-upsert** (skill, sibling) — Same upsert family — handles agent creation and updates
- **** (, example) — Canonical OKF bundle for container authoring and runtime practices
- **** (, example) — Canonical OKF bundle for Java/JVM practices
- **** (, example) — Canonical OKF bundle for data engineering practices
- **** (, example) — Canonical OKF bundle for TypeScript monorepo conventions
- **** (, example) — Canonical OKF bundle for DevSecOps codeguard rules
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram
- **project-detection** (skill, bundled-dependency) — Bundled via includeTree for offline availability. ai-upsert runs it in Phase 2 (Establish Technologies) to detect the target project's package manager, build system, test runner, and linter. The detected tech stack becomes a binding constraint on the generated/updated skill's tool references
- **code-review-guidance** (skill, bundled-dependency) — Bundled via includeTree for offline availability. ai-upsert runs its checklist in Phase 4 (Review & Verify) on the generated/updated artifact before commit
- **git-repository-management** (skill, bundled-dependency) — Bundled via includeTree for offline availability. ai-upsert uses it in Phase 0 (Pre-flight clean-repo check) and Phase 5 (Commit) so commit conventions are always present and never ad-libbed
- **** (, transitive-bundled-dependency) — Transitively bundled via code-review-guidance (which bundles it for standalone use). Materialized at ai-upsert's references/included/knowledge/ at build time. Provides shell-scripting-best-practices.md used in Phase 4 (Review & Verify) to validate generated shell scripts (shellcheck, shfmt, strict mode, PATH guards)
- **** (, transitive-bundled-dependency) — Transitively bundled via code-review-guidance (which bundles it for standalone use). Materialized at ai-upsert's references/included/knowledge/ at build time. Provides standalone-scripts.md (PEP 723, uv) used in Phase 4 (Review & Verify) to validate generated Python scripts
- **** (, transitive-bundled-dependency) — Transitively bundled via code-review-guidance (which bundles it for standalone use). Materialized at ai-upsert's references/included/knowledge/ at build time. Provides rustfmt-clippy-config.md, quality-gates.md, testing-strategy.md, error-handling.md used in Phase 4 (Review & Verify) to validate generated Rust code
- **** (, transitive-bundled-dependency) — Transitively bundled via code-review-guidance (which bundles it for standalone use). Materialized at ai-upsert's references/included/knowledge/ at build time. Provides vault storage and egress firewall patterns for security review in Phase 4
- **** (, transitive-bundled-dependency) — Transitively bundled via code-review-guidance (which bundles it for standalone use). Materialized at ai-upsert's references/included/knowledge/ at build time. Provides security patterns (banned C functions, credential detection, crypto governance, cert validation, SSH hardening) for security review in Phase 4
- **execute-upsert** (skill, pattern-reference) — Sibling execution skill whose phased pipeline (Self-Update, Establish Technologies, per-story review, commit) ai-upsert 3.3.0 adopts for its own lifecycle

---

- **Full skill**: [`skills/ai/ai-upsert/SKILL.md`](skills/ai/ai-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-28T08:41:18Z
