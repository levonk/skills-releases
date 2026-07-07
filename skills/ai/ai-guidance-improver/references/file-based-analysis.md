# File-Based Mode Analysis Framework

When operating in file-based mode (analyzing and improving existing files), follow this comprehensive process:

## Core Principles

This skill applies the same quality principles used in creating new AI guidance, but in reverse: it analyzes existing files and identifies areas for improvement.

## Analysis Framework

### Step 1: Identify Issues

Analyze the target AI guidance file(s) for the following issues:

#### Conflicting Instructions
- **Symptom**: Multiple instructions that contradict each other
- **Example**: "Always use X" in one section, "Never use X" in another
- **Fix**: Resolve conflicts by clarifying intent or removing conflicting guidance

#### Duplicated Instructions
- **Symptom**: Same information repeated in multiple places
- **Example**: Same procedure explained in three different sections
- **Fix**: Consolidate to single source of truth with references

#### Inadequate Frontmatter
- **Symptom**: Missing or incomplete frontmatter fields
- **Example**: Missing `last-used` field, no `see_also` relationships, no `tags`
- **Fix**: Apply standard frontmatter template from `base-frontmatter.md.tmpl`

#### Poor Progressive Disclosure
- **Symptom**: Detailed information inline instead of in reference files
- **Example**: 200-line troubleshooting guide in main body instead of separate file
- **Fix**: Move detailed information to reference files with clear pointers

#### Scattered Context
- **Symptom**: File paths, URLs, project info scattered throughout
- **Example**: `~/p/gh/levonk/dotfiles/...` repeated in multiple places
- **Fix**: Consolidate context at bottom in Context Declaration section

#### Specific vs General Solutions
- **Symptom**: Hardcoded paths/URLs where indirect references would work
- **Example**: Full user-specific path instead of "the project's AGENTS.md"
- **Fix**: Use indirect references and declare actual paths in context section

#### Multiple Audiences Without Separation
- **Symptom**: One file serving multiple distinct audiences without separation
- **Example**: Boilerplate repo with deployer and creator guidance mixed
- **Fix**: Use progressive disclosure to separate audience-specific information

#### Missing Jinja Templating
- **Symptom**: Repeated patterns that could be shared via templates
- **Example**: Same frontmatter structure copied across 10 files
- **Fix**: Create shared templates and use jinja includes

#### Stale or Contradictory Text
- **Symptom**: Documentation that no longer reflects current reality
- **Example**: References to deleted files, outdated workflows, rules that were superseded
- **Fix**: Remove stale text immediately instead of explaining why it changed

#### Diary Entries Instead of Stable Contracts
- **Symptom**: Documentation records history or process narrative instead of durable contracts
- **Example**: "We used to do X but switched to Y" instead of just stating the current rule
- **Fix**: Document stable contracts, not history. Delete stale notes instead of explaining them

#### Misplaced Detail (Wrong Level)
- **Symptom**: Broad rules in child docs or concrete details in parent docs
- **Example**: Repo-wide coding standards inside a sub-package AGENTS.md, or package-specific file paths in the root
- **Fix**: Put broad rules in parent docs and concrete details in child docs

#### Warnings for Non-Existent Risks
- **Symptom**: Cautions about risks that no longer apply
- **Example**: "Be careful not to break the legacy build system" when the legacy system was removed
- **Fix**: Trim warnings for risks that no longer exist

### Step 2: Prioritize Improvements

Not all issues are equally important. Prioritize based on:

**High Priority** (Fix immediately):
- Conflicting instructions (breaks functionality)
- Duplicated critical information (maintenance burden)
- Missing required frontmatter fields (breaks discovery)

**Medium Priority** (Fix soon):
- Poor progressive disclosure (token inefficiency)
- Scattered context (cache inefficiency)
- Specific vs general issues (flexibility)

**Low Priority** (Fix when convenient):
- Missing jinja templating (maintenance optimization)
- Minor audience separation issues (usability improvement)

### Step 3: Apply Improvements

For each identified issue, apply the appropriate fix:

#### Applying Standard Frontmatter

Use the base frontmatter template:

```jinja2
{{{ include "includes/base-frontmatter.md" . }}}
```

Customize fields based on the guidance type (skill, workflow, agent, prompt).

#### Implementing Progressive Disclosure

1. **Identify detailed sections** (>50 lines or deeply nested)
2. **Create reference files** in `references/` directory
3. **Add clear pointers** in main body
4. **Include context guidance** on when to read each reference

**Example transformation:**

**Before:**
```markdown
## Troubleshooting
[200 lines of detailed troubleshooting steps]
```

**After:**
```markdown
## Troubleshooting
For common issues and solutions, see [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md).

### Quick Fixes
- Issue 1: Quick solution
- Issue 2: Quick solution

### When to Read Full Guide
- When quick fixes don't resolve the issue
- When you need detailed diagnostic procedures
- When dealing with complex multi-step issues
```

#### Consolidating Context

Move all file paths, URLs, and project-specific information to a Context Declaration section at the bottom:

```markdown
---
## Context Declaration

### File Paths
- Main file: `config/ai/skills/category/skill/SKILL.md`
- References: `config/ai/skills/category/skill/references/`

### External Resources
- Documentation: https://example.com/docs
- API reference: https://api.example.com

### Project Information
- Project: my-project
- Repository: https://github.com/user/repo
```

Replace scattered references with indirect references:
- "See `~/p/gh/levonk/dotfiles/AGENTS.md`" → "See the project's AGENTS.md"
- "Use the script at `~/p/gh/levonk/dotfiles/scripts/foo.sh`" → "Use the project's foo script"

#### Separating Multiple Audiences

For files serving multiple audiences:

1. **Identify each audience** and their information needs
2. **Create audience-specific sections** or separate files
3. **Add clear navigation** to guide each audience
4. **Use progressive disclosure** to hide audience-specific details

**Example for boilerplate repository:**

```markdown
## Using Boilerplates

For deploying existing boilerplates, see [Quick Start Guide](docs/quick-start.md).

For creating or modifying boilerplates, see [Boilerplate Development Guide](docs/development.md).

### Quick Navigation
- **I want to deploy a boilerplate**: See Quick Start Guide
- **I want to create a new boilerplate**: See Development Guide
- **I want to modify an existing boilerplate**: See Development Guide
```

#### Applying Jinja Templating

For repeated patterns:

1. **Identify repeated content** across multiple files
2. **Create shared template** in `includes/` directory
3. **Replace with jinja include** in each file
4. **Update template** to propagate changes

**Example:**

**Before (in 10 files):**
```yaml
---
name: skill-name
description: ...
date:
  created: "2026-01-01"
  updated: "2026-01-01"
  last-used: "2026-01-01"
---
```

**After:**
```yaml
---
{{{ include "includes/base-frontmatter.md" . }}}
name: skill-name
description: ...
```

### Step 4: Validate Changes

After applying improvements:

1. **Check for new conflicts** introduced by changes
2. **Verify all references** point to valid files/sections
3. **Test jinja templates** render correctly
4. **Ensure frontmatter** is valid YAML
5. **Confirm context declaration** is complete and accurate

### Step 5: Document Changes

For significant improvements, document:

1. **What was changed** and why
2. **Benefits achieved** (token savings, maintainability, etc.)
3. **Any breaking changes** for consumers
4. **Migration guide** if needed

## Type-Specific Guidance

### Skills

**Skill-specific issues to check:**
- Missing `last-used` field in frontmatter
- SKILL.md body exceeding 500 lines
- Missing `see_also` relationships for dependencies
- No context declaration at bottom
- Bundled resources not properly referenced

**Common improvements:**
- Apply standard skill frontmatter
- Move detailed procedures to reference files
- Add context declaration with skill-specific paths
- Implement progressive disclosure for complex workflows

### Workflows

**Workflow-specific issues to check:**
- Missing workflow-specific frontmatter fields
- Step sequences not clearly defined
- Missing safety and concurrency controls
- No tool usage documentation
- Phase transitions unclear

**Common improvements:**
- Apply standard workflow frontmatter
- Clarify phase boundaries and completion criteria
- Document tool usage and dependencies
- Add safety controls and concurrency settings
- Implement progressive disclosure for complex phases

### Agents

**Agent-specific issues to check:**
- Missing agent-specific frontmatter fields
- Incomplete capability documentation
- Missing input/output schemas
- No runtime constraints specified
- Integration points unclear

**Common improvements:**
- Apply standard agent frontmatter
- Document capabilities with examples
- Define clear input/output schemas
- Specify runtime constraints and timeouts
- Add integration documentation

### Prompts

**Prompt-specific issues to check:**
- Missing prompt-specific frontmatter fields
- No template variable documentation
- Unclear expected inputs/outputs
- Missing usage examples
- No template structure documentation

**Common improvements:**
- Apply standard prompt frontmatter
- Document all template variables
- Provide clear usage examples
- Specify expected input/output formats
- Add template structure documentation

### AGENTS.md

**AGENTS.md-specific issues to check:**
- Missing project-level context
- No clear hierarchy or navigation
- Universal rules not specified
- Missing JIT index for sub-directories
- No definition of done

**Common improvements:**
- Add project snapshot and setup instructions
- Implement hierarchical structure with sub-AGENTS.md files
- Define universal rules and conventions
- Create JIT index for navigation
- Specify clear definition of done

## Batch Processing

For improving multiple files:

1. **Start with shared templates** - Create base templates first
2. **Process by type** - Handle all skills, then all workflows, etc.
3. **Apply consistently** - Use the same improvements across all files of the same type
4. **Validate incrementally** - Check each file before moving to the next
5. **Document patterns** - Note common issues for future reference
