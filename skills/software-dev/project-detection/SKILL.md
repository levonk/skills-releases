---
name: project-detection
description: "Comprehensive detection of project types, build systems, package managers, and CI/CD platforms. Use when needing to analyze a project's tech stack, detect build systems, identify CI/CD platforms, extract build targets, or understand project structure. Triggers on 'detect project type', 'analyze project', 'identify build system', 'detect CI/CD', or 'project analysis'."
version: 2.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "project-detection", "build-systems", "ci-cd", "project-analysis", "tooling", "foundational-component"]
see-also:
  - skill: project-adopter
    relationship: "dependent"
    description: "Uses project-detection for comprehensive project analysis before adoption"
  - skill: project-configuration
    relationship: "dependent"
    description: "Uses project-detection to understand existing tooling before configuration"
  - skill: surgical-config
    relationship: "complementary"
    description: "Often used together for safe configuration modifications"
  - templates: boilerplates
    relationship: "reference-source"
    description: "Provides detection patterns for standard project structures"
  - template: base-ai-guidance
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: nix
    name: python312Full
    url: https://search.nixos.org/packages?query=python312Full
    reason: "Required for Python-based detection scripts"
  - type: debian
    name: find
    reason: "Required for file system scanning"
  - type: debian
    name: grep
    reason: "Required for pattern matching"
  - type: nix
    name: ripgrep
    url: https://github.com/BurntSushi/ripgrep
    reason: "Required for fast pattern searching"
  - type: python
    name: json
    url: https://docs.python.org/3/library/json.html
    reason: "Required for JSON output formatting"
  - type: python
    name: yaml
    url: https://pyyaml.org/
    reason: "Required for YAML parsing and output"
  - type: url
    name: Build System Detection Patterns
    url: https://github.com/github/linguist
    reason: "Reference for file extension and pattern detection"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Project Detection Skill

A reusable skill for detecting and analyzing project configurations, build systems, package managers, and CI/CD platforms. This skill serves as a foundational component for other development skills that need to understand project structure and tooling.

## Purpose

This skill provides comprehensive detection capabilities that can be used by:

- **Project Configuration Skill** - Configure projects with standard tooling (devbox, justfile, CI/CD)
- **Monorepo Extractor Skill** - Extract projects while preserving tooling and workflows
- **Project Migration Skill** - Migrate projects between different tooling stacks
- **Environment Setup Skill** - Set up development environments based on detected tooling

## Quick Start

```bash
# Detect all systems in a project
./scripts/detect-all-systems.sh /path/to/project

# Detect specific categories
./scripts/detect-build-systems.sh /path/to/project
./scripts/detect-ci-cd-systems.sh /path/to/project
./scripts/detect-workspace-configs.sh /path/to/project

# Extract build targets from existing configurations
./scripts/extract-build-targets.sh generate /path/to/project
./scripts/extract-build-targets.sh show /path/to/project

# Get detailed analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose
```

## Build Target Extraction

The skill includes **build target extraction** that reads existing configuration files (package.json, Cargo.toml, Makefile, pyproject.toml, go.mod, pom.xml, build.gradle, devbox.json) and generates justfiles with actual project targets.

For detailed extraction examples and supported configuration files, see [references/build-target-extraction.md](references/build-target-extraction.md).

## Core Detection Capabilities

The skill detects build systems, package managers, CI/CD platforms, workspace/monorepo tools, and development tools across a wide range of languages and platforms including JavaScript/TypeScript, Rust, Python, Go, Java, .NET, Ruby, PHP, Elixir, Haskell, Clojure, C/C++, Container, and Infrastructure.

For detailed lists of all supported detection capabilities, see [references/detection-capabilities.md](references/detection-capabilities.md).

## Usage Patterns

The skill can be used as a library (sourced by other skills) or as a standalone tool with JSON/human-readable output. It integrates with project-configuration, monorepo-extractor, and other skills.

For detailed usage patterns and integration examples, see [references/usage-patterns.md](references/usage-patterns.md).

## API Reference

### Detection Functions

#### `detect_systems(repo_path, verbose)`
Detect build systems and package managers.

**Parameters:**
- `repo_path`: Path to repository
- `verbose`: Show detailed output (true/false)

**Returns:** Space-separated list of detected systems

#### `detect_ci_cd_systems(repo_path, verbose)`
Detect CI/CD platforms and configurations.

**Parameters:**
- `repo_path`: Path to repository
- `verbose`: Show detailed output (true/false)

**Returns:** Space-separated list of detected CI/CD systems

#### `analyze_workspace_configs(repo_path, project_name, verbose)`
Analyze workspace configurations and monorepo structures.

**Parameters:**
- `repo_path`: Path to repository
- `project_name`: Target project name
- `verbose`: Show detailed output (true/false)

**Returns:** Analysis of workspace configurations

### Output Formats

#### Human Readable
```
✓ pnpm (via pnpm-lock.yaml)
✓ github-actions (via .github/workflows)
✓ turbo (via turbo.json)
```

#### Machine Readable (JSON)
```json
{
  "build_systems": ["pnpm", "typescript", "tailwind"],
  "ci_cd_systems": ["github-actions", "github-actions-node"],
  "workspace_configs": {
    "pnpm": {
      "file": "pnpm-workspace.yaml",
      "packages": ["apps/*", "packages/*"]
    }
  }
}
```

## Scripts

### Core Detection Scripts

- `scripts/detect-build-systems.sh` - Detect build systems and package managers
- `scripts/detect-ci-cd-systems.sh` - Detect CI/CD platforms
- `scripts/detect-workspace-configs.sh` - Detect workspace configurations

### Analysis Scripts

- `scripts/analyze-project-structure.sh` - Comprehensive project analysis
- `scripts/analyze-workspace-configs.sh` - Detailed workspace analysis
- `scripts/analyze-ci-cd-configs.sh` - CI/CD configuration analysis

### Utility Scripts

- `scripts/detect-all-systems.sh` - Run all detection scripts
- `scripts/export-detection-results.sh` - Export results in various formats
- `scripts/validate-detection.sh` - Validate detection accuracy

## Integration Guide

### For Skill Authors

#### 1. Source the Detection Functions
```bash
# At the top of your script
DETECTION_SKILL_PATH="$(dirname "${BASH_SOURCE[0]}")/../project-detection"
source "$DETECTION_SKILL_PATH/scripts/detect-build-systems.sh"
source "$DETECTION_SKILL_PATH/scripts/detect-ci-cd-systems.sh"
```

#### 2. Use Detection Results
```bash
# Detect systems
build_systems=$(detect_systems "$PROJECT_PATH" "false")
ci_cd_systems=$(detect_ci_cd_systems "$PROJECT_PATH" "false")

# Make decisions based on detection
if [[ "$build_systems" == *"pnpm"* ]]; then
    configure_pnpm_project "$PROJECT_PATH"
fi

if [[ "$ci_cd_systems" == *"github-actions"* ]]; then
    setup_github_actions "$PROJECT_PATH"
fi
```

#### 3. Handle Multiple Systems
```bash
# Handle multiple detected systems
for system in $build_systems; do
    case "$system" in
        "pnpm") configure_pnpm ;;
        "cargo") configure_cargo ;;
        "python") configure_python ;;
        *) echo "Unknown system: $system" ;;
    esac
done
```

### For Direct Usage

#### 1. Quick Detection
```bash
# Simple detection
./scripts/detect-all-systems.sh /path/to/project
```

#### 2. Detailed Analysis
```bash
# Comprehensive analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose --format json
```

#### 3. Export Results
```bash
# Export to file
./scripts/export-detection-results.sh /path/to/project --output project-analysis.json
```

## Configuration

### Detection Patterns

Detection patterns are defined in associative arrays in each script:

```bash
declare -A BUILD_SYSTEMS=(
    ["pnpm"]="pnpm-lock.yaml"
    ["npm"]="package.json"
    ["cargo"]="Cargo.toml"
    # ... more patterns
)
```

### Adding New Systems

To add support for a new system:

1. **Add to Detection Array**
```bash
["new-system"]="indicator-file-or-pattern"
```

2. **Add Validation Logic** (if applicable)
```bash
validate_new_system_targets() {
    # System-specific validation logic
}
```

3. **Update Documentation**
```bash
# Add to SKILL.md documentation
```

## Testing

### Unit Tests
```bash
# Test detection functions
./tests/test-detection-functions.sh

# Test specific systems
./tests/test-pnpm-detection.sh
./tests/test-cargo-detection.sh
```

### Integration Tests
```bash
# Test with sample projects
./tests/test-sample-projects.sh

# Test integration with other skills
./tests/test-skill-integration.sh
```

## Performance

### Optimization Strategies
- **Parallel Detection**: Run multiple detection scripts simultaneously
- **Caching**: Cache detection results for repeated analysis
- **Incremental**: Only detect changed files when possible

### Benchmarks
- **Small Project**: < 1 second
- **Medium Project**: < 5 seconds
- **Large Monorepo**: < 30 seconds

## Limitations

### Current Limitations
- **Nested Configurations**: May miss deeply nested configuration files
- **Dynamic Configurations**: Cannot detect runtime-generated configurations
- **Custom Patterns**: May miss custom build system patterns

### Future Improvements
- **Machine Learning**: Use ML to detect custom patterns
- **Plugin System**: Allow custom detection plugins
- **Remote Detection**: Detect systems in remote repositories

## Contributing

### Adding New Detection Support
1. Fork the skill repository
2. Add detection patterns to appropriate script
3. Add validation logic if needed
4. Add tests for new detection
5. Update documentation
6. Submit pull request

### Reporting Issues
- Include project structure details
- Provide expected vs actual detection results
- Include relevant configuration files

## License

This skill is part of the AI skills ecosystem and follows the same licensing terms.

## Integration with Boilerplates

The **boilerplates** directory provides reference templates that inform detection patterns and help identify standard project structures:

### Detection Pattern Sources
- **TypeScript/Next.js**: `boilerplate/apps/web/typescript/nextjs/` - Reference for detecting Next.js projects
- **Rust Packages**: `boilerplate/packages/category/web/domain/package-name/rust/` - Reference for Cargo-based projects
- **Python Packages**: `boilerplate/packages/category/web/domain/package-name/python3/` - Reference for Poetry/setuptools projects
- **Infrastructure**: `boilerplate/apps/infrastructure/` - Reference for Docker, Airflow, and other infrastructure projects

### Standard Structure Detection
The detection scripts use patterns derived from boilerplates to identify:
- **File organization**: Standard `src/`, `tests/`, `docs/` structures
- **Configuration files**: Standard naming and locations for config files
- **Build targets**: Common script names and build patterns
- **Dependency patterns**: Standard dependency management approaches

### Preference Alignment
When integrating with project-adopter or project-configuration skills:
- **Detection informs preferences**: Detected project type maps to appropriate boilerplate preferences
- **Template matching**: Match detected structure against boilerplate templates
- **Compatibility assessment**: Determine which boilerplate preferences are compatible with existing project

### Example Detection Patterns
```bash
# Patterns derived from boilerplates
declare -A PROJECT_TYPES=(
    ["nextjs-typescript"]="next.config.js package.json tsconfig.json"
    ["rust-package"]="Cargo.toml src/ tests/"
    ["python-poetry"]="pyproject.toml poetry.lock src/"
    ["docker-app"]="Dockerfile docker-compose.yml"
)
```

## Related Skills

- **Project Configuration Skill** - Configure projects with standard tooling (devbox, justfile, CI/CD)
- **Monorepo Extractor Skill** - Extract projects from monorepos
- **Environment Setup Skill** - Set up development environments based on detected tooling
- **Project Migration Skill** - Migrate between tooling stacks
- **Project Adopter Skill** - Overwrite preferences with standardized workflows
- **Project Configuration Skill** - Add compatible preferences without overwriting

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/project-detection/SKILL.md`
- Scripts: `scripts/detect-build-systems.sh`, `scripts/detect-ci-cd-systems.sh`, `scripts/detect-workspace-configs.sh`, `scripts/extract-build-targets.sh`, `scripts/analyze-project-structure.sh`, `scripts/detect-all-systems.sh`
- References: `references/build-target-extraction.md`, `references/detection-capabilities.md`, `references/usage-patterns.md`

### Related Skills
- project-adopter (dependent)
- project-configuration (dependent)
- surgical-config (complementary)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

---

*This skill serves as a foundational component for project analysis and tooling detection across the AI skills ecosystem.*
