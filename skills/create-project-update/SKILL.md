---
name: create-project-update
description: Post a progress update on an existing Karma GAP project. Attests a ProjectUpdate on-chain.
version: 0.1.0
tags: [agent, project, update, progress]
---

# Create Project Update

Post a progress update on an existing project. This creates a ProjectUpdate attestation referencing the project.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Chain where the project lives |
| `projectUID` | Yes | The project's attestation UID |
| `title` | Yes | Update title (1-200 chars) |
| `text` | Yes | Update content (1-10000 chars) |

## Finding the Project UID

If the user knows the project name but not the UID:

```bash
curl -s "${BASE_URL}/v2/projects?q=PROJECT_NAME&limit=5&page=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('payload', []):
    d = p.get('details', {})
    print(f'Title: {d.get(\"title\", \"N/A\")} | Chain: {p[\"chainID\"]} | UID: {p[\"uid\"]}')
"
```

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "post an update on project X" | Look up X's UID, ask for title and text |
| "update project X: we shipped feature Y" | Look up X, use "Feature Y shipped" as title, expand text |
| "progress report for 0xabc..." | Use UID directly, ask for title and text |
| "tell them we completed phase 1" | Ask which project, use as update content |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createProjectUpdate",
    "params": {
      "chainId": 10,
      "projectUID": "0x1234...abcd",
      "title": "Q1 2026 Progress Report",
      "text": "We shipped the v2 protocol with 3 new features..."
    }
  }'
```

## After Success

1. Trigger the indexer with the transaction hash and chain ID
2. Display the result using the standard output format

## Edge Cases

| Scenario | Response |
|----------|----------|
| Project name given instead of UID | Look up the UID via the projects API |
| No title provided | Generate a sensible title from the text content |
| Very long text (>10000 chars) | Summarize or truncate, confirm with user |
| Project not found | "Could not find that project. Check the name or provide the UID." |
