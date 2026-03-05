# Karma Skills

Agent skills for the Karma ecosystem — find funding opportunities, create and manage projects, post milestones and updates, administer grants.

## Quick Start

```bash
npx skills add show-karma/skills
```

Then ask your agent:

> Create a project called "My DeFi App" on Optimism

> Find active grant programs on Ethereum

> Post an update on my project — we shipped the MVP

## What Are Skills?

Skills are reusable instruction sets that encode domain expertise into repeatable workflows. Each skill teaches an AI agent how to perform a specific task within the Karma ecosystem. Skills work with any compatible agent client, including Claude Code, Cursor, Windsurf, and others.

The `SKILL.md` file contains YAML frontmatter (name, description, version, tags) followed by the instructions agents will follow.

## Available Skills

### find-opportunities

| Skill | Description |
|-------|-------------|
| [`find-opportunities`](skills/find-opportunities/) | Search the Karma Funding Map for grants, hackathons, bounties, accelerators, VC funds, and RFPs |

### project-manager

These skills use the Karma Agent API to create on-chain attestations via a server-side wallet. No gas fees, no browser wallet needed.

| Skill | Description |
|-------|-------------|
| [`setup-agent`](skills/setup-agent/) | Register and get your API key — quick start (no account), email login, or manual |
| [`create-project`](skills/create-project/) | Create a new project on-chain |
| [`update-project`](skills/update-project/) | Update a project's title, description, tags, or links |
| [`create-project-update`](skills/create-project-update/) | Post a progress update on a project |
| [`create-grant`](skills/create-grant/) | Attach a grant to a project |
| [`create-grant-update`](skills/create-grant-update/) | Post a progress update on a grant |
| [`create-milestone`](skills/create-milestone/) | Add a milestone to a grant |
| [`complete-milestone`](skills/complete-milestone/) | Mark a milestone as completed with proof of work |
| [`create-project-with-grant`](skills/create-project-with-grant/) | Create a project and grant in a single transaction |

## How It Works

```
You
  ↓
AI Agent (picks the right skill)
  ↓
Karma API (encodes attestation)
  ↓
Server Wallet (signs + submits tx, gasless)
  ↓
Blockchain (EAS attestation created)
  ↓
karmahq.xyz (visible on the web)
```

- **No gas fees** — transactions are sponsored via account abstraction
- **No browser wallet** — your agent gets a server-side wallet
- **On-chain** — every action creates a verifiable [EAS attestation](https://docs.attest.sh/)
- **Client-agnostic** — works with any AI agent that supports the Skills Standard

## Skill Format

Each skill is a directory under `skills/` containing:

```
skills/my-skill/
├── SKILL.md          # Skill definition (required)
├── references/       # Reference documents (optional)
└── assets/           # Templates, scripts (optional)
```

## Karma Ecosystem

[Karma](https://www.karmahq.xyz) helps projects build reputation and find funding opportunities. Karma's grants platform can be used by organizations to run their grant program (application intake, funds disbursal, milestone and metrics tracking). Key areas:

- **Project Profile** — Share progress updates, show traction and get funding
- **Funding Map** — Discover funding opportunities for your project
- **Grants Management** — Grant operators can administer grants efficiently

## License

MIT — see [LICENSE](LICENSE).
