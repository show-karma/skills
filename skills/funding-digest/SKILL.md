---
name: funding-digest
description: Weekly digest of new funding opportunities from the Karma Funding Map. Use when user says "funding digest", "weekly funding report", "new grants this week", "what funding was added recently", "funding roundup", "set up funding alerts", or "notify me about new programs".
version: 0.1.0
tags: [funding, digest, cron, weekly, discovery]
metadata: {"author": "Karma", "category": "discovery"}
---

# Weekly Funding Digest

Fetches new funding programs added to the Karma Funding Map in the past 7 days and formats a concise digest. Can run on a weekly schedule or on demand.

For full API parameters and response shape, see [find-funding-opportunities API reference](../find-funding-opportunities/references/api-reference.md).

## Step 1: Check User Preferences

Before fetching, check the user's persistent memory for stored funding preferences:

- **Claude Code**: check CLAUDE.md and auto-memory for a `funding-digest-preferences` section
- **OpenClaw**: check USER.md or MEMORY.md for a `funding-digest-preferences` section

Look for any of these preference keys:

| Preference | Example | Maps to API param |
|------------|---------|-------------------|
| `ecosystems` | "Ethereum, Optimism" | `ecosystems=Ethereum,Optimism` |
| `types` | "grant, hackathon" | `type=grant,hackathon` |
| `topic` | "AI" | `name=AI` |
| `categories` | "Developer Grant, Research" | `categories=Developer%20Grant,Research` |
| `minBudget` | 10000 | `minGrantSize=10000` |
| `maxBudget` | 100000 | `maxGrantSize=100000` |

If no preferences are found and this is a scheduled (cron) run, fetch everything unfiltered.
If no preferences are found and this is a manual run, fetch everything and then ask: "Would you like to set up filters so future digests only show programs you care about?"

### Saving preferences

When the user asks to filter future digests (e.g., "only ping me about AI programs", "I only care about Ethereum grants"), save their preferences:

- **Claude Code**: write to auto-memory or CLAUDE.md under a `## funding-digest-preferences` section
- **OpenClaw**: write to USER.md under a `## funding-digest-preferences` section

Example saved preferences:
```markdown
## funding-digest-preferences
- topic: AI
- ecosystems: Ethereum, Optimism
- types: grant, hackathon
- minBudget: 5000
```

## Step 2: Fetch Recent Programs

Build the API query with user preferences applied:

```bash
INVOCATION_ID=$(uuidgen)
H=(-H "X-Source: skill:funding-digest" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 0.1.0")
CUTOFF=$(date -v-7d +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -d '7 days ago' +%Y-%m-%dT%H:%M:%S)

curl -s "${H[@]}" \
  "https://gapapi.karmahq.xyz/v2/program-registry/search?isValid=accepted&status=active&limit=25&sortField=createdAt&sortOrder=desc"
```

Append user preference params to the URL (e.g., `&ecosystems=Ethereum&name=AI&type=grant`).

Then filter results client-side: keep only programs where `createdAt` >= `$CUTOFF`.

If `hasNext` is true and the oldest program in the page is still within the 7-day window, fetch the next page.

## Step 3: Format the Digest

### Programs found

```
# Funding Digest — Week of {Mon DD}

{N} new program(s) this week{preference_summary}:

1. **{name}** [{type}] — {ecosystems}
   {shortDescription or first sentence of description}
   Budget: ${programBudget or minGrantSize–maxGrantSize} | Deadline: {deadline or "Rolling"}
   Apply: {submissionUrl}

2. ...

View all → https://karmahq.xyz/funding-map
```

Where `{preference_summary}` is e.g., " matching AI on Ethereum" if preferences are set, or empty if unfiltered.

### No programs found

```
# Funding Digest — Week of {Mon DD}

No new programs added this week{preference_summary}.

Browse all active programs at https://karmahq.xyz/funding-map
```

If preferences are set and no results found, suggest: "Try broadening your filters — run `show me new funding this week` without filters to see everything."

## Step 4: Cron Setup (optional)

When the user asks to set up automatic weekly digests:

1. Ask preferred day and time (default: Monday 9am local time)
2. Ask preferred delivery channel (OpenClaw only: Slack, Telegram, Discord, etc.)
3. Set up the schedule per platform:

### Claude Code (CronCreate tool)

```
Schedule: 0 9 * * 1
Prompt: Run the funding-digest skill — fetch and display new funding opportunities from the past week
```

Note: Claude Code crons auto-expire after 3 days. Mention this to the user and suggest re-running setup periodically, or using OpenClaw for persistent scheduling.

### OpenClaw (cron.add — persistent)

Use the `cron.add` tool to register a recurring job. This persists in `~/.openclaw/cron/jobs.json` and survives restarts.

**Basic setup (main session):**
```json
{
  "name": "Karma Funding Digest",
  "schedule": { "kind": "cron", "expr": "0 9 * * 1", "tz": "USER_TIMEZONE" },
  "sessionTarget": "isolated",
  "wakeMode": "now",
  "payload": {
    "kind": "agentTurn",
    "message": "Run the funding-digest skill. Check my preferences in USER.md, fetch new programs from the past 7 days, and show me the digest.",
    "lightContext": true
  }
}
```

**With delivery to a channel (Slack, Telegram, etc.):**
```json
{
  "name": "Karma Funding Digest",
  "schedule": { "kind": "cron", "expr": "0 9 * * 1", "tz": "USER_TIMEZONE" },
  "sessionTarget": "isolated",
  "wakeMode": "now",
  "payload": {
    "kind": "agentTurn",
    "message": "Run the funding-digest skill. Check my preferences in USER.md, fetch new programs from the past 7 days, and show me the digest.",
    "lightContext": true
  },
  "delivery": {
    "mode": "announce",
    "channel": "PLATFORM",
    "to": "CHANNEL_OR_USER_ID",
    "bestEffort": true
  }
}
```

Replace `USER_TIMEZONE` with the user's IANA timezone (e.g., `America/New_York`), `PLATFORM` with `slack`, `telegram`, `discord`, etc., and `CHANNEL_OR_USER_ID` with the target (e.g., `channel:C1234567890` or `user:U1234567890`).

**Managing the job:**
- `cron.list` — show all scheduled jobs
- `cron.update` with `jobId` — change schedule, enable/disable
- `cron.remove` with `jobId` — delete the job
- `cron.run` with `jobId` — trigger immediately for testing

## Error Handling

| Error | Action |
|-------|--------|
| API unreachable | "Could not reach the Karma API — try again later or check https://karmahq.xyz/funding-map directly." |
| Empty results with preferences | Suggest broadening filters |
| Rate limiting | Wait briefly and retry once |
