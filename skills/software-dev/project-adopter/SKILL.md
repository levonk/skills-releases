---
name: project-adopter
description: Adopt and establish best practices for projects by overwriting existing preferences with standardized developer UX flow. Use when onboarding a new project to standard tooling, setting up devbox/just/direnv, establishing CI/CD, or applying ADR-compliant project structure. Triggers on 'adopt project', 'set up dev environment', 'standardize project', 'apply best practices', or 'project adoption'.
version: 2.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "project-management", "best-practices", "development-experience", "project-adoption", "preference-overwrite"]
see-also:
  - skill: project-configuration
    relationship: "alternative-approach"
    description: "For adding compatible preferences without overwriting existing workflows"
  - skill: project-detection
    relationship: "dependency"
    description: "Required for analyzing current project state and tooling"
  - skill: surgical-config
    relationship: "dependency"
    description: "Required for safe configuration file modifications"
  - skill: repository-health-review
    relationship: "optional"
    description: "Optional for pre/post-adoption health assessment"
  - skill: ai-development-loop
    relationship: "optional"
    description: "Optional for systematic development workflow integration"
  - skill: base-ai-guidance
    relationship: "base-framework"
    description: "Base AI guidance framework for all AI skills"
  - templates: boilerplates
    relationship: "preference-source"
    description: "Provides standardized project templates and preference definitions"
dependencies:
  - type: skill
    name: project-detection
    reason: "Required for comprehensive project analysis and tooling detection"
  - type: skill
    name: surgical-config
    reason: "Required for non-destructive configuration file editing"
  - type: skill
    name: repository-health-review
    reason: "Optional for pre/post-adoption health assessment"
  - type: skill
    name: ai-development-loop
    reason: "Optional for systematic development workflow integration"
  - type: templates
    name: boilerplates
    url: https://github.com/lrepo52/job-aide/tree/main/boilerplate
    reason: "Source of preference templates and standard project structures"
  - type: nix
    name: devbox
    url: https://github.com/jetify-com/devbox
  - type: nix
    name: just
    url: https://github.com/casey/just
  - type: node
    name: direnv
    url: https://direnv.net/
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Project Adopter

## Quick Start

When adopting best practices for a project (per ADR 20260131001 Standard Developer UX Flow):

1. **Health Review** - Run repository health analysis to assess current state (using repository-health-review skill)
2. **Detect** project type and existing configuration (using project-detection skill)
3. **Configure** devbox.json with appropriate packages (per ADR 20251226001)
4. **Set up** justfile with standard targets (build-internal, test-internal, lint-internal, etc.)
5. **Configure** .envrc for direnv integration (per ADR 20251226001)
6. **Set up** technology-specific build tools (cargo, nx, pytest, etc. per ADR 20260131001)
7. **Add** shared quality scripts (per ADR 20251218002)
8. **Configure** testing framework (Vitest for TypeScript per ADR 20251106002)
9. **Set up** GitHub Actions CI/CD (per ADR 20251106014)
10. **Update** README.md with development setup
11. **Add** docker-compose.yml if needed
12. **Create** LICENSE.md (Proprietary)
13. **Set up** AGENTS.md for AI workflow
14. **Configure** dependencies and tooling using surgical-config skill
15. **Integrate** with ai-development-loop for systematic workflow
16. **Post-Adoption Validation** - Run repository health review to verify improvements

## Integration with Other Skills

This skill integrates with project-detection, ai-development-loop, project-configuration, surgical-config, repository-health-review, quality scripts, testing framework, and CI/CD. For detailed integration descriptions, usage examples, health review reports, and loop prevention details, see [Skill Integrations](references/skill-integrations.md).

## Enhanced Workflow Integration

This skill sets up the foundation per **ADR 20260131001 Standard Developer UX Flow**, then the **ai-development-loop** skill provides the systematic workflow.

### Standard Developer UX Flow (ADR 20260131001)

**Primary Flow**: `direnv → devbox → just (*-internal) → [build tool]`

For the technology-specific build tools table, see [Technology Build Tools](references/technology-build-tools.md).

For detailed devbox setup, justfile configuration, direnv configuration, README.md structure, Docker configuration, LICENSE.md, AGENTS.md configuration, dependency management, GitHub configuration, .gitignore updates, examples, and quality checklist, see [Developer UX Flow](references/developer-ux-flow.md).

## References

For ADR references and detailed configuration links, see [ADR References](references/adr-references.md).

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/project-adopter/SKILL.md`
- Scripts: `scripts/adopt-project.sh`
- References: `references/skill-integrations.md`, `references/developer-ux-flow.md`, `references/technology-build-tools.md`, `references/adr-references.md`
- Related skills: `config/ai/skills/software-dev/project-detection/SKILL.md`, `config/ai/skills/software-dev/project-configuration/SKILL.md`
- Boilerplates reference: https://github.com/lrepo52/job-aide/tree/main/boilerplate

### Related Skills
- project-configuration (alternative-approach)
- project-detection (dependency)
- surgical-config (dependency)
- repository-health-review (optional)
- ai-development-loop (optional)
- base-ai-guidance (base-framework)

### External Resources
- Devbox: https://github.com/jetify-com/devbox
- just: https://github.com/casey/just
- direnv: https://direnv.net/

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk
