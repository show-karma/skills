---
name: setup-agent
description: Configure your Karma GAP API key for agent actions. Run this once before using any project, grant, or milestone skills.
version: 0.1.0
tags: [agent, setup, authentication]
---

# Setup Karma Agent

Configure your environment to use Karma GAP agent skills. Run this once before using any action skill.

## What You Need

A Karma API key (`karma_...`). You can get one from:
- **Karma GAP website**: Go to your profile settings and generate an API key
- **API directly**: If you have a JWT token, call `POST /v2/user/api-keys`

## Setup Steps

### 1. Set Your API Key

Ask the user for their API key, then guide them to export it:

```bash
export KARMA_API_KEY="karma_your_key_here"
```

### 2. Set the API URL (Optional)

Defaults to production. For staging or local development:

```bash
export KARMA_API_URL="https://gapapi.karmahq.xyz"  # production (default)
export KARMA_API_URL="http://localhost:3002"         # local development
```

### 3. Verify Configuration

Run this to verify everything works:

```bash
curl -s "${KARMA_API_URL:-https://gapapi.karmahq.xyz}/v2/agent/info" \
  -H "x-api-key: ${KARMA_API_KEY}" | python3 -m json.tool
```

**Expected response:**
```json
{
  "walletAddress": "0x...",
  "smartAccountAddress": "0x...",
  "supportedChainIds": [10, 137, 1135, ...],
  "supportedActions": ["createProject", "createMilestone", ...]
}
```

### 4. Confirm Success

If the response includes `walletAddress` and `supportedActions`, the setup is complete. Tell the user:

> Your Karma agent is ready! You can now use these skills:
> - `create-project` — Create a new project on-chain
> - `update-project` — Update an existing project's details
> - `create-project-update` — Post a progress update
> - `create-grant` — Add funding to a project
> - `create-grant-update` — Post a grant progress update
> - `create-milestone` — Add a milestone to a grant
> - `complete-milestone` — Mark a milestone as done
> - `create-project-with-grant` — Create project + grant in one tx

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `401 Invalid or revoked API key` | Key is wrong or expired — regenerate at gap.karmahq.xyz |
| `walletAddress: null` | Key was created before server wallets — regenerate it |
| `Connection refused` | Wrong `KARMA_API_URL` — check the URL is reachable |
| `KARMA_API_KEY not set` | Run `export KARMA_API_KEY="karma_..."` in your terminal |
