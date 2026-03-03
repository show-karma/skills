---
name: create-milestone
description: Add a milestone to a grant on the Karma protocol. Use when user says "add milestone", "create milestone", "set deliverable", "add deadline to grant", or "define grant milestones".
version: 0.1.0
tags: [agent, milestone, create, grant]
metadata:
  author: Karma
  category: grant-management
---

# Create Milestone

Add a milestone to an existing grant. This creates a Milestone attestation referencing the grant.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Chain where the grant lives |
| `grantUID` | Yes | The grant's attestation UID |
| `title` | Yes | Milestone title (1-200 chars) |
| `description` | Yes | Milestone description (1-5000 chars) |
| `endsAt` | Yes | Deadline as Unix timestamp (seconds) |
| `priority` | No | Priority order (0-indexed integer) |

## Date Handling

The `endsAt` field is a Unix timestamp in **seconds**. Convert user dates:

| User says | Unix timestamp |
|-----------|---------------|
| "end of March 2026" | 1743465600 (March 31, 2026 00:00 UTC) |
| "in 30 days" | Current time + 2592000 |
| "June 15, 2026" | 1750032000 |

Use `date -d "DATE" +%s` or Python to convert.

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
| "add a milestone to grant X" | Look up grant UID, ask for title, description, deadline |
| "create milestone: ship v2 by March" | title: "Ship v2", endsAt: end of March, ask for grant |
| "add 3 milestones to my grant" | Create each one sequentially |
| "milestone for 0xgrant...: Phase 1 by June" | Use UID, parse deadline |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createMilestone",
    "params": {
      "chainId": 10,
      "grantUID": "0xgrant...uid",
      "title": "Ship Protocol v2",
      "description": "Deploy the v2 smart contracts and frontend",
      "endsAt": 1743465600,
      "priority": 0
    }
  }'
```

## After Success

Display the result using the standard output format. The milestone will be automatically indexed by the system.

## Edge Cases

| Scenario | Response |
|----------|----------|
| No deadline given | Ask for a target date |
| Relative date ("in 2 months") | Convert to absolute Unix timestamp |
| Multiple milestones requested | Create them one by one, incrementing priority |
| Grant not found | Help look it up via project name |
