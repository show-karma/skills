---
name: create-project-with-grant
description: Create a new project with a grant in a single transaction on the Karma protocol. Use when user says "create project with grant", "new project with funding", "set up project and grant together", or "register funded project".
version: 0.2.0
tags: [agent, project, grant, create, batch]
metadata:
  author: Karma
  category: project-management
---

# Create Project with Grant

Create a new project and attach a grant in a single on-chain transaction. This creates 4 attestations: Project + ProjectDetails + Grant + GrantDetails.

Use this instead of separate `create-project` + `create-grant` when the user wants to set up a project with its funding in one step.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.
See [Project Fields Reference](../references/project-fields.md) for all available project fields with descriptions and examples.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

**Project fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Which blockchain |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |
| `communityUID` | Yes | The community UID that funded the project |

Optional: `imageURL`, `links`, `tags`, plus 8 metadata fields — see [Project Fields Reference](../references/project-fields.md).

**Grant fields (nested under `grant`):**

| Field | Required | Description |
|-------|----------|-------------|
| `grant.title` | Yes | Grant title (1-200 chars) |
| `grant.description` | No | Grant description (max 5000 chars) |
| `grant.amount` | No | Funding amount as string |
| `grant.proposalURL` | No | Link to proposal |
| `grant.programId` | No | Program identifier (see below) |

## Finding the programId

If the user provides a program/track name but not a `programId`, look it up after finding the community UID:

```bash
# Accepts community slug (e.g., "optimism") or UID (0x...)
curl -s "${BASE_URL}/communities/${COMMUNITY_SLUG_OR_UID}/programs" | python3 -c "
import sys, json
data = json.load(sys.stdin)
programs = data if isinstance(data, list) else data.get('payload', data.get('data', []))
for p in programs:
    print(f'Name: {p.get(\"metadata\", {}).get(\"title\", \"N/A\")} | ID: {p[\"programId\"]}')
"
```

## Finding the Community UID

```bash
curl -s "${BASE_URL}/v2/communities/?limit=10&page=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for c in data if isinstance(data, list) else data.get('payload', data.get('data', [])):
    d = c.get('details', {})
    name = d.get('name', 'N/A') if isinstance(d, dict) else 'N/A'
    print(f'Name: {name} | Chain: {c.get(\"chainID\", \"?\")} | UID: {c[\"uid\"]}')
"
```

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "create a project with a grant from the Offchain Super Chain program" | Look up community UID + programId, ask for details |
| "create a project with a grant from Optimism" | Look up community UID, ask if it's a specific program |
| "new project X funded by Y for $50K" | title: X, community: Y, amount: "50000" |
| "create project and grant together" | Ask for all details |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createProjectWithGrant",
    "params": {
      "chainId": 10,
      "title": "DeFi Protocol",
      "description": "A decentralized lending protocol",
      "links": [{ "type": "github", "url": "https://github.com/defi-protocol" }],
      "tags": ["defi", "lending"],
      "problem": "DeFi users lack visibility into...",
      "solution": "A unified dashboard...",
      "missionSummary": "Making DeFi risk transparent",
      "stageIn": "MVP",
      "communityUID": "0xcommunity...uid",
      "grant": {
        "title": "Optimism Builder Grant",
        "description": "Funding for protocol development",
        "amount": "50000",
        "proposalURL": "https://gov.optimism.io/proposal/123"
      }
    }
  }'
```

Include only the fields the user provided — all metadata fields are optional.

## After Success

Display the result:

```
Project + Grant created successfully!

Transaction: 0x...
Chain: Optimism (10)
```

Then offer guided enrichment (same as create-project):

> Project and grant created! Would you like to add more details to make your project stand out? I can walk you through:
>
> 1. **Mission & Problem** — What you solve and your mission
> 2. **Impact & Stage** — Where you operate and development stage
> 3. **Business & Funding** — Business model and funding status
>
> Pick a number, say **"all"** to go through everything, or **"skip"** to finish.

If the user wants to enrich, gather answers and call `updateProjectDetails` with the project UID from the creation response, including all original fields plus new metadata. See [Project Fields Reference](../references/project-fields.md#field-groups-for-guided-flow) for the questions to ask per group.

**Important**: `updateProjectDetails` replaces all fields. Always include the original title, description, links, tags alongside the new metadata.

## Edge Cases

| Scenario | Response |
|----------|----------|
| Community name given instead of UID | Look up the UID via communities API |
| Community not found | "Could not find that community. Provide the UID directly." |
| User wants separate creation | Suggest using `create-project` then `create-grant` instead |
| Amount with currency symbol | Strip symbol and convert ("$50K" → "50000") |
