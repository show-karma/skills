# Karma Skills

Agent skills for the Karma ecosystem — find funding opportunities, create and manage projects, post milestones and updates, administer grants.

## Quick Start

```bash
npx skills add show-karma/skills
```

Then ask your agent:

> Find active grant programs

> What hackathons are open right now?

## What Are Skills?

Skills are reusable instruction sets that encode domain expertise into repeatable workflows. Each skill teaches an AI agent how to perform a specific task within the Karma ecosystem. Skills work with any compatible agent client, including Claude Code, Codex, Openclaw, and others.

The `SKILL.md` file contains YAML frontmatter (name, description, version, tags) followed by the instructions Agnets will follow.

## Available Skills

| Skill | Description |
|-------|-------------|
| [`find-opportunities`](skills/find-opportunities/) | Search the Karma Funding Map for grants, hackathons, bounties, accelerators, VC funds, and RFPs |

## Focus Areas

- **Funding Map** — Explore all funding opportunities

## Skill Format

Each skill is a directory under `skills/` containing:

```
skills/my-skill/
├── SKILL.md          # Skill definition (required)
├── scripts/          # Helper scripts (optional)
└── references/       # Reference documents (optional)
```

## Karma Ecosystem

[Karma](https://www.karmahq.xyz) helps projects build reputation and find funding opportunities. Karma's grants platform can be used by organizations to run their grant program (application intake, funds disbursal, milestone and metrics tracking). Key areas:

- **Project Profile** — Share progress updates, show traction and get funding
- **Funding Map** — Discover funding opportunities for your project
- **Grants management software** — Grant operators can administer grants efficiently

## License

MIT — see [LICENSE](LICENSE).
