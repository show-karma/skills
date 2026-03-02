---
name: create-project
description: Create a new project on the Karma GAP protocol. Use when user says "create a project", "new project", "register project", or "start a project on Karma".
version: 0.1.0
tags: [agent, project, create]
metadata:
  author: Karma
  category: project-management
---

# Create Project

Create a new project on the Karma GAP protocol. This creates two on-chain attestations: Project + ProjectDetails.

See [Agent API Reference](../references/agent-api.md) for auth, base URL, and error handling.

## Prerequisite

If `KARMA_API_KEY` is not set in the environment, invoke the `/setup-agent` skill first, then continue with this skill.

## Required Information

Gather from the user before calling the API:

| Field | Required | Description |
|-------|----------|-------------|
| `chainId` | Yes | Which blockchain (see supported chains in reference) |
| `title` | Yes | Project name (1-200 chars) |
| `description` | Yes | Project description (1-5000 chars) |
| `imageURL` | No | Project logo/image URL |
| `links` | No | Array of `{ type, url }` — e.g., github, website, twitter |
| `tags` | No | Array of strings — e.g., "defi", "infrastructure" (max 20) |

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "create a project" | Ask for title, description, chain |
| "create a project called X" | Use X as title, ask for description and chain |
| "create a DeFi project on Optimism" | tags: ["defi"], chainId: 10, ask for title/description |
| "new project on Base" | chainId: 8453, ask for title/description |

If the user doesn't specify a chain, ask. For testing, suggest OP Sepolia (11155420).

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
      "tags": ["defi", "infrastructure"]
    }
  }'
```

## After Success

Display the result using the output format from the reference. The project will be automatically indexed by the system.

## Edge Cases

| Scenario | Response |
|----------|----------|
| Missing title or description | Ask the user for the missing field |
| Chain not specified | Ask which chain, suggest options |
| API key not set | Invoke `/setup-agent` skill automatically |
| Title too long (>200) | Truncate and confirm with user |
