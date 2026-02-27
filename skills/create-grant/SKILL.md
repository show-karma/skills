---
name: create-grant
description: Add a grant (funding) to an existing Karma GAP project. Attests Grant + GrantDetails on-chain.
version: 0.1.0
tags: [agent, grant, create, funding]
---

# Create Grant

Add a grant (funding record) to an existing project. This creates two on-chain attestations: Grant + GrantDetails.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Chain where the project lives |
| `projectUID` | Yes | The project's attestation UID |
| `communityUID` | Yes | The community/program UID (bytes32) that funded the project |
| `title` | Yes | Grant title (1-200 chars) |
| `description` | No | Grant description (max 5000 chars) |
| `amount` | No | Funding amount as string (e.g., "50000") |
| `proposalURL` | No | Link to the grant proposal |
| `programId` | No | Program identifier |

## Finding UIDs

**Project UID** — search by name:
```bash
curl -s "${BASE_URL}/v2/projects?q=PROJECT_NAME&limit=5&page=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('payload', []):
    d = p.get('details', {})
    print(f'Title: {d.get(\"title\", \"N/A\")} | Chain: {p[\"chainID\"]} | UID: {p[\"uid\"]}')
"
```

**Community UID** — browse communities or get by slug:
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
| "add a grant to project X" | Look up project UID, ask for community and grant details |
| "project X received $50K from Optimism" | Look up project + community UIDs, amount: "50000" |
| "add funding from program Y to project X" | Look up both UIDs, ask for amount |
| "create a grant for 0xabc... from 0xdef..." | Use UIDs directly |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createGrant",
    "params": {
      "chainId": 10,
      "projectUID": "0xproject...",
      "communityUID": "0xcommunity...",
      "title": "Optimism Builder Grant",
      "description": "Funding for protocol development",
      "amount": "50000",
      "proposalURL": "https://gov.optimism.io/proposal/123"
    }
  }'
```

## After Success

1. Trigger the indexer with the transaction hash and chain ID
2. Display the result using the standard output format

## Edge Cases

| Scenario | Response |
|----------|----------|
| Project or community name given instead of UID | Look up UIDs via the APIs |
| Community not found | "Could not find that community/program. Provide the community UID directly." |
| Amount with currency symbol | Strip the symbol and convert (e.g., "$50K" → "50000") |
| Missing community UID | This is required — ask the user which program/community funded the project |
