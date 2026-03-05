---
name: create-project
description: Create a new project on the Karma protocol. Use when user says "create a project", "new project", "register project", or "start a project on Karma".
version: 0.2.0
tags: [agent, project, create]
metadata:
  author: Karma
  category: project-management
---

# Create Project

Create a new project on the Karma protocol. This creates two on-chain attestations: Project + ProjectDetails.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.
See [Project Fields Reference](../references/project-fields.md) for all available fields with descriptions and examples.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

Gather from the user:

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Which blockchain (see supported chains in reference) |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |

Optional fields: `imageURL`, `links`, `tags`, plus 8 metadata fields — see [Project Fields Reference](../references/project-fields.md) for the full list.

If the user provides metadata fields (problem, solution, missionSummary, etc.) upfront, include them in the request.

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "create a project" | Ask for title, description, chain |
| "create a project called X" | Use X as title, ask for description and chain |
| "create a DeFi project on Optimism" | tags: ["defi"], chainId: 10, ask for title/description |
| "new project on Base" | chainId: 8453, ask for title/description |

If the user doesn't specify a chain, ask which one they want.

## Making the Request

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "createProject",
    "params": {
      "chainId": 10,
      "title": "My Project",
      "description": "Project description",
      "imageURL": "https://example.com/logo.png",
      "links": [
        { "type": "github", "url": "https://github.com/myproject" },
        { "type": "website", "url": "https://myproject.com" }
      ],
      "tags": ["defi", "infrastructure"],
      "problem": "Users lack visibility into...",
      "solution": "A unified dashboard that...",
      "missionSummary": "Making DeFi risk transparent",
      "stageIn": "MVP"
    }
  }'
```

Include only the fields the user provided — all metadata fields are optional.

## After Success

Display the result using the output format from the reference. Then offer to enrich the project.

## Guided Enrichment (after creation)

After the project is created, offer to add more details:

> Project created! Would you like to add more details to make it stand out? I can walk you through:
>
> 1. **Mission & Problem** — What you solve and your mission
> 2. **Impact & Stage** — Where you operate and development stage
> 3. **Business & Funding** — Business model and funding status
>
> Pick a number, say **"all"** to go through everything, or **"skip"** to finish.

For each section, ask conversational questions based on the [Field Groups](../references/project-fields.md#field-groups-for-guided-flow). Accept freeform answers and map them to the structured fields.

After gathering answers, call `updateProjectDetails` with the project's UID, all original fields, plus the new metadata:

```bash
curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -d '{
    "action": "updateProjectDetails",
    "params": {
      "chainId": 10,
      "projectUID": "0x...",
      "title": "My Project",
      "description": "Project description",
      "problem": "Users answer from Q&A",
      "solution": "Users answer from Q&A",
      "missionSummary": "Users answer from Q&A"
    }
  }'
```

**Important**: `updateProjectDetails` replaces all fields. Always include the original title, description, links, tags alongside the new metadata.

If the user says "skip" or the project was created from a URL with fields already filled, skip the enrichment.

## Edge Cases

| Scenario | Response |
|----------|----------|
| Missing title or description | Ask the user for the missing field |
| Chain not specified | Ask which chain |
| API key not set | Invoke `/setup-agent` skill automatically |
| Title too long (>200) | Truncate and confirm with user |
| User skips enrichment | Fine — metadata is optional |
