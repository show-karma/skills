---
name: setup-agent
description: Set up or log in to Karma. Use when user says "set up agent", "configure API key", "connect to Karma", "login to Karma", "log in", or before first use of any Karma skill.
version: 0.3.0
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
- **If not set** → use the `AskUserQuestion` tool with these options:
  - Question: "You need a Karma API key to continue. How would you like to set it up?"
  - Options: ["Quick start — Generate instantly (no account needed)", "Email login — Link to existing Karma account", "I already have a key"]

  - **Quick start** → go to [Quick Start — No Account Needed](#quick-start--no-account-needed)
  - **Email login** → go to [Create API Key via Email](#create-api-key-via-email)
  - **I already have a key** → ask for the key, skip to [Save Your API Key](#1-save-your-api-key)

## Quick Start — No Account Needed

The fastest way to get started. No email, no login, no existing account required.

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
INVOCATION_ID=$(uuidgen)

RESPONSE=$(curl -s -X POST "${BASE_URL}/v2/agent/register" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:setup-agent" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 0.3.0" \
  -d '{}')
API_KEY=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('key','') or d.get('apiKey',''))")
```

Extract the `key` value from the response into `API_KEY`. Proceed immediately to [Save Your API Key](#1-save-your-api-key).

> **Note**: Projects created with this method get their own wallet. They won't be linked to an existing Karma account, so they can't be managed from the website yet (coming in a future update).

## Create API Key via Email

### Step 1: Ask for Email

Ask the user for their email address.

### Step 2: Send Verification Code

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
INVOCATION_ID=$(uuidgen)

curl -s -X POST "${BASE_URL}/v2/api-keys/auth/init" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:setup-agent" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 0.3.0" \
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
RESPONSE=$(curl -s -X POST "${BASE_URL}/v2/api-keys/auth/verify" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:setup-agent" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 0.3.0" \
  -d '{
    "email": "user@example.com",
    "code": "123456",
    "name": "claude-agent"
  }')
API_KEY=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('key','') or d.get('apiKey',''))")
```

Extract the `key` value into `API_KEY`. Proceed immediately to save it.

### Step 4: Handle Errors

| Error | Meaning | Action |
|-------|---------|--------|
| `400 Invalid or expired code` | Wrong code or expired | Ask user to check code or request a new one |
| `409 Active key already exists` | User already has a key | Tell them to use their existing key or revoke it from the website |
| `429 Too many requests` | Rate limited | Wait and try again |

## 1. Save Your API Key

After obtaining the key (stored in `API_KEY` variable), save it automatically. The save method depends on the environment:

### If running as a plugin (`CLAUDE_PLUGIN_DATA` is set):

Save to the plugin's persistent data directory — this works in both CLI and Cowork and persists across sessions automatically:

```bash
mkdir -p "${CLAUDE_PLUGIN_DATA}"
echo "{\"apiKey\": \"${API_KEY}\"}" > "${CLAUDE_PLUGIN_DATA}/credentials.json"
export KARMA_API_KEY="${API_KEY}"
```

Tell the user:

> Your API key has been saved and will be loaded automatically in future sessions.

### If running standalone (no `CLAUDE_PLUGIN_DATA`):

Set the key for the current session:

```bash
export KARMA_API_KEY="${API_KEY}"
```

Then ask the user if they want to persist it:

> Your API key is set for this session. Would you like me to save it to your shell config so it persists across sessions?

If yes:

```bash
if [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi

if grep -q 'KARMA_API_KEY' "$SHELL_RC" 2>/dev/null; then
  sed -i.bak "s/export KARMA_API_KEY=.*/export KARMA_API_KEY=\"${API_KEY}\"/" "$SHELL_RC"
else
  echo "\n# Karma API Key\nexport KARMA_API_KEY=\"${API_KEY}\"" >> "$SHELL_RC"
fi
```

If no, the key is only available for the current session.

## 2. Set the API URL (Optional)

Defaults to production. For local development:

```bash
export KARMA_API_URL="http://localhost:3002"
```

## 3. Verify Configuration

```bash
curl -s "${KARMA_API_URL:-https://gapapi.karmahq.xyz}/v2/agent/info" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:setup-agent" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 0.3.0" \
  | python3 -m json.tool
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

If the response includes `walletAddress` and `supportedActions`, show the user their API key and confirm they're ready:

> Your Karma agent is ready!
>
> **API Key**: `karma_...` (the key from step 1 or the email flow)
>
> You can now use these skills:
> - `project-manager` — Create and manage projects, grants, milestones, and updates
> - `find-funding-opportunities` — Search for grants, hackathons, bounties, and more

Do NOT show wallet address, smart account address, or chain IDs to the user. They only need the API key.

## Action Safety

This setup skill only handles authentication — it does not execute any on-chain or financial actions. The action skills (project-manager, funding-program-manager) enforce their own confirmation flows before executing operations.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `401 Invalid or revoked API key` | Key is wrong or expired — regenerate via email flow or at karmahq.org |
| `walletAddress: null` | Key was created before server wallets — regenerate it |
| `Connection refused` | Wrong `KARMA_API_URL` — check the URL is reachable |
| `KARMA_API_KEY not set` | Run the setup-agent skill again to generate a new key |
