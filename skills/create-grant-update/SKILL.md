---
name: create-grant-update
description: Post a progress update on an existing grant in the Karma GAP protocol. Attests a GrantUpdate on-chain.
version: 0.1.0
tags: [agent, grant, update, progress]
---

# Create Grant Update

Post a progress update on an existing grant. This creates a GrantUpdate attestation referencing the grant.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Chain where the grant lives |
| `grantUID` | Yes | The grant's attestation UID |
| `title` | Yes | Update title (1-200 chars) |
| `text` | Yes | Update content (1-10000 chars) |

## Finding the Grant UID

If the user knows the project name, search for it then fetch its grants:

```bash
# Step 1: Find the project
curl -s "${BASE_URL}/v2/projects?q=PROJECT_NAME&limit=5&page=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('payload', []):
    d = p.get('details', {})
    print(f'Title: {d.get(\"title\", \"N/A\")} | Chain: {p[\"chainID\"]} | UID: {p[\"uid\"]}')
"

# Step 2: Get grants for the project
curl -s "${BASE_URL}/v2/projects/PROJECT_UID_OR_SLUG/grants" | python3 -c "
import sys, json
data = json.load(sys.stdin)
grants = data if isinstance(data, list) else data.get('payload', data.get('data', []))
for g in grants:
    d = g.get('details', {})
    title = d.get('title', d.get('data', {}).get('title', 'Untitled')) if isinstance(d, dict) else 'Untitled'
    print(f'Grant: {title} | UID: {g[\"uid\"]}')
"
```

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "post a grant update on project X" | Look up project grants, ask which grant if multiple |
| "update grant 0xabc... with progress" | Use UID directly, ask for title and text |
| "report progress on my Optimism grant" | Look up by project + community name |
| "we finished phase 1 of the grant" | Ask which project/grant, use as update content |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createGrantUpdate",
    "params": {
      "chainId": 10,
      "grantUID": "0xgrant...uid",
      "title": "Phase 1 Complete",
      "text": "We completed all Phase 1 deliverables including..."
    }
  }'
```

## After Success

1. Trigger the indexer with the transaction hash and chain ID
2. Display the result using the standard output format

## Edge Cases

| Scenario | Response |
|----------|----------|
| Project has multiple grants | List them and ask the user which one |
| Grant UID not known | Help look it up via project name |
| No title provided | Generate a sensible title from the text |
| Grant not found | "Could not find that grant. Check the project name or provide the grant UID." |
