#!/bin/bash
# Load Karma API credentials from plugin data directory into the session.
# Called by SessionStart hook — runs before any skill invocation.
#
# Resolution order:
# 1. KARMA_API_KEY already set in env → do nothing (CLI user with .zshrc)
# 2. CLAUDE_PLUGIN_DATA/credentials.json exists → load it (plugin user)
# 3. Neither → do nothing (setup-agent skill will handle it)

if [ -n "$KARMA_API_KEY" ]; then
  exit 0
fi

CRED_FILE="${CLAUDE_PLUGIN_DATA}/credentials.json"

if [ -z "$CLAUDE_PLUGIN_DATA" ] || [ ! -f "$CRED_FILE" ]; then
  exit 0
fi

API_KEY=$(python3 -c "import json; print(json.load(open('$CRED_FILE'))['apiKey'])" 2>/dev/null)

if [ -n "$API_KEY" ]; then
  echo "export KARMA_API_KEY=\"${API_KEY}\"" >> "$CLAUDE_ENV_FILE"
fi

# Also load custom API URL if saved
API_URL=$(python3 -c "import json; d=json.load(open('$CRED_FILE')); print(d.get('apiUrl',''))" 2>/dev/null)

if [ -n "$API_URL" ]; then
  echo "export KARMA_API_URL=\"${API_URL}\"" >> "$CLAUDE_ENV_FILE"
fi
