# Organizational Structure Templates

## Department Templates

### Standard Department Structure
```yaml
department_name:
  title: "Human-Readable Department Name"
  director_role_id: "department-director"
  roles:
    - id: "department-director"
      title: "Department Director"
      level: "director"
      department: "department_name"
      reports_to: "shared-services-director"
      synopsis: "Brief one-line description"
      rationale: "Why this department exists"
      manages: ["department-manager-1", "department-manager-2"]
    
    - id: "department-manager-1"
      title: "Manager Role 1"
      level: "manager"
      department: "department_name"
      reports_to: "department-director"
      synopsis: "Manager responsibilities"
      manages: ["department-specialist-1", "department-specialist-2"]
    
    - id: "department-specialist-1"
      title: "Specialist Role 1"
      level: "specialist"
      department: "department_name"
      reports_to: "department-manager-1"
      synopsis: "Specialist responsibilities"
```

### Sales Department Template
```yaml
sales:
  title: "Sales"
  director_role_id: "sales-director"
  roles:
    - id: "sales-director"
      title: "Sales Director"
      level: "director"
      department: "sales"
      reports_to: "shared-services-director"
      synopsis: "Overall sales strategy and team leadership"
      rationale: "Leads revenue generation and sales operations"
      manages: ["sales-operations-manager", "ecommerce-sales-manager"]
    
    - id: "sales-operations-manager"
      title: "Sales Operations Manager"
      level: "manager"
      department: "sales"
      reports_to: "sales-director"
      synopsis: "Sales process optimization and enablement"
      rationale: "Implements Scaled Selling principles"
      manages: ["sales-lead-generation-specialist", "sales-account-executive", "sales-account-manager"]
    
    - id: "sales-lead-generation-specialist"
      title: "Lead Generation Specialist"
      level: "specialist"
      department: "sales"
      reports_to: "sales-operations-manager"
      synopsis: "Prospect identification and qualification"
      rationale: "Part of Scaled Selling - consistent lead flow"
    
    - id: "sales-account-executive"
      title: "Account Executive"
      level: "specialist"
      department: "sales"
      reports_to: "sales-operations-manager"
      synopsis: "Deal closing and new customer acquisition"
      rationale: "Specialized closing role in Scaled Selling model"
    
    - id: "sales-account-manager"
      title: "Account Manager"
      level: "specialist"
      department: "sales"
      reports_to: "sales-operations-manager"
      synopsis: "Customer retention and expansion"
      rationale: "Post-sale specialization for customer success"
```

### Marketing Department Template
```yaml
marketing:
  title: "Marketing"
  director_role_id: "marketing-director"
  roles:
    - id: "marketing-director"
      title: "Marketing Director"
      level: "director"
      department: "marketing"
      reports_to: "shared-services-director"
      synopsis: "Overall marketing strategy and brand management"
      rationale: "Leads demand generation and marketing operations"
      manages: ["marketing-operations-manager", "demand-generation-manager", "product-marketing-specialist"]
    
    - id: "marketing-operations-manager"
      title: "Marketing Operations Manager"
      level: "manager"
      department: "marketing"
      reports_to: "marketing-director"
      synopsis: "Marketing operations and budget management"
      rationale: "Coordinates marketing team and resources"
      manages: ["marketing-paid-media-manager"]
    
    - id: "marketing-paid-media-manager"
      title: "Paid Media Manager"
      level: "manager"
      department: "marketing"
      reports_to: "marketing-operations-manager"
      synopsis: "Cross-platform advertising strategy"
      rationale: "Manages advertising specialists"
      manages: ["marketing-google-ads-specialist", "marketing-meta-ads-specialist", "marketing-x-ads-specialist"]
```

## Role Templates

### Director Role Template
```yaml
- id: "department-director"
  title: "Department Director"
  level: "director"
  department: "department_name"
  reports_to: "shared-services-director"
  synopsis: "Strategic leadership and department management"
  rationale: "Provides executive oversight for department functions"
  manages: ["department-manager-1", "department-manager-2"]
  scope: "Department-wide strategy, team leadership, budget oversight"
```

### Manager Role Template
```yaml
- id: "department-function-manager"
  title: "Function Manager"
  level: "manager"
  department: "department_name"
  reports_to: "department-director"
  synopsis: "Team management and operational oversight"
  rationale: "Manages day-to-day operations and team performance"
  manages: ["department-specialist-1", "department-specialist-2"]
  scope: "Team management, process optimization, resource allocation"
```

### Specialist Role Template
```yaml
- id: "domain-specialist"
  title: "Domain Specialist"
  level: "specialist"
  department: "department_name"
  reports_to: "department-manager"
  synopsis: "Specialized expertise in specific domain"
  rationale: "Provides deep expertise in functional area"
  scope: "Domain-specific tasks, analysis, and execution"
```

## Cross-Functional Role Template
```yaml
- id: "cross-functional-specialist"
  title: "Cross-Functional Specialist"
  level: "specialist"
  department: "primary_department"
  reports_to: "primary-manager"
  synopsis: "Coordinates across multiple departments"
  rationale: "Ensures alignment and collaboration"
  cross_functional: ["secondary-department-1", "secondary-department-2"]
  scope: "Cross-departmental coordination and integration"
```

## Specialized Office Templates

### Family & Personal Office Template
```yaml
family_personal:
  title: "Family & Personal Office"
  manager_role_id: "family-office-manager"
  location: "personal"
  roles:
    - id: "family-office-manager"
      title: "Family Office Manager"
      level: "manager"
      department: "family_personal"
      reports_to: "chief-of-staff"
      synopsis: "Personal affairs and family office management"
      rationale: "Coordinates personal and family matters"
      location: "Family & Personal Office"
```

### Business Office Template
```yaml
business_office:
  title: "Business Office"
  manager_role_id: "business-portfolio-manager"
  roles:
    - id: "business-portfolio-manager"
      title: "Business Portfolio Manager"
      level: "manager"
      department: "business_office"
      reports_to: "chief-of-staff"
      synopsis: "Established business portfolio management"
      rationale: "Oversees established business operations"
      manages: ["business-development-manager", "property-manager"]
```

## Validation Templates

### Role Validation Checklist
```yaml
validation_checklist:
  required_fields:
    - id: "Must be unique and follow format"
    - title: "Human-readable role title"
    - level: "director|manager|specialist"
    - department: "Parent department"
    - reports_to: "Valid role ID"
    - synopsis: "One-line description"
    - rationale: "Business justification"
  
  optional_fields:
    - manages: "List of direct report IDs"
    - cross_functional: "Cross-department relationships"
    - existing: "true|false for existing roles"
    - note: "Additional context"
    - scope: "Role scope definition"
    - location: "Specific location if different from department"
```

### Department Validation Checklist
```yaml
department_validation:
  structure_requirements:
    - title: "Human-readable department name"
    - director_role_id: "ID of department director"
    - roles: "List of role definitions"
  
  consistency_checks:
    - All roles belong to correct department
    - Director role exists and reports appropriately
    - No duplicate role IDs
    - All reports_to references are valid
    - Hierarchical relationships are logical
```

## Migration Templates

### Role Renaming Template
```yaml
role_migration:
  old_role:
    title: "Old Role Title"
    id: "old-role-id"
  
  new_role:
    title: "New Role Title"
    id: "same-role-id"  # Keep same ID for stability
    changes:
      - "Updated title"
      - "Modified responsibilities"
      - "Changed reporting structure"
  
  migration_steps:
    1: "Update role title in YAML structure"
    2: "Update synopsis and rationale"
    3: "Update any references by title"
    4: "Validate all relationships"
    5: "Regenerate diagrams"
```

### Department Restructuring Template
```yaml
department_restructure:
  before:
    old_department:
      title: "Old Department Name"
      roles: ["role-1", "role-2", "role-3"]
  
  after:
    new_department_1:
      title: "New Department 1"
      roles: ["role-1", "role-2"]
    
    new_department_2:
      title: "New Department 2"
      roles: ["role-3"]
  
  changes:
    - "Split old department into two"
    - "Updated reporting relationships"
    - "Added new department directors"
```

---

*These templates provide standardized patterns for organizational structure design and maintenance.*
