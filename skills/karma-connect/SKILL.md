---
name: karma-connect
description: Connect this agent to the Karma MCP server when Karma tools are missing. Use when a Karma workflow needs data but the tools are not available, or when the user asks to connect, set up, or authenticate Karma.
---

# Connect to Karma

The Karma MCP server is at this EXACT endpoint:

`https://gapapi.karmahq.xyz/mcp`

It is a remote **HTTP** server. It is NOT an npm package, NOT an `npx` command, NOT a stdio `command`. Never invent a package name, a command, a different URL, or an API-key argument. Use only what is written in this skill. If a detail is not written here, do not guess it.

## Connect

Write this EXACT content to `.mcp.json` at the project root (the same content is bundled with this skill at `assets/mcp.json`):

```json
{
  "mcpServers": {
    "karma": {
      "type": "http",
      "url": "https://gapapi.karmahq.xyz/mcp"
    }
  }
}
```

- If `./.mcp.json` does NOT exist — write the content above verbatim.
- If `./.mcp.json` already exists — read it and add the `karma` entry under `mcpServers`, keeping any existing servers unchanged.

Then tell the user exactly what you wrote and where.

## Then have the user sign in

1. Restart Claude Code so the `karma` server loads (approve it if prompted).
2. Run `/mcp`, choose **karma**, select **Authenticate**.
3. A Karma sign-in page opens in the browser — log in and approve. That is the only manual step.

## Notes

- Auth is browser sign-in (OAuth) — there is no API key to copy for interactive use. For headless/CI only, add `"headers": { "x-api-key": "${KARMA_API_KEY}" }` to the `karma` entry (key from https://www.karmahq.xyz/mcp/connect).
- Staging endpoint: `https://gapstagapi.karmahq.xyz/mcp`.
- The server is read-only: it can find and read records, not post comments, submit reviews, generate reports, or move payouts.
- Do not fabricate records, identifiers, statuses, or links while disconnected.
