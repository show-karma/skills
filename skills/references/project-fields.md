# Project Fields Reference

## Core Fields (Required)

| Field | Max | Description |
|-------|-----|-------------|
| `chainId` | — | Blockchain ID (see agent-api.md for supported chains) |
| `title` | 200 | Project name |
| `description` | 5000 | Project description |

## Optional Fields

| Field | Max | Description |
|-------|-----|-------------|
| `imageURL` | URL | Project logo or image |
| `links` | — | Array of `{ type, url }` — e.g. github, website, twitter, discord |
| `tags` | 20 items, 50 chars each | Category tags like "defi", "infrastructure", "public-goods" |

## Metadata Fields (Optional)

These fields make a project richer and more discoverable. They are all optional but highly recommended.

| Field | Max | Description | Example |
|-------|-----|-------------|---------|
| `problem` | 5000 | What problem does this project solve? | "DeFi users lack visibility into protocol risk across chains" |
| `solution` | 5000 | What is the solution? | "A unified dashboard that aggregates risk metrics from 20+ protocols" |
| `missionSummary` | 1000 | Brief mission statement | "Making DeFi risk transparent and accessible to everyone" |
| `locationOfImpact` | 1000 | Geographic or domain focus | "Global", "Southeast Asia", "Ethereum L2 ecosystem" |
| `businessModel` | 1000 | How does the project sustain itself? | "Protocol fees on premium analytics", "Grants + donations", "SaaS subscription" |
| `stageIn` | 1000 | Current development stage | "Idea", "MVP", "Beta", "Production", "Growth", "Mature" |
| `raisedMoney` | 1000 | Funding raised so far | "$500K seed round", "50K OP grant", "Bootstrapped" |
| `pathToTake` | 1000 | Future roadmap | "Launch mainnet Q2, expand to 3 chains by EOY, target 10K users" |

## Field Groups (for Guided Flow)

When guiding users through project enrichment, group fields into these sections:

### 1. Mission & Problem
- `problem` — What problem are you solving?
- `solution` — How does your project solve it?
- `missionSummary` — Sum up your mission in one sentence

### 2. Impact & Stage
- `locationOfImpact` — Where or who does your project impact?
- `stageIn` — What stage is the project in?

### 3. Links & Media
- `links` — GitHub, website, Twitter, Discord, etc.
- `imageURL` — Project logo or banner
- `tags` — Category tags for discoverability

### 4. Business & Funding
- `businessModel` — How do you sustain the project?
- `raisedMoney` — What funding have you received?
- `pathToTake` — What's your roadmap?

