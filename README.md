# Karma Skills

Claude Code skills for the Karma ecosystem — grants management, funding maps, and ecosystem growth tooling.

## Installation

```bash
npx skills add show-karma/skills
```

This installs all published skills from this repository into your Claude Code environment.

## What Are Skills?

Skills are reusable instruction sets for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that encode domain expertise into repeatable workflows. Each skill teaches Claude how to perform a specific task within the Karma ecosystem.

## Focus Areas

- **Grants Management** — Tooling for the Grants, Applications & Proposals (GAP) protocol: milestone tracking, grant lifecycle, reporting
- **Funding Maps** — Visualization and analysis of funding flows across ecosystems
- **Ecosystem Growth** — Tools for measuring, tracking, and accelerating ecosystem development

## Skill Format

Each skill is a directory under `skills/` containing:

```
skills/my-skill/
├── SKILL.md          # Skill definition (required)
├── scripts/          # Helper scripts (optional)
└── references/       # Reference documents (optional)
```

The `SKILL.md` file contains YAML frontmatter (name, description, version, tags) followed by the instructions Claude will follow.

## Available Skills

No published skills yet. Check back soon or [contribute one](CONTRIBUTING.md)!

## Creating Skills

This repo includes a meta-skill for creating new Karma skills:

```bash
# The skill-creator lives in .claude/skills/skill-creator/
# It guides you through designing, writing, and validating new skills
```

See the [Contributing Guide](CONTRIBUTING.md) for skill structure requirements and naming conventions.

## Karma Ecosystem

[Karma](https://karmahq.xyz) builds accountability infrastructure for onchain communities. Key areas:

- **GAP (Grants, Applications & Proposals)** — Onchain grants lifecycle management
- **Funding Maps** — Cross-ecosystem funding flow visualization
- **Ecosystem Growth** — Metrics and tooling for community health

## License

MIT — see [LICENSE](LICENSE).
