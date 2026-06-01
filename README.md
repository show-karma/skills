# Karma Skills

Shared agent skills for the Karma ecosystem.

These skills describe Karma workflows and operation names. They do not include API-key setup, curl examples, or raw endpoint instructions. The runtime is responsible for exposing the operations listed in each skill, whether through Karma's in-product MCP server or an external adapter.

## Quick Start

```bash
npx skills add show-karma/skills
```

Then ask your agent questions such as:

> How do I submit a milestone update for this program?

> What applications do I need to review?

> Which projects have milestones ready for my review?

> What is happening across the programs I manage?

> What is the status of my project milestones?

## What Are Skills?

Skills are reusable instruction sets that encode domain expertise into repeatable workflows. Each skill teaches an AI agent how to perform a specific task within the Karma ecosystem.

The `SKILL.md` file contains YAML frontmatter (name, description, version, tags) followed by the instructions agents will follow.

## Available Skills

| Skill | Description |
|-------|-------------|
| Skill | Description |
|-------|-------------|
| [`knowledge-base-answering`](skills/knowledge-base-answering/) | Answer community and program process questions from indexed knowledge-base content. |
| [`karma-product-concepts`](skills/karma-product-concepts/) | Explain Karma roles, entities, and routing between entity data and knowledge-base content. |
| [`application-review`](skills/application-review/) | Help application reviewers find assigned applications and review state. |
| [`milestone-review`](skills/milestone-review/) | Help milestone reviewers find projects and milestones ready for review. |
| [`program-admin-workspace`](skills/program-admin-workspace/) | Help admins inspect programs, applications, reviewers, milestones, payouts, and reports. |
| [`project-owner-workspace`](skills/project-owner-workspace/) | Help project owners inspect projects, grants, milestones, completions, updates, indicators, invoices, and payouts. |
| [`philanthropy-research`](skills/philanthropy-research/) | Research grantmakers, nonprofits, grant transactions, totals, filings, and prospect-fit evidence. |

## How It Works

```
User request
  ↓
AI agent selects a Karma skill
  ↓
Skill names the workflow and expected operations
  ↓
Runtime adapter exposes operations through MCP or another interface
  ↓
Karma services enforce auth, RBAC, budgets, and tool policy
```

- **Skills are transport-neutral** — no raw endpoint or API-key setup instructions.
- **Runtime enforcement stays in code** — skills guide behavior but do not grant permissions.
- **Client-agnostic** — compatible agents can install the same skill files.

## Skill Format

Each skill is a directory under `skills/` containing:

```
skills/my-skill/
├── SKILL.md          # Skill definition (required)
├── references/       # Reference documents (optional)
└── assets/           # Templates, scripts (optional)
```

Karma-specific frontmatter may include `operations`, a list of runtime operation names the skill expects.

## Karma Ecosystem

[Karma](https://www.karmahq.xyz) helps projects build reputation and find funding opportunities. Karma's grants platform can be used by organizations to run their grant program (application intake, funds disbursal, milestone and metrics tracking). Key areas:

- **Project Profile** — Share progress updates, show traction and get funding
- **Funding Map** — Discover funding opportunities for your project
- **Grants Management** — Grant operators can administer grants efficiently

## License

MIT — see [LICENSE](LICENSE).
