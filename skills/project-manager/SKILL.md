---
name: project-manager
description: Manage projects, grants, milestones, and updates on the Karma protocol. Use when user says "create a project", "new project", "add a grant", "record funding", "add milestone", "complete milestone", "post an update", "project progress", "grant update", "update project", "edit project", "edit grant", "complete grant", "add roadmap milestone", "report impact", "endorse project", "add team member", "set up agent", "configure API key", "check payouts", "payout status", "payout history", "total disbursed", "view invoices", "download invoice", or any project management action. Also supports dynamic endpoint discovery from the Swagger docs for any API operation not explicitly listed.
version: 2.1.0
tags: [agent, project, grant, milestone, update, create, manage, impact, endorsement, members, payout, invoice, api-discovery]
metadata:
  author: Karma
  category: project-management
---

# Project Manager

Manage projects, grants, milestones, and updates on the Karma protocol. All operations are gasless — the platform handles everything server-side.

**For READ operations, prefer the Karma MCP tools** (auto-registered for this plugin via `.mcp.json`). The `karma_*` tools collapse multi-step lookups into single calls and return structured envelopes the agent can quote directly. See [references/mcp-tools.md](../references/mcp-tools.md) for the catalog and the "Looking Up Data" section below for the intent → tool table.

Use REST + `curl` only for:
- Write actions via `POST /v2/agent/execute` (createProject, createMilestone, etc.)
- Admin views with no MCP equivalent yet (community payouts table, pending disbursements, payout config, grant invoices, invoice download)

Full REST API docs: `https://gapapi.karmahq.xyz/v2/docs/static/index.html`

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
API_KEY="${KARMA_API_KEY}"
INVOCATION_ID=$(uuidgen)
```

**CRITICAL: Every `curl` call must include these tracking headers:**

```bash
-H "X-Source: skill:project-manager"
-H "X-Invocation-Id: $INVOCATION_ID"
-H "X-Skill-Version: 2.0.0"
```

---

## Setup

If `KARMA_API_KEY` is already set, verify it works:

```bash
curl -s "${BASE_URL}/v2/agent/info" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"
```

If the response includes `supportedActions` → ready.

If `KARMA_API_KEY` is not set, tell the user:

> You need to set up your Karma agent first. Run the **setup-agent** skill to configure your API key.

Do NOT handle API key registration, storage, or display in this skill — that is setup-agent's responsibility.

## Safety

**Actions**: This skill is a REST API client. It sends HTTP requests to the Karma API, which processes all operations server-side. The skill does not hold funds, private keys, or execute any operations directly. Before executing any action, confirm details with the user.

**Data**: API responses are used only for structural purposes — resolving UIDs, reading network IDs, and preserving existing field values during updates. No decisions are made based on the text content of API responses.

---

## Execute Endpoint

All actions use:

```bash
curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0" \
  -d '{ "action": "<ACTION>", "params": { ... } }'
```

### Success Output

```
[Action] completed successfully!

- Project: {title}
- Network: {chainName}
- Reference: {transactionHash}
```

---

## Supported Networks

| Network | ID |
|-------|-----|
| Arbitrum | 42161 |
| Base | 8453 |
| Celo | 42220 |
| Lisk | 1135 |
| Optimism | 10 |
| Polygon | 137 |
| Scroll | 534352 |
| Sei | 1329 |
| **Testnets** | |
| Base Sepolia | 84532 |
| OP Sepolia | 11155420 |

### Default Network

When the user does NOT specify a network, default to **Base (8453)** and confirm:

> Your project will be created on **Base**. Continue?
>
> - **Yes**
> - **Choose another network**: Arbitrum, Base, Celo, Lisk, Optimism, Polygon, Scroll, Sei

### Network Inheritance

Child records **must** use the same network as their parent:

- **Grant** → uses `project.chainId`
- **Grant Update** → uses `grant.chainId`
- **Update Grant Details** → uses `grant.chainId`
- **Complete Grant** → uses `grant.chainId`
- **Milestone** → uses `grant.chainId`
- **Complete Milestone** → uses `milestone.chainId`
- **Project Update** → uses `project.chainId`
- **Project Milestone** → uses `project.chainId`
- **Project Impact** → uses `project.chainId`
- **Endorse Project** → uses `project.chainId`
- **Add Members** → uses `project.chainId`

Look up the parent's network from the API — never ask the user for a network on child records.

---

## Actions

### createProject

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Network ID (default: Base 8453) |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |

**Optional fields:**

| Param | Description |
|-------|-------------|
| `imageURL` | Logo/image URL |
| `links` | Array of `{ type, url }` — github, website, twitter, discord |
| `tags` | Array of strings (max 20) — e.g. "defi", "infrastructure" |
| `problem` | What problem does this project solve? (1-5000 chars) |
| `solution` | What is the solution? (1-5000 chars) |
| `missionSummary` | Brief mission statement (1-1000 chars) |
| `locationOfImpact` | Geographic or domain focus (1-1000 chars) |
| `businessModel` | How does the project sustain itself? (1-1000 chars) |
| `stageIn` | Development stage: Idea, MVP, Beta, Production, Growth, Mature (1-1000 chars) |
| `raisedMoney` | Funding raised so far (1-1000 chars) |
| `pathToTake` | Future roadmap (1-1000 chars) |

#### Gathering Project Information

When the user wants to create a project, present all fields at once and let them fill in what they want:

> To create your project, provide the following. Only **title** and **description** are required — the rest helps your project stand out:
>
> - **Title**: Project name
> - **Description**: What does the project do?
> - **Problem**: What problem are you solving?
> - **Solution**: How does your project solve it?
> - **Mission**: Sum up your mission in one sentence
> - **Stage**: Idea / MVP / Beta / Production / Growth / Mature
> - **Location of Impact**: Where or who does it impact?
> - **Business Model**: How do you sustain the project?
> - **Funding Raised**: What funding have you received?
> - **Roadmap**: What's your plan ahead?
> - **Links**: GitHub, website, Twitter, Discord URLs
> - **Tags**: Category tags (e.g. defi, infrastructure, public-goods)
> - **Image**: Logo or banner URL

Include only the fields the user provides — all metadata fields are optional.

#### After Project Creation

After a successful project creation, display:

> Your project has been created on {chainName}!
>
> - **Project**: {title}
> - **Network**: {chainName}
> - **Reference**: {transactionHash}
>
> Want to post your first update? Share something you just built, a milestone you hit, or what's coming next.

---

### updateProjectDetails

Update an existing project. **Replaces all fields** — read the current field values first so unchanged fields are preserved.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Network where the project lives |
| `projectUID` | Yes | Project attestation UID |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |

Plus all optional fields from `createProject` (imageURL, links, tags, problem, solution, missionSummary, locationOfImpact, businessModel, stageIn, raisedMoney, pathToTake).

**Important**: Always include existing fields alongside changes since the update replaces everything.

---

### createProjectUpdate

Post a progress update on a project.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `title` | Yes | Update title (1-200 chars) |
| `text` | Yes | Update content (1-10000 chars) |

---

### createGrant

Add a grant (funding) to a project.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `communityUID` | Yes | Community attestation UID |
| `title` | Yes | Grant title (1-200 chars) |
| `description` | No | Grant description (1-5000 chars) |
| `amount` | No | Funding amount as text (e.g. "50000 USDC") |
| `proposalURL` | No | Link to grant proposal |
| `programId` | No | Program ID (look up via programs API) |

---

### createGrantUpdate

Post a progress update on a grant.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match grant's network |
| `grantUID` | Yes | Grant attestation UID |
| `title` | Yes | Update title (1-200 chars) |
| `text` | Yes | Update content (1-10000 chars) |

---

### createMilestone

Add a milestone to a grant.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match grant's network |
| `grantUID` | Yes | Grant attestation UID |
| `title` | Yes | Milestone title (1-200 chars) |
| `description` | Yes | What will be delivered (1-5000 chars) |
| `endsAt` | Yes | Deadline as Unix timestamp in **seconds** |
| `priority` | No | Priority level (0-4) |

Date conversion: `Math.floor(new Date("2025-06-30").getTime() / 1000)`

---

### completeMilestone

Mark a milestone as completed.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match milestone's network |
| `milestoneUID` | Yes | Milestone attestation UID |
| `reason` | Yes | Completion summary (1-5000 chars) |
| `proofOfWork` | No | URL to proof (PR, demo, report) |

---

### createProjectWithGrant

Create a project and grant in a single transaction (4 attestations).

All `createProject` params plus:

| Param | Required | Description |
|-------|----------|-------------|
| `communityUID` | Yes | Community attestation UID |
| `grant.title` | Yes | Grant title (1-200 chars) |
| `grant.description` | No | Grant description |
| `grant.amount` | No | Funding amount |
| `grant.proposalURL` | No | Proposal link |
| `grant.programId` | No | Program ID |

After success, use the same post-creation message as `createProject`.

---

### updateGrantDetails

Update an existing grant's details. Attests new details — the indexer uses the latest one.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match grant's network |
| `grantUID` | Yes | Grant attestation UID |
| `title` | Yes | Grant title (1-200 chars) |
| `description` | No | Grant description (1-5000 chars) |
| `amount` | No | Funding amount as text (e.g. "50000 USDC") |
| `proposalURL` | No | Link to grant proposal |
| `programId` | No | Program ID |

**Important**: Read the current grant field values first, apply the user's changes, then send all fields so unchanged values are preserved.

---

### completeGrant

Mark a grant as fully completed with a final summary.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match grant's network |
| `grantUID` | Yes | Grant attestation UID |
| `title` | Yes | Completion title (1-200 chars) |
| `text` | Yes | Completion summary (1-10000 chars) |
| `proofOfWork` | No | URL to proof (demo, report, repo) |
| `pitchDeck` | No | URL to pitch deck |
| `demoVideo` | No | URL to demo video |
| `trackExplanations` | No | Array of `{ trackId, trackName, explanation }` — how the grant fulfilled each track |

After completion:

> Grant **{title}** has been marked as completed!
>
> - **Grant**: {title}
> - **Network**: {chainName}
> - **Reference**: {transactionHash}

---

### createProjectMilestone

Create a project-level roadmap milestone (not tied to a specific grant).

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `title` | Yes | Milestone title (1-200 chars) |
| `text` | Yes | Milestone description (1-5000 chars) |

---

### createProjectImpact

Report impact achieved by a project.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `work` | Yes | Description of work done (1-5000 chars) |
| `impact` | Yes | Description of impact achieved (1-5000 chars) |
| `proof` | Yes | Proof of impact — URL or description (1-5000 chars) |
| `startedAt` | No | When work started (Unix timestamp in seconds) |
| `completedAt` | Yes | When work was completed (Unix timestamp in seconds) |

---

### endorseProject

Endorse a project with an optional comment.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `comment` | No | Endorsement comment (1-5000 chars) |

---

### addProjectMembers

Add team members to a project.

| Param | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Must match project's network |
| `projectUID` | Yes | Project attestation UID |
| `members` | Yes | Array of members (1-20) |

Each member object:

| Field | Required | Description |
|-------|----------|-------------|
| `address` | Yes | Ethereum address of the member |
| `name` | No | Member's display name |
| `profilePictureURL` | No | Member's profile picture URL |

---

## Looking Up Data — prefer MCP tools

The Karma MCP server is auto-registered for this plugin (see `.mcp.json` and [references/mcp-tools.md](../references/mcp-tools.md)). For READ operations, **call the `karma_*` MCP tool by name** — do not shell out to `curl`. The MCP envelope already carries a one-sentence `summary` plus structured `data`, `identifiers`, and `nextActions`, so you can answer the user without re-parsing JSON yourself.

### Picking the right tool by intent

| User asks | Call this MCP tool | Required args |
|---|---|---|
| "Find project / community / program X" | `karma_search_discover` | `query` |
| "What is the status of X?" / "How is X doing?" | `karma_project_get_status` | `projectIdOrSlug` |
| "Show me the project record for X" | `karma_project_get_details` | `projectIdOrSlug` |
| "What grants does X have?" / "List X's grants" | `karma_project_get_details` (grants live in the response) | `projectIdOrSlug` |
| "How many milestones has X completed?" | `karma_project_get_status` (overall) **or** `karma_project_list_milestones` (per-milestone) | `projectIdOrSlug` |
| "How many milestones has X completed in &lt;program&gt;?" | `karma_project_get_progress_in_program` | `projectIdOrSlug`, `programId` |
| "How much has been disbursed to project X?" | `karma_project_get_disbursement_total` | `projectIdOrSlug` |
| "Per-payout history for grant Y" | *(no MCP tool — use REST `/v2/payouts/grant/:uid/history`)* | — |
| "Who got funded in &lt;program&gt; and how much?" | `karma_program_get_funding_summary` | `programId` |
| "Programs in &lt;community&gt;" / "Community overview" | `karma_community_get_overview` | `communityIdOrSlug` |
| "Program details / report for &lt;program&gt;" | `karma_program_get_details` or `karma_program_generate_report` | `programId` |
| "What are MY projects / applications?" | `karma_user_get_workspace` | *(none — uses your API key's address)* |

Each MCP response is a typed envelope:

```json
{
  "summary": "Project \"drand\" has received 0 disbursements ...",
  "data":   { ... },
  "identifiers": { "projectSlug": "drand", "grantUIDs": [...], "programIds": [...] },
  "nextActions": [ "...", "..." ]
}
```

Quote `summary` to the user. Pull stable IDs from `identifiers` for follow-up tool calls. Read `nextActions` to decide what to chain next.

### When the answer needs a community-wide payout view

For multi-grant per-community admin views (the "show me ALL payouts/invoices/agreement statuses across the community" case), there is no MCP equivalent — the per-payout admin panel still goes through REST:

```bash
curl -s "${BASE_URL}/v2/communities/${COMMUNITY_UID}/payouts?page=1&limit=25" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"
```

**Display rules for the community-payouts table (MANDATORY):**
- Each item in `payload[]` is a different project+grant combination
- First column **must** be **Project** (`item.project.title`)
- Second column **must** be **Grant** (`item.grant.title`)
- Never group/flatten by grant name — always one row per milestone per project+grant pair (a search like "curio" can return both "Curio Storage" and "Curio Dashboard" and the user needs to tell them apart)

Optional query params:

| Param | Description |
|-------|-------------|
| `page` | Page number (default: 1) |
| `limit` | Items per page (default: 10, max: 1000) |
| `programId` | Filter by program ID |
| `status` | Filter by payout status |
| `agreementStatus` | `signed` or `not_signed` |
| `invoiceStatus` | `all_received`, `needs_invoices`, or `has_invoices` |
| `search` | Search by project or grant name (max 200 chars) |
| `sortBy` | `project_title`, `grant_title`, `payout_amount`, `disbursed_amount`, or `status` |
| `sortOrder` | `asc` or `desc` (default: `asc`) |

If you get 403 (no COMMUNITY_VIEW permission), fall back to the public endpoint (no auth, fewer fields):

```bash
curl -s "${BASE_URL}/v2/communities/${COMMUNITY_UID}/payouts/public?page=1&limit=25" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"
```

For "what was disbursed to *one project*?" prefer `karma_project_get_disbursement_total` — it composes the project-grant-payout join in a single MCP call with a per-(program, token) breakdown.

### Other admin endpoints (no MCP equivalent yet)

```bash
# Pending disbursements awaiting processing for a community
curl -s "${BASE_URL}/v2/payouts/community/${COMMUNITY_UID}/pending?page=1&limit=20" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"

# Payout config for a grant (payment address, token, schedule)
curl -s "${BASE_URL}/v2/payout-config/grant/${GRANT_UID}" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"

# Grant invoices: id, milestoneUID, milestoneLabel, invoiceStatus, invoiceReceivedAt, invoiceFileKey
curl -s "${BASE_URL}/v2/milestone-invoices/grant/${GRANT_UID}" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"

# Invoice download URL (15-min TTL) — pass the invoiceFileKey from the previous call
curl -s "${BASE_URL}/v2/milestone-invoices/download?key=${INVOICE_FILE_KEY}" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"
```

---

## Dynamic Endpoint Discovery (Fallback)

When the user requests an action not covered by the endpoints above, discover the right endpoint from the live API schema. This requires only `curl` — no other tools.

### Step 1: Fetch the API schema

```bash
curl -s "${BASE_URL}/v2/docs/json" \
  -H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"
```

Read through the `paths` object in the response to find endpoints matching the user's request. Each path contains its HTTP method, parameters, request body schema, and response schema.

### Step 2: Call the discovered endpoint

Use the schema to construct the correct `curl` call. Always include:
- Auth: `-H "x-api-key: ${API_KEY}"`
- Tracking headers: `-H "X-Source: skill:project-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 2.0.0"`

If the endpoint returns 403, check the schema for a `/public` variant of the same path and try that instead.

---

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "create a project", "new project" | `createProject` — present all fields, default Base |
| "create a DeFi project on Optimism" | `createProject` with tags: ["defi"], chainId: 10 |
| "update project details", "rename project", "enrich my project" | `updateProjectDetails` — read current values, apply changes |
| "post an update", "project progress" | `createProjectUpdate` — look up projectUID, inherit chain |
| "add a grant", "record funding" | `createGrant` — look up projectUID + communityUID, inherit chain |
| "grant update", "grant progress" | `createGrantUpdate` — look up grantUID, inherit chain |
| "edit grant", "update grant details", "change grant amount" | `updateGrantDetails` — read current values, apply changes |
| "complete grant", "finish grant", "close grant" | `completeGrant` — look up grantUID, inherit chain |
| "add milestone", "set deliverable" | `createMilestone` — look up grantUID, inherit chain |
| "complete milestone", "mark done" | `completeMilestone` — look up milestoneUID, inherit chain |
| "add roadmap milestone", "project milestone" | `createProjectMilestone` — look up projectUID, inherit chain |
| "report impact", "log impact", "share impact" | `createProjectImpact` — look up projectUID, inherit chain |
| "endorse project", "support project" | `endorseProject` — look up projectUID, inherit chain |
| "add team member", "add member", "invite to project" | `addProjectMembers` — look up projectUID, inherit chain |
| "create project with grant" | `createProjectWithGrant` |
| "check payouts" / "payout status" / "show payouts" / "invoices" — admin view spanning many projects | Community Payouts REST endpoint (`/v2/communities/:id/payouts`) with `search` — there is no MCP equivalent for the admin table |
| "how much disbursed to project X" / "total paid out to X" | `karma_project_get_disbursement_total` (single MCP call, per-(program, token) breakdown) |
| "who got funded in &lt;program&gt;" | `karma_program_get_funding_summary` (single MCP call, per-currency totals + project names) |
| "milestones project X has completed in &lt;program&gt;" | `karma_project_get_progress_in_program` |
| "payout history for grant Y" | REST `/v2/payouts/grant/:uid/history` (no MCP equivalent yet) |
| "pending payouts", "pending disbursements" — community admin view | Pending Disbursements REST endpoint — look up communityUID first |
| "payout config", "payment setup" | Payout Config REST endpoint — look up grantUID first |
| "view invoices", "check invoices", "invoice status" | Grant Invoices REST endpoint — look up grantUID first |
| "download invoice" | Invoice Download — get `invoiceFileKey` from Grant Invoices first |
| Any other action not listed above | Use **Dynamic Endpoint Discovery** as fallback |

---

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Bad params | Show error, help fix |
| 403 | Forbidden | Check if a `/public` variant of the endpoint exists. If not, tell user they need higher API key permissions |
| 401 | Invalid API key | Tell user to run the **setup-agent** skill to reconfigure their API key |
| 429 | Rate limited (60/min) | Wait and retry |
| 500 | Server error | Retry once, then report |

## Edge Cases

| Scenario | Response |
|----------|----------|
| Missing required field | Ask user for it |
| Network not specified (root action) | Default to Base, confirm with user |
| Network not specified (child action) | Inherit from parent — never ask |
| API key not set | Run setup flow |
| Title too long (>200) | Truncate and confirm |
| Need UID but user gave name | Search API to find the UID |
| Partial project update | Read current field values, apply user's changes, then update |
| Multiple grants on project | Show list, ask which one |
| Date given as string | Convert to Unix timestamp in seconds |
| Action not in hardcoded list | Use Dynamic Endpoint Discovery — fetch API schema, find matching endpoint, call it |
