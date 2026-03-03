---
name: setup-agent
description: Set up or log in to Karma. Use when user says "set up agent", "configure API key", "connect to Karma", "login to Karma", "log in", or before first use of any Karma skill.
version: 0.2.0
tags: [agent, setup, authentication, login]
metadata:
  author: Karma
  category: authentication
---

# Setup Karma Agent

Configure your environment to use Karma agent skills. Run this once before using any action skill.

See [Agent API Reference](../references/agent-api.md) for base URL and error handling.

## Flow

Check if `KARMA_API_KEY` is already set:

- **If set** → skip to [Verify Configuration](#3-verify-configuration)
- **If not set** → ask the user:

> Do you already have a Karma API key, or would you like to create one?

- **"I have one"** → ask for it, skip to [Set Your API Key](#1-set-your-api-key)
- **"Create one" / "Login"** → go to [Create API Key via Email](#create-api-key-via-email)

## Create API Key via Email

### Step 1: Ask for Email

Ask the user for their email address.

### Step 2: Send Verification Code

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"

curl -s -X POST "${BASE_URL}/v2/api-keys/auth/init" \
  -H "Content-Type: application/json" \
  -d '{ "email": "user@example.com" }'
```

**Expected response:**
```json
{ "message": "Verification code sent to user@example.com" }
```

Tell the user: "Check your email for a verification code from Karma."

### Step 3: Verify Code

Ask the user for the code they received, then:

```bash
curl -s -X POST "${BASE_URL}/v2/api-keys/auth/verify" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "code": "123456",
    "name": "claude-agent"
  }'
```

**Expected response:**
```json
{ "key": "karma_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }
```

**Important:** The key is shown only once. Proceed immediately to set it.

### Step 4: Handle Errors

| Error | Meaning | Action |
|-------|---------|--------|
| `400 Invalid or expired code` | Wrong code or expired | Ask user to check code or request a new one |
| `409 Active key already exists` | User already has a key | Tell them to use their existing key or revoke it from the website |
| `429 Too many requests` | Rate limited | Wait and try again |

## 1. Set Your API Key

```bash
export KARMA_API_KEY="karma_your_key_here"
```

## 2. Set the API URL (Optional)

Defaults to production. For local development:

```bash
export KARMA_API_URL="http://localhost:3002"
```

## 3. Verify Configuration

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

## 4. Confirm Success

If the response includes `walletAddress` and `supportedActions`, tell the user their API key and that they're ready:

> Your Karma agent is ready!
>
> **API Key**: `karma_...` (the key from step 1 or the email flow)
>
> You can now use these skills:
> - `create-project` — Create a new project on-chain
> - `update-project` — Update an existing project's details
> - `create-project-update` — Post a progress update
> - `create-grant` — Add funding to a project
> - `create-grant-update` — Post a grant progress update
> - `create-milestone` — Add a milestone to a grant
> - `complete-milestone` — Mark a milestone as done
> - `create-project-with-grant` — Create project + grant in one tx

Do NOT show wallet address, smart account address, or chain IDs to the user. They only need the API key.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `401 Invalid or revoked API key` | Key is wrong or expired — regenerate via email flow or at karmahq.xyz |
| `walletAddress: null` | Key was created before server wallets — regenerate it |
| `Connection refused` | Wrong `KARMA_API_URL` — check the URL is reachable |
| `KARMA_API_KEY not set` | Run `export KARMA_API_KEY="karma_..."` in your terminal |
