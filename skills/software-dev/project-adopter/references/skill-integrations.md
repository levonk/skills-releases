# Integration with Other Skills

This skill integrates with:

### Project Detection Skill
- **Purpose**: Comprehensive detection of project types, build systems, and tooling
- **Usage**: `source ../project-detection/scripts/detect-build-systems.sh`
- **Benefit**: Avoids duplicating detection logic
- **Reference**: [Project Detection Skill](../project-detection/SKILL.md)

### AI Development Loop Skill
- **Purpose**: Systematic 9-step workflow for high-quality development cycles
- **Usage**: Follow the enhanced workflow after project setup
- **Benefit**: Ensures consistent, high-quality development process
- **Reference**: [AI Development Loop Skill](../ai-development-loop/SKILL.md)

### Project Configuration Skill
- **Purpose**: Configure projects with standard tooling based on detection
- **Usage**: Reference for configuration patterns and templates
- **Benefit**: Leverages existing configuration expertise
- **Reference**: [Project Configuration Skill](../project-configuration/SKILL.md)

### Surgical Configuration Skill
- **Purpose**: Intelligent, non-destructive configuration file editing with project-aware tool selection
- **Usage**: Apply surgical edits to configuration files while preserving comments, formatting, and structure
- **Benefit**: Safe, deterministic configuration modifications with automatic backup and validation
- **Reference**: [Surgical Configuration Skill](../surgical-config/SKILL.md)

### Repository Health Review Skill
- **Purpose**: Comprehensive repository health analysis for outdated information, conflicting rules, undocumented standards, lessons from failures, missing tool documentation, and security/access patterns
- **Usage**: Pre-adoption health assessment and post-adoption validation
- **Benefit**: Ensures adopted projects are in good condition before integration and identifies areas needing improvement
- **Reference**: [Repository Health Review Skill](../repository-health-review/SKILL.md)

### Quality Scripts Integration (ADR 20251218002)
- **Purpose**: Single Docker-based quality script for both pre-commit hooks and CI/CD
- **Usage**: Create `scripts/run-quality-checks.sh` with configurable task sets
- **Benefit**: Parity between local and CI behavior, isolated tooling, maintainable single source of truth
- **Configuration**: Environment variables (FAST_MODE, FULL_MODE, SKIP_RUNTIME_SCAN, etc.)
- **Reference**: [Shared Quality Scripts ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251218002-shared-quality-scripts.md)

### Testing Framework Integration (ADR 20251106002)
- **Purpose**: Standardize testing framework across TypeScript projects
- **Usage**: Adopt Vitest for unit/integration tests and as E2E test runner
- **Benefit**: Fast, modern, unified testing experience with TypeScript/ESM support
- **E2E Testing**: Vitest + Stagehand/Playwright for browser automation
- **Reference**: [Vitest for Testing ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106002-vitest-for-testing.md)

### CI/CD Integration (ADR 20251106014)
- **Purpose**: Standardize CI/CD platform and local testing
- **Usage**: GitHub Actions for all CI/CD pipelines, `act` for local workflow testing
- **Benefit**: Deep GitHub integration, powerful workflow syntax, local testing capability
- **Reference**: [GitHub Actions CI/CD ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106014-cicd-strategy.md)

**Key Features:**
- **Hierarchical tool selection**: Template processors → Semantic parsers → Structural rewriters → Patch managers → Text utilities
- **Project-aware editing**: Automatically detects project type and uses appropriate tools
- **Comment preservation**: Uses yq-go to maintain comments and formatting in structured files
- **Template support**: Handles templated files like `*.json.jinja`, `*.yaml.jinja`, `*.xml.jinja`
- **Automatic backups**: Mirrored directory tree backups with timestamps
- **Loop prevention**: Safe integration with other skills including project-adopter
- **Multi-context support**: Works from chezmoi templates, deployed config, and AI tools locations

**Repository Health Analysis:**
- **Outdated Information**: Detects deprecated tools, old dates, broken links
- **Conflicting Rules**: Identifies configuration contradictions and build conflicts
- **Undocumented Standards**: Finds undocumented scripts, environment variables, custom formats
- **Lessons from Failures**: Detects TODO/FIXME patterns, temporary code, performance warnings
- **Missing Tool Documentation**: Identifies tools without setup instructions, undocumented config files
- **Security and Access Patterns**: Finds hardcoded secrets, insecure configs, permission issues

## Enhanced Workflow Integration

This skill sets up the foundation per **ADR 20260131001 Standard Developer UX Flow**, then the **ai-development-loop** skill provides the systematic workflow.

### AI Development Loop Integration

The **ai-development-loop** skill provides the systematic workflow:

1. **Foundation Check** - Ensure clean starting state
2. **Ticket Selection** - Grab next actionable ticket
3. **Start Work** - Mark ticket as in_progress
4. **High Quality** - Ensure upstream has adequate testing (mandatory per ADR 20260131001)
5. **Strategy** - Determine implementation approach (reuse, dependency, new package, external service)
6. **Implementation** - Do the actual work
7. **Verification** - Add/update/run tests and validate (mandatory per ADR 20260131001)
8. **Completion** - Mark ticket ready/closed
9. **Commit & Loop** - Commit changes and repeat

### Repository Health Review Integration

The project-adopter skill integrates with the repository health review skill to provide comprehensive analysis before and after adoption:

#### Pre-Adoption Health Analysis

```bash
# Run project adoption with automatic health reviews
./scripts/adopt-project.sh /path/to/project my-project

# The skill automatically runs:
# 1. Pre-adoption health review → .pre-adoption-health.json
# 2. Project detection and configuration
# 3. Post-adoption health review → .post-adoption-health.json
```

#### Health Review Benefits

**Before Adoption:**
- ✅ **Baseline Assessment**: Establish current repository health score
- ✅ **Critical Issue Detection**: Identify security vulnerabilities and blockers
- ✅ **Migration Planning**: Understand what needs to be fixed
- ✅ **Risk Assessment**: Evaluate adoption complexity

**After Adoption:**
- ✅ **Improvement Validation**: Measure health score improvements
- ✅ **Quality Assurance**: Verify adoption didn't introduce issues
- ✅ **Trend Tracking**: Compare before/after metrics
- ✅ **Actionable Insights**: Get specific improvement recommendations

#### Health Review Reports

The skill generates detailed JSON reports:

```json
{
  "repository": {
    "path": "/path/to/project",
    "name": "my-project",
    "last_analyzed": "2025-02-05T12:00:00Z"
  },
  "health_score": 85,
  "issues": {
    "critical": 0,
    "high": 2,
    "medium": 5,
    "low": 8,
    "total": 15
  },
  "categories": {
    "outdated_information": { "issues": 3, "severity": "warning" },
    "security_patterns": { "issues": 0, "severity": "info" },
    "conflicting_rules": { "issues": 1, "severity": "critical" }
  },
  "recommendations": [
    {
      "priority": "high",
      "category": "conflicts",
      "action": "Resolve ESLint rule conflicts",
      "files": [".eslintrc.js"]
    }
  ]
}
```

#### Health Score Interpretation

- **90-100**: Excellent repository health
- **80-89**: Good repository health
- **70-79**: Fair repository health
- **50-69**: Poor repository health
- **Below 50**: Critical repository health

#### Integration Examples

```bash
# Example output with health review integration
[INFO] Starting project adoption in standard mode for: /opt/my-project
[INFO] Project name: my-project

[STEP] Running pre-adoption repository health review
[INFO] Pre-adoption health review completed: /opt/my-project/.pre-adoption-health.json
[INFO]   Health Score: 72/100
[INFO]   Critical Issues: 1
[WARN]   ⚠️  Critical issues detected - review health report before proceeding

[STEP] Detecting project characteristics...
[INFO] Detected project type: TypeScript
[INFO] Detected build system: npm
[INFO] Detected package manager: pnpm

[STEP] Applying surgical configurations...
[INFO] Configured TypeScript project with standard tooling

[STEP] Running post-adoption repository health review
[INFO] Post-adoption health review completed: /opt/my-project/.post-adoption-health.json
[INFO]   🎉 Health score improved by +13 points (72 → 85)

[INFO] ✅ Project adoption completed successfully!
[INFO] Next steps:
[INFO]   1. Review the generated configuration files
[INFO]   2. Review health reports (.pre-adoption-health.json and .post-adoption-health.json)
[INFO]   3. Run 'just bootstrap' to install dependencies
[INFO]   4. Run 'just dev' to start development
[INFO]   5. Address any critical issues identified in health reviews
```

### Project Detection (Using Project Detection Skill)

Use the dedicated project-detection skill for comprehensive analysis:

```bash
# Source the detection functions
DETECTION_SKILL_PATH="$(dirname "${BASH_SOURCE[0]}")/../project-detection"
source "$DETECTION_SKILL_PATH/scripts/detect-build-systems.sh"
source "$DETECTION_SKILL_PATH/scripts/detect-ci-cd-systems.sh"
source "$DETECTION_SKILL_PATH/scripts/detect-workspace-configs.sh"

# Detect all systems
build_systems=$(detect_systems "$PROJECT_PATH" "false")
ci_cd_systems=$(detect_ci_cd_systems "$PROJECT_PATH" "false")
workspace_configs=$(analyze_workspace_configs "$PROJECT_PATH" "$PROJECT_NAME" "false")

# Output results
echo "Detected build systems: $build_systems"
echo "Detected CI/CD: $ci_cd_systems"
echo "Workspace configs: $workspace_configs"
```

**Detection capabilities include:**
- **Build Systems**: npm, pnpm, cargo, poetry, go modules, etc.
- **CI/CD Platforms**: GitHub Actions, GitLab CI, CircleCI, etc.
- **Workspace Tools**: pnpm workspaces, npm workspaces, Nx (preferred per ADR 20260419001), Turbo (legacy), etc.
- **Development Tools**: ESLint, Prettier, Black, Ruff, Clippy, etc.

### Surgical Configuration Integration

Use the surgical-config skill for intelligent, non-destructive configuration modifications:

#### Environment Setup
```bash
# Ensure surgical-config environment is ready
~/.config/ai/skills/software-dev/surgical-config/scripts/ensure-environment.sh --setup
```

#### Configuration File Updates
```bash
# Update package.json with surgical precision
~/.config/ai/skills/software-dev/surgical-config/scripts/surgical-edit.sh \
  --detect-project package.json '.dependencies += {"surgical-config": "^0.1.0"}'

# Update Cargo.toml preserving comments
~/.config/ai/skills/software-dev/surgical-config/scripts/surgical-edit.sh \
  --detect-project Cargo.toml '.dependencies += {"serde": {version = "1.0", features = ["derive"]}}'

# Process templated configuration files
~/.config/ai/skills/software-dev/surgical-config/scripts/surgical-edit.sh \
  config.xml.jinja '.config.port = 8080'

# Update environment files safely
~/.config/ai/skills/software-dev/surgical-config/scripts/surgical-edit.sh \
  .env 'DEBUG=false' 'DEBUG=true'
```

#### Integration with Project Detection
The surgical-config skill automatically integrates with project-detection:

```bash
# Project-aware editing (detects project type automatically)
~/.config/ai/skills/software-dev/surgical-config/scripts/surgical-edit.sh \
  --detect-project config.json '.database.host = "localhost"'

# This will:
# 1. Detect project type (Node.js, Rust, Python, etc.)
# 2. Choose appropriate tools (yq-go, jq, comby, etc.)
# 3. Apply edit while preserving comments and formatting
# 4. Create automatic backup in .cache/
# 5. Validate the result
```

#### Safe Configuration Management
- **Automatic backups**: All changes are backed up to `.cache/` directory
- **Comment preservation**: Uses yq-go to maintain comments in structured files
- **Template support**: Handles `*.json.jinja`, `*.yaml.jinja`, `*.xml.jinja` files
- **Validation**: Validates syntax and structure after modifications
- **Rollback**: Automatically restores from backup if validation fails

#### Loop Prevention
The surgical-config skill includes built-in loop prevention when called from project-adopter:
- Detects project-adopter execution context
- Automatically disables project detection to prevent infinite loops
- Continues with standard surgical editing functionality
- Can be overridden with `--force-detection` if needed

#### Automated Adoption Script
Use the provided `adopt-project.sh` script for complete project adoption:

```bash
# Adopt current directory
./scripts/adopt-project.sh

# Adopt specific project
./scripts/adopt-project.sh /path/to/my-project my-project

# Adopt with custom name
./scripts/adopt-project.sh ./my-cool-app cool-app
```

**The script automatically:**
- Detects project type and existing configuration
- Applies surgical configuration updates using project-aware editing
- Creates standard developer UX files (devbox.json, justfile, .envrc, README.md)
- Preserves comments and formatting in configuration files
- Sets up proper project structure and tooling
- Provides next steps for development

#### Loop Prevention and Safety
The project-adopter includes comprehensive loop prevention:

**Automatic Detection:**
- Detects if project-adopter is already running
- Prevents nested calls from the same process tree
- Checks for surgical-config execution conflicts
- Analyzes parent process and environment variables

**Control Options:**
```bash
# Disable loop prevention (use with caution)
./scripts/adopt-project.sh --no-loop-prevention

# Force adoption even if loops detected
./scripts/adopt-project.sh --force-adoption

# Verbose output for debugging
./scripts/adopt-project.sh --verbose
```

**Safety Features:**
- **Lock files**: `/tmp/.project-adopter.lock` and `/tmp/.surgical-config.lock`
- **PID tracking**: Monitors running processes to detect conflicts
- **Process tree analysis**: Prevents nested calls from same process tree
- **Automatic cleanup**: Removes stale lock files on exit
- **Non-breaking**: Loop prevention doesn't break core functionality
