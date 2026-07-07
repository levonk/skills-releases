#!/bin/bash
# Agent Org Structure Generator
# Usage: ./scripts/generate-org-diagrams.sh [full|departments|obsidian|<department-name>]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
YAML_FILE="$SKILL_DIR/references/organization-structure.yml"
OUTPUT_DIR="/Users/micro/Documents/2ndbrain/2ndbrain/Work/01 OandO/Agent Org"
TEMP_DIR="/tmp/agent-org-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"; }
error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"; exit 1; }

# Cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Create temp directory
mkdir -p "$TEMP_DIR"

# Extract YAML from the structure file
extract_yaml() {
    log "Reading YAML structure..."
    
    # Copy the YAML file to temp location for processing
    cp "$YAML_FILE" "$TEMP_DIR/structure.yaml"
    
    if [[ ! -s "$TEMP_DIR/structure.yaml" ]]; then
        error "Failed to read YAML structure from: $YAML_FILE"
    fi
    
    log "YAML structure read successfully"
}

# Generate full detailed Mermaid diagram
generate_full_diagram() {
    log "Generating full detailed Mermaid diagram..."
    
    cat > "$OUTPUT_DIR/Office of the Principal.md" << 'EOF'
# Office of the Principal - Complete Organizational Chart

This document contains the complete organizational chart for the Agent Org structure.

```mermaid
graph TD
    %% Executive Level
    Principal[Principal] --> ChiefOfStaff[Chief of Staff (CoS)]
    
    %% Shared Services Office
    ChiefOfStaff --> SharedServices[Shared Services Office<br/>Director: Director of Shared Services (SSCoord)]
    
    %% Executive Operations
    SharedServices --> ExecOps[Executive Operations]
    ExecOps --> EventCoord[Event Coordinator]
    ExecOps --> EventStrategist[Event Strategist]
    ExecOps --> TaskCoord[Task Coordinator]
    ExecOps --> BriefingMgr[Daily Briefing Manager]
    ExecOps --> OKRMgr[OKR Program Manager]
    
    %% Brand & Communications
    SharedServices --> BrandComms[Brand & Communications]
    BrandComms --> BrandDir[Brand & Communications Director]
    BrandComms --> PRMgr[PR Manager]
    BrandComms --> ContentMgr[Content Manager]
    BrandComms --> CreativeMgr[Creative Studio Manager]
    BrandComms --> SocialMgr[Social Media Manager]
    BrandComms --> CrisisLead[Crisis Communications Lead]
    BrandComms --> NarrativeStrat[Narrative Strategist]
    BrandComms --> SpeechWriter[Speech Writer]
    BrandComms --> BizViz[Business Visualization Specialist]
    
    %% Community Team
    BrandComms --> CommDir[Community Director]
    CommDir --> CommGrowthMgr[Community Growth Manager]
    CommDir --> CommOpsMgr[Community Operations Manager]
    CommDir --> CommContent[Community Content Producer]
    CommDir --> CommMgr[Community Manager]
    
    %% Sales Department
    SharedServices --> Sales[Sales]
    Sales --> SalesDir[Sales Director]
    SalesDir --> SalesOpsMgr[Sales Operations Manager]
    SalesDir --> eCommerceMgr[eCommerce Sales Manager]
    
    %% Sales Teams
    SalesOpsMgr --> LeadGenSpec[Lead Generation Specialist]
    SalesOpsMgr --> AcctExec[Account Executive]
    SalesOpsMgr --> AcctMgr[Account Manager]
    
    eCommerceMgr --> AmazonSpec[Amazon Seller Specialist]
    eCommerceMgr --> TikTokMgr[TikTok Shop Manager]
    eCommerceMgr --> MarketplaceSpec[Marketplace Specialist]
    
    %% Marketing Department
    SharedServices --> Marketing[Marketing]
    Marketing --> MktgDir[Marketing Director]
    MktgDir --> MktgOpsMgr[Marketing Operations Manager]
    MktgDir --> DemandGenMgr[Demand Generation Manager]
    MktgDir --> ProdMktgSpec[Product Marketing Specialist]
    MktgDir --> CustExpMgr[Customer Experience Manager]
    MktgDir --> ReferralMgr[Referral Program Manager]
    
    %% Marketing Teams
    MktgOpsMgr --> PaidMediaMgr[Paid Media Manager]
    PaidMediaMgr --> GoogleSpec[Google Ads Specialist]
    PaidMediaMgr --> MetaSpec[Meta Ads Specialist]
    PaidMediaMgr --> XSpec[X Ads Specialist]
    PaidMediaMgr --> AdPlatformSpec[Ad Platform Specialist]
    
    DemandGenMgr --> ContentSpec[Content Marketing Specialist]
    
    %% Customer Service Department
    SharedServices --> CustService[Customer Service]
    CustService --> CustServiceDir[Customer Service Director]
    CustServiceDir --> CustServiceMgr[Customer Service Manager]
    CustServiceDir --> CustSuccessMgr[Customer Success Manager]
    
    CustServiceMgr --> CustSupport[Customer Support Specialist (Tier 1)]
    CustServiceMgr --> TechSupport[Technical Support Specialist (Tier 2)]
    
    %% Security Department
    SharedServices --> Security[Security]
    Security --> SecDir[Security Director]
    SecDir --> PhysicalSecMgr[Physical Security Manager]
    SecDir --> DigitalSecMgr[Digital Security Manager]
    SecDir --> BizSecMgr[Business Security Manager]
    
    %% Security Teams
    DigitalSecMgr --> AISecEngineer[AI Security Engineer]
    DigitalSecMgr --> RedTeamCoord[Security Red Team Coordinator]
    DigitalSecMgr --> JWTSpec[JWT Token Specialist]
    DigitalSecMgr --> HTTPSpec[HTTP Security Specialist]
    DigitalSecMgr --> CDNSpec[CDN Security Specialist]
    
    %% Finance Department
    SharedServices --> Finance[Finance]
    Finance --> FinDir[Finance Director]
    FinDir --> TaxMgr[Tax Manager]
    FinDir --> WealthMgr[Wealth Manager]
    FinDir --> CloudFinMgr[Cloud Finance Manager]
    FinDir --> CreditDebtMgr[Credit & Debt Manager]
    
    %% Finance Teams
    TaxMgr --> PersonalTaxDed[Personal Tax Deductions Finder]
    TaxMgr --> TaxAvoidPersonal[Tax Avoidance Specialist - Personal]
    TaxMgr --> TaxAvoidBusiness[Tax Avoidance Specialist - Business]
    TaxMgr --> CorpTaxSpec[Corporate Tax Specialist]
    TaxMgr --> RentalTaxSpec[Rental Income Tax Specialist]
    
    WealthMgr --> WealthBurndown[Wealth Burndown Specialist]
    WealthMgr --> SavingsBurndown[Savings Burndown Analyst]
    WealthMgr --> InvestmentAdvisor[Investment Advisor]
    
    CloudFinMgr --> GCPSpec[GCP Finance Specialist]
    CloudFinMgr --> AzureSpec[Azure Finance Specialist]
    CloudFinMgr --> AWSSpec[AWS Finance Specialist]
    CloudFinMgr --> DigitalOceanSpec[Digital Ocean Finance Specialist]
    CloudFinMgr --> CloudflareSpec[Cloudflare Finance Specialist]
    CloudFinMgr --> LinodeSpec[Linode Finance Specialist]
    CloudFinMgr --> HetznerSpec[Hetzner Finance Specialist]
    CloudFinMgr --> IONOSSpec[IONOS Finance Specialist]
    CloudFinMgr --> KamateraSpec[Kamatera Finance Specialist]
    CloudFinMgr --> VultrSpec[Vultr Finance Specialist]
    
    %% Legal Department
    SharedServices --> Legal[Legal]
    Legal --> GenCounsel[General Counsel]
    GenCounsel --> ContractsMgr[Contracts Manager]
    GenCounsel --> ComplianceMgr[Compliance Manager]
    GenCounsel --> IPMgr[IP Manager]
    GenCounsel --> CRMSpec[CRM Specialist]
    
    %% Data & Research Department
    SharedServices --> DataResearch[Data & Research]
    DataResearch --> NewsOpsDir[Director of News Operations]
    DataResearch --> KnowledgeOpsDir[Director of Knowledge Operations]
    
    %% News Operations
    NewsOpsDir --> IntelFin[Intelligence Analyst - Finance]
    NewsOpsDir --> IntelBiz[Intelligence Analyst - Business]
    NewsOpsDir --> IntelPol[Intelligence Analyst - Politics]
    NewsOpsDir --> IntelAI[Intelligence Analyst - AI]
    NewsOpsDir --> IntelTech[Intelligence Analyst - Technology]
    
    %% Knowledge Operations
    KnowledgeOpsDir --> OntologyExpert[Ontology Expert]
    
    %% Technology & Engineering Department
    SharedServices --> TechEng[Technology & Engineering]
    TechEng --> FrontendDir[Frontend Engineering Director]
    TechEng --> LangDir[Language Engineering Director]
    
    %% Frontend Teams
    FrontendDir --> WebMgr[Web Engineering Manager]
    FrontendDir --> MobileMgr[Mobile Engineering Manager]
    FrontendDir --> AppMgr[App Engineering Manager]
    FrontendDir --> CLIMgr[CLI Engineering Manager]
    
    WebMgr --> CSSSpec[CSS Specialist]
    WebMgr --> HTMLSpec[HTML Specialist]
    WebMgr --> TailwindSpec[Tailwind Specialist]
    WebMgr --> NextJSSpec[NextJS Specialist]
    
    MobileMgr --> iOSSpec[iOS Specialist]
    MobileMgr --> AndroidSpec[Android Specialist]
    MobileMgr --> FlutterSpec[Flutter Specialist]
    
    %% Language Specialists
    LangDir --> JavaSpec[Java Specialist]
    LangDir --> RustSpec[Rust Specialist]
    LangDir --> SwiftSpec[Swift Specialist]
    LangDir --> KotlinSpec[Kotlin Specialist]
    LangDir --> DartSpec[Dart Specialist]
    LangDir --> TypeScriptSpec[TypeScript Specialist]
    LangDir --> JSSpec[JavaScript Specialist]
    LangDir --> CppSpec[C++ Specialist]
    LangDir --> GoSpec[Go Specialist]
    LangDir --> PythonSpec[Python Specialist]
    
    %% Additional Tech Roles
    TechEng --> SQLSpec[SQL Specialist]
    TechEng --> HonoSpec[Hono Specialist]
    
    %% People & Workplace Department
    SharedServices --> PeopleWork[People & Workplace]
    PeopleWork --> PeopleDir[People & Workplace Director]
    PeopleDir --> RecruitingMgr[Recruiting Manager]
    PeopleDir --> CultureMgr[Culture Manager]
    PeopleDir --> WorkforceMgr[Workforce Design Manager]
    PeopleDir --> ProcurementMgr[Procurement Manager]
    PeopleDir --> VendorMgr[Vendor Manager]
    
    %% Strategy, Governance & Risk Department
    SharedServices --> StratGovRisk[Strategy, Governance & Risk]
    StratGovRisk --> StratDir[Strategy Director]
    StratDir --> OKRMgr2[OKR Manager]
    StratDir --> PolicyMgr[Policy Manager]
    StratDir --> RiskMgr[Risk Manager]
    StratDir --> GovernanceMgr[Governance Manager]
    
    %% Family & Personal Office
    ChiefOfStaff --> FamilyPersonal[Family & Personal Office<br/>Manager: Family Office Manager]
    FamilyPersonal --> PersonalTaxFin[Personal Tax & Finance]
    FamilyPersonal --> DocMgmt[Document & Deadline Management]
    FamilyPersonal --> PersonalIntel[Personal Intelligence & Insights]
    FamilyPersonal --> InsuranceRisk[Insurance & Risk]
    
    %% Personal Tax & Finance
    PersonalTaxFin --> PersonalFinMgr[Personal Finance Manager]
    PersonalFinMgr --> WithholdingAnalyst[Withholding Gap Analyst]
    PersonalFinMgr --> EstimatedTaxCoord[Estimated Tax Payments Coordinator]
    PersonalFinMgr --> DepreciationSpec[Depreciation Specialist]
    PersonalFinMgr --> LoyaltyTracker[Loyalty Programs Tracker]
    
    %% Document Management
    DocMgmt --> DocMgr[Document Manager]
    DocMgr --> DocRenewalSpec[Document Renewal Specialist]
    
    %% Personal Intelligence
    PersonalIntel --> PersonalInsightsMgr[Personal Insights Manager]
    PersonalInsightsMgr --> JournalThemeAnalyst[Journal Theme Analyst]
    PersonalInsightsMgr --> JournalActionExtractor[Journal Action Item Extractor]
    
    %% Insurance & Risk
    InsuranceRisk --> PersonalRiskMgr[Personal Risk Manager]
    PersonalRiskMgr --> InsuranceAlignSpec[Insurance Alignment Specialist]
    
    %% Business Office
    ChiefOfStaff --> BusinessOffice[Business Office<br/>Manager: Business Portfolio Manager]
    BusinessOffice --> StrategicGrowth[Strategic Growth]
    BusinessOffice --> EquityOwnership[Equity & Ownership]
    BusinessOffice --> PropertyMgmt[Property Management & Real Estate]
    BusinessOffice --> FleetMgmt[Vehicle/Fleet Services]
    BusinessOffice --> RoleCoord[Role Coordination]
    BusinessOffice --> BusinessDev[Business Development]
    
    %% Strategic Growth
    StrategicGrowth --> MASpec[Mergers & Acquisitions Specialist]
    StrategicGrowth --> CrossBizMgr[Cross-Business Collaboration Manager]
    StrategicGrowth --> DiligenceLead[Due Diligence Lead]
    
    %% Equity & Ownership
    EquityOwnership --> EquityGrowthStrat[Equity Growth Strategist]
    EquityOwnership --> EquityProtectSpec[Equity Protection Specialist]
    
    %% Property Management
    PropertyMgmt --> PropertyMgr[Property Manager]
    PropertyMgr --> PropertyScoutLiaison[Property Location Scout Liaison]
    PropertyMgr --> PropertySalesStrat[Property Sales Strategist]
    PropertyMgr --> PropertyLoanMax[Property Loan Maximizer]
    PropertyMgr --> RentalTaxSpec2[Rental Income Tax Specialist]
    
    %% Fleet Management
    FleetMgmt --> FleetMgr[Fleet Manager]
    FleetMgr --> RentalCarSpec[Rental Car Services Specialist]
    
    %% Role Coordination
    RoleCoord --> ActingRolesCoord[Acting Roles Coordinator]
    
    %% Business Development
    BusinessDev --> BizDevMgr[Business Development Manager]
    BizDevMgr --> GovFundingSpec[Gov Funding Specialist]
    BizDevMgr --> PartnershipMgr[Partnership Manager]
    
    %% Venture Studio
    ChiefOfStaff --> VentureStudio[Venture Studio<br/>Structure: Flat]
    VentureStudio --> StartupLifecycle[Startup Lifecycle Management]
    VentureStudio --> InvestmentFunding[Investment & Funding]
    VentureStudio --> MentorshipAdvisory[Mentorship & Advisory]
    
    %% Startup Lifecycle
    StartupLifecycle --> StartupIdeation[Startup Ideation Specialist]
    StartupLifecycle --> StartupValidation[Startup Validation Specialist]
    StartupLifecycle --> StartupSpinOut[Startup Spin-Out Manager]
    StartupLifecycle --> StartupScaling[Startup Scaling Specialist]
    StartupLifecycle --> BizExperimentDesigner[Business Experiment Designer]
    
    %% Investment & Funding
    InvestmentFunding --> InvestorRelationsMgr[Investor Relations Manager]
    InvestmentFunding --> InvestorDiscoverySpec[Investor Discovery Specialist]
    InvestmentFunding --> VCSpec[Venture Capital Specialist]
    
    %% Mentorship & Advisory
    MentorshipAdvisory --> MentorAdvisorCoord[Mentor & Advisor Coordinator]
    
    %% Philanthropy Office
    ChiefOfStaff --> Philanthropy[Philanthropy Office<br/>Manager: Director of Philanthropy]
    Philanthropy --> Grantmaking[Grantmaking & Impact]
    Grantmaking --> GrantMgr[Grant Manager]
    Grantmaking --> ImpactAnalyst[Impact Analyst]
    Grantmaking --> NonprofitPartnershipMgr[Nonprofit Partnership Manager]
    
    %% Financial Markets
    ChiefOfStaff --> FinancialMarkets[Financial Markets<br/>Location: Business Office or Family & Personal Office]
    FinancialMarkets --> InvestmentTeam[Investment Team]
    InvestmentTeam --> InvestmentMgr[Investment Manager]
    InvestmentMgr --> CryptoAnalyst[Crypto Markets Analyst]
    InvestmentMgr --> StockAnalyst[Stock Markets Analyst]
    InvestmentMgr --> DerivativesSpec[Derivatives Specialist]
    InvestmentMgr --> FXAnalyst[FX (Forex) Analyst]
    InvestmentMgr --> FixedIncomeAnalyst[Fixed Income Analyst]
    InvestmentMgr --> PreciousMetalsAnalyst[Precious Metals Analyst]
    InvestmentMgr --> CollectiblesAnalyst[Collectibles Analyst]
    InvestmentMgr --> SpeculativeRiskAnalyst[Speculative Risk Analyst]
    
    %% Styling
    classDef executive fill:#f9f,stroke:#333,stroke-width:2px
    classDef sharedservices fill:#bbf,stroke:#333,stroke-width:2px
    classDef family fill:#fbb,stroke:#333,stroke-width:2px
    classDef business fill:#bfb,stroke:#333,stroke-width:2px
    classDef venture fill:#ffb,stroke:#333,stroke-width:2px
    classDef philanthropy fill:#bff,stroke:#333,stroke-width:2px
    classDef financial fill:#fbf,stroke:#333,stroke-width:2px
    
    class Principal,ChiefOfStaff executive
    class SharedServices,ExecOps,BrandComms,Sales,Marketing,CustService,Security,Finance,Legal,DataResearch,TechEng,PeopleWork,StratGovRisk sharedservices
    class FamilyPersonal,PersonalTaxFin,DocMgmt,PersonalIntel,InsuranceRisk family
    class BusinessOffice,StrategicGrowth,EquityOwnership,PropertyMgmt,FleetMgmt,RoleCoord,BusinessDev business
    class VentureStudio,StartupLifecycle,InvestmentFunding,MentorshipAdvisory venture
    class Philanthropy,Grantmaking philanthropy
    class FinancialMarkets,InvestmentTeam financial
```

---

*This document is automatically generated from the single source of truth YAML structure.*
*Last updated: $(date +'%Y-%m-%d %H:%M:%S')*
EOF

    log "Full diagram generated: $OUTPUT_DIR/Office of the Principal.md"
}

# Generate high-level department view
generate_department_view() {
    log "Generating high-level department view..."
    
    cat > "$OUTPUT_DIR/Department Overview.md" << 'EOF'
# Department Overview - High-Level View

This document shows the high-level department structure without individual roles.

```mermaid
graph TD
    %% Executive Level
    Principal[Principal] --> ChiefOfStaff[Chief of Staff (CoS)]
    
    %% Major Divisions
    ChiefOfStaff --> SharedServices[Shared Services Office]
    ChiefOfStaff --> FamilyPersonal[Family & Personal Office]
    ChiefOfStaff --> BusinessOffice[Business Office]
    ChiefOfStaff --> VentureStudio[Venture Studio]
    ChiefOfStaff --> Philanthropy[Philanthropy Office]
    ChiefOfStaff --> FinancialMarkets[Financial Markets]
    
    %% Shared Services Departments
    SharedServices --> ExecOps[Executive Operations]
    SharedServices --> BrandComms[Brand & Communications]
    SharedServices --> Sales[Sales]
    SharedServices --> Marketing[Marketing]
    SharedServices --> CustService[Customer Service]
    SharedServices --> Security[Security]
    SharedServices --> Finance[Finance]
    SharedServices --> Legal[Legal]
    SharedServices --> DataResearch[Data & Research]
    SharedServices --> TechEng[Technology & Engineering]
    SharedServices --> PeopleWork[People & Workplace]
    SharedServices --> StratGovRisk[Strategy, Governance & Risk]
    
    %% Family & Personal Office Departments
    FamilyPersonal --> PersonalTaxFin[Personal Tax & Finance]
    FamilyPersonal --> DocMgmt[Document & Deadline Management]
    FamilyPersonal --> PersonalIntel[Personal Intelligence & Insights]
    FamilyPersonal --> InsuranceRisk[Insurance & Risk]
    
    %% Business Office Departments
    BusinessOffice --> StrategicGrowth[Strategic Growth]
    BusinessOffice --> EquityOwnership[Equity & Ownership]
    BusinessOffice --> PropertyMgmt[Property Management & Real Estate]
    BusinessOffice --> FleetMgmt[Vehicle/Fleet Services]
    BusinessOffice --> RoleCoord[Role Coordination]
    BusinessOffice --> BusinessDev[Business Development]
    
    %% Venture Studio Departments
    VentureStudio --> StartupLifecycle[Startup Lifecycle Management]
    VentureStudio --> InvestmentFunding[Investment & Funding]
    VentureStudio --> MentorshipAdvisory[Mentorship & Advisory]
    
    %% Philanthropy Office Departments
    Philanthropy --> Grantmaking[Grantmaking & Impact]
    
    %% Financial Markets Departments
    FinancialMarkets --> InvestmentTeam[Investment Team]
    
    %% Styling
    classDef executive fill:#f9f,stroke:#333,stroke-width:3px
    classDef sharedservices fill:#bbf,stroke:#333,stroke-width:2px
    classDef family fill:#fbb,stroke:#333,stroke-width:2px
    classDef business fill:#bfb,stroke:#333,stroke-width:2px
    classDef venture fill:#ffb,stroke:#333,stroke-width:2px
    classDef philanthropy fill:#bff,stroke:#333,stroke-width:2px
    classDef financial fill:#fbf,stroke:#333,stroke-width:2px
    
    class Principal,ChiefOfStaff executive
    class SharedServices,ExecOps,BrandComms,Sales,Marketing,CustService,Security,Finance,Legal,DataResearch,TechEng,PeopleWork,StratGovRisk sharedservices
    class FamilyPersonal,PersonalTaxFin,DocMgmt,PersonalIntel,InsuranceRisk family
    class BusinessOffice,StrategicGrowth,EquityOwnership,PropertyMgmt,FleetMgmt,RoleCoord,BusinessDev business
    class VentureStudio,StartupLifecycle,InvestmentFunding,MentorshipAdvisory venture
    class Philanthropy,Grantmaking philanthropy
    class FinancialMarkets,InvestmentTeam financial
```

---

*This document is automatically generated from the single source of truth YAML structure.*
*Last updated: $(date +'%Y-%m-%d %H:%M:%S')*
EOF

    log "Department overview generated: $OUTPUT_DIR/Department Overview.md"
}

# Generate department-specific view
generate_department_specific() {
    local dept_name="$1"
    log "Generating department-specific view for: $dept_name"
    
    # Create departments directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR/departments"
    
    case "$dept_name" in
        "sales")
            cat > "$OUTPUT_DIR/departments/Sales.md" << 'EOF'
# Sales Department

## Structure

```mermaid
graph TD
    SalesDir[Sales Director] --> SalesOpsMgr[Sales Operations Manager]
    SalesDir --> eCommerceMgr[eCommerce Sales Manager]
    
    %% Scaled Selling Team
    SalesOpsMgr --> LeadGenSpec[Lead Generation Specialist]
    SalesOpsMgr --> AcctExec[Account Executive]
    SalesOpsMgr --> AcctMgr[Account Manager]
    
    %% eCommerce Team
    eCommerceMgr --> AmazonSpec[Amazon Seller Specialist]
    eCommerceMgr --> TikTokMgr[TikTok Shop Manager]
    eCommerceMgr --> MarketplaceSpec[Marketplace Specialist]
    
    %% Styling
    classDef manager fill:#f9f,stroke:#333,stroke-width:2px
    classDef specialist fill:#bbf,stroke:#333,stroke-width:1px
    
    class SalesDir,SalesOpsMgr,eCommerceMgr manager
    class LeadGenSpec,AcctExec,AcctMgr,AmazonSpec,TikTokMgr,MarketplaceSpec specialist
```

## Roles & Responsibilities

### Sales Director
- Overall sales strategy, team leadership, and revenue growth
- Manages Sales Operations Manager and eCommerce Sales Manager

### Sales Operations Manager
- Sales process optimization, tools, and enablement
- Implements Scaled Selling principles
- Manages lead generation, account executives, and account managers

### Lead Generation Specialist
- Prospect identification and qualification
- Part of Scaled Selling - specialized role for consistent lead flow

### Account Executive
- Deal closing and new customer acquisition
- Specialized closing role in Scaled Selling model

### Account Manager
- Customer retention and expansion
- Post-sale specialization for customer success and growth

### eCommerce Sales Manager
- Marketplace strategy, inventory, and sales optimization
- Manages marketplace specialists

### Amazon Seller Specialist
- Amazon marketplace management

### TikTok Shop Manager
- TikTok commerce operations

### Marketplace Specialist
- Other platforms (eBay, Walmart, Etsy, etc.)
- Additional marketplace specialists as needed

---

*This document is automatically generated from the single source of truth YAML structure.*
*Last updated: $(date +'%Y-%m-%d %H:%M:%S')*
EOF
            ;;
        "marketing")
            cat > "$OUTPUT_DIR/departments/Marketing.md" << 'EOF'
# Marketing Department

## Structure

```mermaid
graph TD
    MktgDir[Marketing Director] --> MktgOpsMgr[Marketing Operations Manager]
    MktgDir --> DemandGenMgr[Demand Generation Manager]
    MktgDir --> ProdMktgSpec[Product Marketing Specialist]
    MktgDir --> CustExpMgr[Customer Experience Manager]
    MktgDir --> ReferralMgr[Referral Program Manager]
    
    %% Advertising Team
    MktgOpsMgr --> PaidMediaMgr[Paid Media Manager]
    PaidMediaMgr --> GoogleSpec[Google Ads Specialist]
    PaidMediaMgr --> MetaSpec[Meta Ads Specialist]
    PaidMediaMgr --> XSpec[X Ads Specialist]
    PaidMediaMgr --> AdPlatformSpec[Ad Platform Specialist]
    
    %% Demand GTM Team
    DemandGenMgr --> ContentSpec[Content Marketing Specialist]
    
    %% Cross-functional indicators
    CustExpMgr -.-> Sales
    ReferralMgr -.-> Sales
    
    %% Styling
    classDef director fill:#f9f,stroke:#333,stroke-width:3px
    classDef manager fill:#bbf,stroke:#333,stroke-width:2px
    classDef specialist fill:#bfb,stroke:#333,stroke-width:1px
    classDef crossfunc fill:#ffb,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5
    
    class MktgDir director
    class MktgOpsMgr,DemandGenMgr,PaidMediaMgr manager
    class ProdMktgSpec,CustExpMgr,ReferralMgr,GoogleSpec,MetaSpec,XSpec,AdPlatformSpec,ContentSpec specialist
    class CustExpMgr,ReferralMgr crossfunc
```

## Roles & Responsibilities

### Marketing Director
- Overall marketing strategy, brand management, and demand generation
- Manages all marketing teams

### Marketing Operations Manager
- Marketing operations, budget allocation, and team coordination
- Integrated from existing Marketing Operations Manager role
- Manages advertising team

### Paid Media Manager
- Cross-platform advertising strategy and budget allocation
- Manages platform specialists

### Google Ads Specialist
- Google advertising campaigns and optimization

### Meta Ads Specialist
- Facebook/Instagram advertising campaigns

### X Ads Specialist
- Twitter/X advertising campaigns

### Ad Platform Specialist
- Other advertising platforms (TikTok, LinkedIn, Amazon, etc.)
- Additional platform specialists can be added as needed

### Demand Generation Manager
- Lead generation campaigns and marketing automation
- Implements Demand GTM strategy - creates awareness and interest

### Content Marketing Specialist
- Content creation and distribution strategy
- Core part of Demand GTM - creates value through content

### Product Marketing Specialist
- Product positioning and launch strategy
- Connects product value to market needs

### Customer Experience Manager
- Customer journey optimization and satisfaction
- Implements Flywheel model - ensures customer delight drives growth
- Cross-functional with Sales

### Referral Program Manager
- Customer referral and advocacy programs
- Flywheel component - turns customers into growth engine
- Cross-functional with Sales

---

*This document is automatically generated from the single source of truth YAML structure.*
*Last updated: $(date +'%Y-%m-%d %H:%M:%S')*
EOF
            ;;
        *)
            warn "Department '$dept_name' not found in predefined templates"
            return 1
            ;;
    esac
    
    log "Department view generated: $OUTPUT_DIR/departments/${dept_name^}.md"
}

# Main execution
main() {
    local command="${1:-full}"
    
    log "Starting Agent Org diagram generation..."
    log "Command: $command"
    
    extract_yaml
    
    case "$command" in
        "full")
            generate_full_diagram
            ;;
        "departments")
            generate_department_view
            ;;
        *)
            if [[ -n "$command" ]]; then
                generate_department_specific "$command"
            else
                error "Unknown command: $command. Use: full, departments, or department-name"
            fi
            ;;
    esac
    
    log "Generation completed successfully!"
}

# Run main function with all arguments
main "$@"
