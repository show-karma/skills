# Karma Domain Context

## Platform Overview

[Karma](https://karmahq.xyz) builds accountability infrastructure for onchain communities. The platform helps ecosystems track grants, measure impact, and improve funding efficiency.

## Key Repositories

| Repo | Description | Stack |
|------|-------------|-------|
| `backend-nestjs` | Main API backend | NestJS, TypeScript, PostgreSQL |
| `frontend-nextjs` | Web application | Next.js, TypeScript, React |
| `gap-contracts` | GAP protocol smart contracts | Solidity, Hardhat |
| `warehouse` | Data indexing and aggregation | TypeScript |

## Domain Concepts

### GAP (Grants, Applications & Proposals)

The core protocol for onchain grants lifecycle management:

- **Grant Programs** — Funding programs created by ecosystems (e.g., Optimism, Arbitrum)
- **Applications** — Grantee submissions to grant programs
- **Milestones** — Deliverables within a grant, tracked onchain
- **Milestone Completion** — Grantee-submitted proof of completion
- **Milestone Review** — Program admin approval/rejection of milestones
- **Impact Reporting** — Periodic reports on grant outcomes

### Funding Maps

Cross-ecosystem visualization of funding flows:

- **Funding Sources** — Treasuries, foundations, DAOs providing capital
- **Funding Recipients** — Teams, projects, individuals receiving grants
- **Flow Analysis** — How funds move through ecosystems over time
- **Category Breakdown** — Funding by vertical (DeFi, infrastructure, public goods, etc.)

### Ecosystem Growth

Metrics and tooling for community health:

- **Grantee Activity** — Builder engagement, delivery rates, retention
- **Program Effectiveness** — Completion rates, time-to-delivery, ROI signals
- **Ecosystem Comparisons** — Cross-ecosystem benchmarking
- **Growth Signals** — Leading indicators of ecosystem development

## Tech Stack

- **Frontend**: Next.js 14+, TypeScript, Tailwind CSS, wagmi/viem
- **Backend**: NestJS, TypeScript, PostgreSQL, Redis
- **Contracts**: Solidity, EAS (Ethereum Attestation Service)
- **Data**: The Graph, custom indexers, warehouse aggregation
- **Chains**: Multi-chain (Optimism, Arbitrum, Base, Ethereum, etc.)

## Suggested Skill Categories

Skills for the Karma ecosystem should focus on these areas:

### Grants Management
- Grant program analysis and reporting
- Milestone tracking and verification
- Application review workflows
- Grantee onboarding and compliance

### Funding Maps
- Funding flow visualization
- Treasury analysis
- Cross-ecosystem funding comparisons
- Category and vertical breakdowns

### Ecosystem Growth
- Builder activity dashboards
- Program effectiveness metrics
- Growth signal detection
- Ecosystem health reporting

### Data & Integration
- GAP protocol data queries
- Warehouse data extraction
- Cross-chain data aggregation
- API integration helpers
