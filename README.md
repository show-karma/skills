# Karma Skills

Shared agent skills for the Karma ecosystem.

These skills describe Karma workflows and reach data through Karma's MCP server. Inside Karma's in-product chat the MCP tools are provided automatically. For an external agent (Claude Code, Cursor, and similar), installing this plugin also registers the Karma MCP server (bundled `.mcp.json`) — you sign in through your browser, no API key to copy. See the **Connecting to Karma** section below. The domain skills themselves stay transport-neutral: they describe the workflow and let the API tools resolve the concrete endpoints.

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

## Connecting to Karma

Inside Karma's in-product chat, the MCP tools are already available — no setup needed.

For an external agent, this plugin bundles the Karma MCP server (`.mcp.json` at the plugin root), so installing the plugin registers it automatically. Authentication is browser-based sign-in — no API key to copy:

1. Install the plugin.
2. Connect the server (in Claude Code, run `/mcp` and pick **karma**). The agent gives you a Karma sign-in URL.
3. Open the URL, log in to Karma, and approve access. That's it — the agent now acts as you.

Details:

- Endpoint: `https://gapapi.karmahq.xyz/mcp` (production). For staging, point at `https://gapstagapi.karmahq.xyz/mcp`.
- Auth: OAuth 2.1 (authorization-code + PKCE). The token is scoped to your Karma identity and managed by your MCP client.
- The surface is read-only (GET): it can find and read records, not post comments, submit reviews, generate reports, or move payouts — those happen in the Karma product UI.

For non-interactive use (CI, headless `-p`), browser sign-in isn't possible — use an API key instead via an `x-api-key` header (get a key at https://www.karmahq.xyz/mcp/connect):

```bash
claude mcp add --transport http karma https://gapapi.karmahq.xyz/mcp \
  --header "x-api-key: $KARMA_API_KEY"
```

## What Are Skills?

Skills are reusable instruction sets that encode domain expertise into repeatable workflows. Each skill teaches an AI agent how to perform a specific task within the Karma ecosystem.

The `SKILL.md` file contains YAML frontmatter (name, description, version, tags) followed by the instructions agents will follow.

## Available Skills

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
