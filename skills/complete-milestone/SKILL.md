---
name: complete-milestone
description: Mark a milestone as completed on the Karma protocol. Use when user says "complete milestone", "mark milestone done", "finish milestone", "milestone completed", or "submit milestone proof".
version: 0.1.0
tags: [agent, milestone, complete]
metadata:
  author: Karma
  category: grant-management
---

# Complete Milestone

Mark an existing milestone as completed. This creates a MilestoneCompleted attestation referencing the milestone.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Always `8453` (Base) |
| `milestoneUID` | Yes | The milestone's attestation UID |
| `reason` | Yes | Completion explanation (1-5000 chars) |
| `proofOfWork` | No | URL to proof (demo, PR, deployment, etc.) |

## Finding the Milestone UID

Search for the project, then fetch grants and milestones:

```bash
# Step 1: Find the project
curl -s "${BASE_URL}/v2/projects?q=PROJECT_NAME&limit=5&page=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('payload', []):
    d = p.get('details', {})
    print(f'Title: {d.get(\"title\", \"N/A\")} | Chain: {p[\"chainID\"]} | UID: {p[\"uid\"]}')
"

# Step 2: Get grants and milestones for the project
curl -s "${BASE_URL}/v2/projects/PROJECT_UID_OR_SLUG/grants" | python3 -c "
import sys, json
data = json.load(sys.stdin)
grants = data if isinstance(data, list) else data.get('payload', data.get('data', []))
for g in grants:
    d = g.get('details', {})
    title = d.get('title', d.get('data', {}).get('title', 'Untitled')) if isinstance(d, dict) else 'Untitled'
    print(f'Grant: {title} | UID: {g[\"uid\"]}')
    for m in g.get('milestones', []):
        mt = m.get('data', {}).get('title', m.get('title', 'Untitled'))
        print(f'  Milestone: {mt} | UID: {m[\"uid\"]}')
"
```

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "complete milestone X" | Look up milestone UID, ask for reason |
| "mark milestone 0xabc... as done" | Use UID, ask for reason |
| "we finished the v2 deployment" | Ask which project/grant/milestone, use as reason |
| "complete milestone with proof: https://..." | Extract proof URL, ask for milestone UID |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "completeMilestone",
    "params": {
      "chainId": 8453,
      "milestoneUID": "0xmilestone...uid",
      "reason": "All deliverables completed. Smart contracts deployed and audited.",
      "proofOfWork": "https://github.com/myproject/releases/tag/v2.0"
    }
  }'
```

## After Success

Display the result using the standard output format. The completion will be automatically indexed by the system.

## Edge Cases

| Scenario | Response |
|----------|----------|
| Milestone name given instead of UID | Look it up via project → grant → milestones |
| No proof of work | That's fine, it's optional — just ask for the reason |
| Multiple milestones to complete | Process them one by one |
| Milestone not found | "Could not find that milestone. Check the project/grant or provide the UID." |
