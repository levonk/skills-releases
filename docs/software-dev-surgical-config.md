<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Deterministic, non-destructive configuration file modifications using a tiered tool hierarchy. Use when modifying config files (devbox.json, Cargo.toml, package.json, YAML, TOML) without overwriting user settings, adding dependencies surgically, or making structure-preserving edits. Triggers on 'surgical edit', 'modify config', 'non-destructive config change', 'add dependency', or 'preserve config structure'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `surgical-config` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `config-management`
- `file-editing`

## Quick Start

Modify a configuration file surgically without overwriting existing content:

```bash
# Add a dependency to Cargo.toml (intelligent tool selection)
./scripts/surgical-edit.sh Cargo.toml '.dependencies += {"serde": "1.0"}'

# Update a specific section in devbox.json
./scripts/surgical-edit.sh devbox.json '.packages += ["nodejs", "rust"]'

# Project-aware editing (detects project type automatically)
./scripts/surgical-edit.sh --detect-project package.json '.dependencies += {"lodash": "^4.17.21"}'
```

## Instructions

### Core Philosophy

**Favor surgical, deterministic modifications over monolithic templates for configuration files.** Instead of overwriting files, use the `surgical-edit.sh` script which automatically applies a tiered tool hierarchy:

1. **Interface Layer** (`surgical-edit.sh`) - Intelligent file type detection and tool selection
2. **Semantic Parsers** (`yq-go`) - Format-aware, structure-preserving (preferred underlying tool)
3. **Structural Rewriters** (`comby`, `ast-grep`) - Pattern-based code transformations
4. **Patch Managers** (`quilt`, `guilt`) - Managed patch application
5. **Text-based Utilities** (`sd`, `sed`) - Line-level modifications

> **See also**: [Tool Selection](references/tool-selection.md) for the mermaid flowchart of tool selection logic and the file type detection table, and [Tool Hierarchy](references/tool-hierarchy.md) for detailed descriptions of each tier, project-specific tool selection, and required tools installation.

### Integration with Project Adoption Workflow

The surgical-config Skill integrates with the project-adopter workflow for intelligent project-aware editing:

1. **Detect project type** using project-detection skill
2. **Analyze existing configuration** and tooling
3. **Apply context-aware edits** based on project structure
4. **Respect project conventions** and existing patterns

```bash
# Project-aware surgical editing
./scripts/surgical-edit.sh \
  --detect-project \
  --file config.json \
  --operation '.dependencies += {"package": "1.0.0"}'

# This will:
# 1. Detect project type (Node.js, Rust, Python, etc.)
# 2. Check for existing package managers
# 3. Apply edit using appropriate tool (yq-go preferred)
# 4. Validate against project conventions
```

> **See also**: [Implementation Patterns](references/implementation-patterns.md) for additive configuration, idempotent operations, content preservation, common config file patterns, backup strategy, configuration management operations, and context-aware editing examples.

### Environment Setup

Before using the surgical-config Skill, ensure your environment is properly configured:

```bash
# Full environment setup (recommended)
./skills/surgical-config/scripts/ensure-environment.sh --setup

# Check what's available
./skills/surgical-config/scripts/ensure-environment.sh --check

# Install missing tools only
./skills/surgical-config/scripts/ensure-environment.sh --install
```

This Skill integrates seamlessly with:

- **File editing workflows**: Use as the primary modification strategy
- **Configuration management**: Apply to infrastructure-as-code files
- **Development environment setup**: Modify devbox.json, shell configs
- **CI/CD pipeline updates**: Update GitHub Actions, build configs

> **See also**: [Tool Comparison](references/tool-comparison.md) for detailed comparison of `surgical-edit.sh` vs `manage-config.mjs`, when to use which tool, and integration examples.

## Examples

### Example 1: Adding Development Dependencies

```bash
# Add Node.js and TypeScript to devbox.json
./scripts/surgical-edit.sh devbox.json '.packages += ["nodejs", "typescript"]'
```

### Example 2: Updating Service Configuration

```bash
# Change port in docker-compose.yml
./scripts/surgical-edit.sh docker-compose.yml '.services.web.port = 8080'
```

### Example 3: Pattern-based Code Updates

```bash
# Add serde derive to Rust structs (pattern replacement)
./scripts/surgical-edit.sh src/main.rs 'println!(:[args])' 'log::info!(:[args])'
```

## References

- [Tool Selection](references/tool-selection.md) - Mermaid flowchart of tool selection logic and file type detection table
- [Tool Hierarchy](references/tool-hierarchy.md) - Detailed descriptions of each tier, project-specific tool selection, and required tools installation
- [Implementation Patterns](references/implementation-patterns.md) - Additive configuration, idempotent operations, content preservation, common config file patterns, backup strategy, and configuration management operations
- [Tool Comparison](references/tool-comparison.md) - Detailed comparison of surgical-edit.sh vs manage-config.mjs, when to use which tool, and integration examples

## Related Skills
- **** (, ) — 
- **** (, ) — 
- **** (, ) — 
- **** (, ) — 

---

- **Full skill**: [`skills/software-dev/surgical-config/SKILL.md`](skills/software-dev/surgical-config/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-15T22:13:34Z
