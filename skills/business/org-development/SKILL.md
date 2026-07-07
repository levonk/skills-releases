---
name: org-development
description: Comprehensive organizational design, restructuring, and role management for Agent Org framework. Use when designing organizational structures, managing role changes, implementing department reorganizations, maintaining organizational consistency, or generating org charts. Triggers on requests like 'design org structure', 'add role', 'restructure department', 'generate org diagram'. Supports single source of truth management, role ID systems, department hierarchies, and organizational diagram generation.
synopsis: Design and manage organizational structures with ID-based role references and automated diagram generation
version: 1.0.0
category: business/organization
date:
  created: "2026-06-10"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags:
  - "ai/skill"
  - "organizational-design"
  - "role-management"
  - "structure-planning"
  - "agent-org"
  - "hierarchy-management"
see-also:
  - template: "task-triage"
    relationship: "related"
    description: "Task prioritization framework that interacts with org structure for requestor adjustments"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies: []
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Organizational Development

## Quick Start

Use this skill for organizational tasks:

1. **Role management** - Add, modify, or remove roles with ID-based references
2. **Department design** - Create or restructure departments and hierarchies
3. **Single source of truth** - Maintain consistent org structure across multiple views
4. **Diagram generation** - Generate organizational charts automatically
5. **Conflict resolution** - Handle role conflicts and organizational changes

## Core Principles

### Entity Specialist → Shared Services Executor Pattern

This organizational design pattern separates strategic decision-making from operational execution:

#### **Entity Specialists (Strategic Layer)**

- **Location**: Within each business entity (Venture Studios, Philanthropy Office, etc.)
- **Purpose**: Define strategy, requirements, and specifications for their domain
- **Role**: "What we need" and "Why we need it"
- **Examples**:
  - Director, Brand Management - Venture Studios (defines brand strategy for portfolio)
  - Director, Brand Management - Philanthropic Foundation (defines philanthropic brand needs)
  - Director, Brand Management - Principal's Office (defines personal brand requirements)
  - Director, Brand Management - Enterprise (defines conglomerate brand strategy)

#### **Shared Services Executors (Operational Layer)**

- **Location**: Centralized Shared Services departments
- **Purpose**: Execute work based on entity specifications and requirements
- **Role**: "Let me help guide you", "How we do it" and "When we do it"
- **Examples**:
  - Brand & Communications Director (executes brand strategies for all entities)
  - Creative Studio Manager (produces creative assets per entity specifications)
  - Content Manager (creates content based on entity requirements)
  - PR Manager (manages PR per entity strategic needs)

#### **Pattern Benefits**

1. **Specialization**: Entity specialists focus on domain expertise
2. **Efficiency**: Shared Services provides consistent, scalable execution
3. **Consistency**: Centralized execution maintains quality standards
4. **Flexibility**: Entities can change strategy without operational disruption
5. **Accountability**: Clear separation between strategy and execution

#### **Implementation Rules**

- **Never place entity specialists in Shared Services** - they belong in their entities
- **Shared Services only contains execution roles** - no strategic decision-making
- **Entity specialists make requests to Shared Services** - not the reverse
- **Shared Services serves all entities** - not just one specific entity

### ID-Based Role Management

Every role has a unique ID that serves as the primary key:

- **Format**: `department-role-type` (e.g., `sales-director`, `security-ai-engineer`)
- **Purpose**: Stable references that survive role renames and reorganizations
- **Usage**: Reference roles by ID in instructions, not by title

### Single Source of Truth

Maintain organizational structure in one place:

- **YAML structure** contains authoritative data
- **Multiple views** generated automatically (full, department-level, role-specific)
- **No dual maintenance** - update once, regenerate all views

### Progressive Disclosure

Organize content by detail level:

- **Level 1**: Department blocks (high-level overview)
- **Level 2**: Full hierarchy with all roles (detailed view)
- **Level 3**: Individual departments (focused views)

## Role Structure

For the full role structure specification including required and optional YAML fields, department listings, naming conventions, and validation rules, see `references/role-structure-reference.md`.

Key points:

- Every role has a unique `id` (format: `department-role-type`)
- Required fields: `id`, `title`, `level`, `department`, `reports_to`, `rationale`, `synopsis`
- Optional fields: `cross_functional`, `existing`, `note`, `scope`, `tags`, `aliases`
- Standard departments and specialized offices are defined in the reference

## Workflow Instructions

For detailed bash workflow examples including adding roles, restructuring departments, conflict resolution, and diagram generation commands, see `references/workflow-examples.md`.

### 1. Adding New Roles

1. Choose a unique ID following the `department-role-type` convention
2. Add the role to the YAML structure with all required fields
3. Update any references to use the new ID

### 2. Restructuring Departments

1. Plan changes — identify affected roles by ID and map new reporting relationships
2. Update the YAML structure — move role IDs and update `reports_to` relationships
3. Regenerate views using the diagram generation script

### 3. Conflict Resolution

1. Identify conflicts — duplicate titles, conflicting reporting relationships, missing references
2. Resolve by ID — keep stable IDs, update titles and relationships, maintain referential integrity
3. Validate structure using the validation scripts

## Diagram Generation

The diagram generation script is located at `scripts/generate-org-diagrams.sh`.

This script:

- Reads YAML structure from `references/organization-structure.yml`
- Generates Mermaid diagrams for different organizational views
- Outputs to the Agent Org directory for easy access
- Supports multiple view types (full, departments, role-specific)

For available views and custom view commands, see `references/workflow-examples.md`.

## Integration Points

### Briefing Memo Integration

Reference: `~/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/execution/briefingmemo/SKILL.md`

- **Board structure** for organizational decisions
- **Research team** for role analysis and design
- **Decision framework** for organizational changes

### Agent Org Framework

This is the top level structure of the org, check with the

- **Office of the Principal** - Executive structure
- **Shared Services** - Centralized support functions
- **Business Office** - Established operations
- **Venture Studio** - Innovation activities

---

*See [references/](references/) for detailed documentation and examples.*

---
## Context Declaration

### File Paths

- Main skill: `config/ai/skills/business/org-development/SKILL.md`
- References: `config/ai/skills/business/org-development/references/role-structure-reference.md`
- References: `config/ai/skills/business/org-development/references/workflow-examples.md`
- References: `config/ai/skills/business/org-development/references/organization-structure.yml`
- References: `config/ai/skills/business/org-development/references/role-id-system.md`
- References: `config/ai/skills/business/org-development/references/structure-templates.md`
- Scripts: `config/ai/skills/business/org-development/scripts/`
- Templates: `config/ai/skills/business/org-development/templates/`

### Related Skills

- task-triage (related) — Task prioritization framework that interacts with org structure for requestor adjustments
- base-ai-guidance (base-framework) — Shared framework for creating all AI guidance types

### Project Information

- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
