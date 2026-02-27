---
name: create-project-with-grant
description: Create a new project with a grant in a single transaction on the Karma GAP protocol. Attests Project + ProjectDetails + Grant + GrantDetails.
version: 0.1.0
tags: [agent, project, grant, create, batch]
---

# Create Project with Grant

Create a new project and attach a grant in a single on-chain transaction. This creates 4 attestations: Project + ProjectDetails + Grant + GrantDetails.

Use this instead of separate `create-project` + `create-grant` when the user wants to set up a project with its funding in one step.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Required Information

**Project fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Which blockchain |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |
| `imageURL` | No | Project logo/image URL |
| `links` | No | Array of `{ type, url }` |
| `tags` | No | Array of tag strings (max 20) |
| `communityUID` | Yes | The community/program UID that funded the project |

**Grant fields (nested under `grant`):**

| Field | Required | Description |
|-------|----------|-------------|
| `grant.title` | Yes | Grant title (1-200 chars) |
| `grant.description` | No | Grant description (max 5000 chars) |
| `grant.amount` | No | Funding amount as string |
| `grant.proposalURL` | No | Link to proposal |
| `grant.programId` | No | Program identifier |

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
| "create a project with a grant from Optimism" | Look up Optimism community UID, ask for project/grant details |
| "new project X funded by Y for $50K" | title: X, community: Y, amount: "50000" |
| "create project and grant together" | Ask for all details |
| "set up project X with Arbitrum grant" | Look up community, ask for remaining details |

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

## After Success

1. Trigger the indexer with the transaction hash and chain ID
2. Display the result — note this created 4 attestations in one tx:
   ```
   Project + Grant created successfully!

   Transaction: 0x...
   Chain: Optimism (10)
   Smart Account: 0x...
   Attestations: Project, ProjectDetails, Grant, GrantDetails (4 in 1 tx)

   Indexer: indexed
   ```

## Edge Cases

| Scenario | Response |
|----------|----------|
| Community name given instead of UID | Look up the UID via communities API |
| Community not found | "Could not find that community. Provide the UID directly." |
| User wants separate creation | Suggest using `create-project` then `create-grant` instead |
| Amount with currency symbol | Strip symbol and convert ("$50K" → "50000") |
