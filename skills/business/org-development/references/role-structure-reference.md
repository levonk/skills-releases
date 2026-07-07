# Role Structure Reference

Detailed reference for role fields, department structure, and naming conventions used in the Agent Org framework.

## Role Structure

### Required Fields

```yaml
id: "unique-role-identifier"           # Primary key for references
title: "Human-Readable Role Title"     # Display name
level: "director|manager|specialist"   # Organizational level
department: "department-name"          # Parent department
reports_to: "parent-role-id"           # ID of reporting manager
manages: ["role-id-1", "role-id-2"]    # List of direct reports
location: "department-path"            # Organizational location
rationale: "Why this role exists"       # Business justification
synopsis: "Brief role description"      # One-line summary
```

### Optional Fields

```yaml
cross_functional: ["department-1", "department-2"]  # Cross-department relationships
existing: true/false                              # Existing vs new role
note: "Additional context"                        # Extra information
scope: "Specific responsibilities"                # Role scope definition
tags: ["ex-tag1", "ex-tag2"]                # Search tags
aliases: ["ex-alias1", "ex-alias2"]                # Search tags
```

## Department Structure

### Standard Departments

- **executive-operations** - Executive support and coordination
- **brand-communications** - PR, content, creative, community
- **sales** - Revenue generation and account management
- **marketing** - Demand generation and brand awareness
- **customer-service** - Support and success management
- **security** - Physical and digital security
- **finance** - Financial management and planning
- **legal** - Legal compliance and contracts
- **data-research** - Analytics and intelligence
- **technology-engineering** - Technical infrastructure
- **people-workplace** - HR and workplace management
- **strategy-governance-risk** - Strategic planning and risk
- **financial-markets** - Investment and trading operations

### Specialized Offices

- **family-personal** - Personal affairs management
- **business-office** - Established business operations
- **venture-studio** - Innovation and startup incubation
- **philanthropy** - Charitable giving and impact

## Reference Materials

### Role ID Convention

- **Format**: `[department]-[role-type]-[specialization]`
- **Examples**:
  - `sales-director` (Sales department director)
  - `security-ai-engineer` (Security AI specialist)
  - `marketing-content-specialist` (Marketing content role)

### Department Naming

- **Use kebab-case** for department names
- **Be descriptive but concise**
- **Maintain consistency** across all documents

### Validation Rules

- **Unique IDs**: No duplicate role IDs
- **Valid references**: All reports_to IDs must exist
- **Complete hierarchies**: No orphaned roles
- **Consistent levels**: Level matches responsibilities

## Examples

### Example: Adding New AI Security Role

```yaml
- id: "security-ai-researcher"
  title: "AI Security Researcher"
  level: "specialist"
  department: "security"
  reports_to: "security-director"
  synopsis: "Research emerging AI security threats and mitigation strategies"
  rationale: "Proactive AI security research to prevent emerging threats"
  existing: false
```

### Example: Department Restructuring

```yaml
# Before: Marketing under Brand & Communications
brand_communications:
  title: "Brand & Communications"
  roles:
    - id: "brand-director"
    - id: "marketing-manager"

# After: Separate Marketing department
marketing:
  title: "Marketing"
  roles:
    - id: "marketing-director"      # Renamed from marketing-manager
      level: "director"             # Promoted to director level
      reports_to: "shared-services-director"
```
