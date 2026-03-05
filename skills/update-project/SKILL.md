---
name: update-project
description: Update an existing project's details (title, description, image, links, tags, metadata) on the Karma protocol. Use when user says "update project", "change project details", "edit project", "rename project", or "enrich my project".
version: 0.2.0
tags: [agent, project, update]
metadata:
  author: Karma
  category: project-management
---

# Update Project

Update an existing project's details on the Karma protocol. This creates a new ProjectDetails attestation referencing the existing project.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.
See [Project Fields Reference](../references/project-fields.md) for all available fields with descriptions and examples.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Chain where the project lives |
| `projectUID` | Yes | The project's attestation UID (bytes32 hex string) |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |

Optional: `imageURL`, `links`, `tags`, plus 8 metadata fields (`problem`, `solution`, `missionSummary`, `locationOfImpact`, `businessModel`, `stageIn`, `raisedMoney`, `pathToTake`) — see [Project Fields Reference](../references/project-fields.md).

**Important**: `updateProjectDetails` **replaces** all fields entirely. If the user only wants to change one field, fetch the current details first and merge the change with existing data.

## Finding the Project UID

If the user knows the project name but not the UID, search for it:

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
| "update my project" | Ask which project (name or UID) |
| "change the title of project X to Y" | Look up X's UID, set title to Y, keep other fields |
| "add a github link to project X" | Look up current details, add the link |
| "update description of 0xabc..." | Use the UID directly |
| "add mission and problem info to project X" | Fetch current, ask for problem/solution/missionSummary |
| "enrich my project with more details" | Fetch current, ask what's missing, guide through metadata |

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "updateProjectDetails",
    "params": {
      "chainId": 10,
      "projectUID": "0x1234...abcd",
      "title": "Updated Project Name",
      "description": "Updated description",
      "links": [{ "type": "github", "url": "https://github.com/updated" }],
      "tags": ["defi"],
      "problem": "DeFi users lack...",
      "solution": "A unified dashboard...",
      "missionSummary": "Making DeFi transparent",
      "stageIn": "Beta",
      "businessModel": "Protocol fees"
    }
  }'
```

Include all fields (existing + updated) since the request replaces everything.

## After Success

Display the result using the standard output format. The updated details will be automatically indexed.

## Edge Cases

| Scenario | Response |
|----------|----------|
| Project name given instead of UID | Look up the UID via the projects API |
| User only wants to change one field | Fetch current details first, merge the change |
| Project not found | "Could not find a project with that name. Check the name or provide the UID directly." |
| User doesn't own the project | The API will return an error — relay it to the user |
