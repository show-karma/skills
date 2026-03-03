# Karma Agent API Reference

## Base URL

Use the environment variable `KARMA_API_URL` if set, otherwise default to `https://gapapi.karmahq.xyz`.

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
```

## Authentication

All agent endpoints require an API key via the `x-api-key` header.

```bash
API_KEY="${KARMA_API_KEY}"
```

If `KARMA_API_KEY` is not set, stop and tell the user:

> You need to set your Karma API key first. Run the `setup-agent` skill or set it manually:
> ```bash
> export KARMA_API_KEY="karma_your_key_here"
> ```

## Execute Endpoint

**POST** `{BASE_URL}/v2/agent/execute`

### Request

```bash
curl -s -X POST "${BASE_URL}/v2/agent/execute" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -d '{ "action": "<action>", "params": { ... } }'
```

### Success Response

```json
{
  "transactionHash": "0x...",
  "chainId": 10,
  "smartAccountAddress": "0x..."
}
```

Attestations are automatically indexed by the system after a successful transaction.

## Info Endpoint

**GET** `{BASE_URL}/v2/agent/info`

Returns the agent's wallet address, smart account, supported chains, and supported actions.

## Supported Chains

| Chain | ID |
|-------|-----|
| Optimism | 10 |
| Polygon | 137 |
| Lisk | 1135 |
| Sei | 1329 |
| Base | 8453 |
| Arbitrum | 42161 |
| Celo | 42220 |
| Base Sepolia | 84532 |
| Scroll | 534352 |
| Sepolia | 11155111 |
| OP Sepolia | 11155420 |

When the user doesn't specify a chain, ask which chain they want. For testnets, suggest OP Sepolia (11155420).

## Error Responses

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Validation error (bad params) | Show the error message, help fix params |
| 401 | Invalid or missing API key | Tell user to check `KARMA_API_KEY` |
| 429 | Rate limited (60 req/min) | Wait and retry |
| 500 | Server error | Try again in a moment |

## API Documentation

Full Swagger docs: `{BASE_URL}/v2/docs/static/index.html`

## Looking Up Data

### Search Projects

```bash
curl -s "${BASE_URL}/v2/projects?q=SEARCH_TERM&limit=5&page=1"
```

Response shape: `{ "payload": [...], "pagination": { "totalCount", "page", "limit", ... } }`

Each project in `payload` has:
- `uid` — the project attestation UID
- `chainID` — the chain ID
- `owner` — the project owner address
- `details.title` — project title
- `details.slug` — project slug
- `details.description` — project description

### Get Project by UID or Slug

```bash
curl -s "${BASE_URL}/v2/projects/PROJECT_UID_OR_SLUG"
```

### Get Project Grants

```bash
curl -s "${BASE_URL}/v2/projects/PROJECT_UID_OR_SLUG/grants"
```

### Search Communities

```bash
curl -s "${BASE_URL}/v2/communities/?limit=5&page=1"
```

### Get Community by UID or Slug

```bash
curl -s "${BASE_URL}/v2/communities/COMMUNITY_UID_OR_SLUG"
```

### List Programs for a Community

When adding a grant to a specific program (not just generic community funding), look up the `programId` first:

```bash
curl -s "${BASE_URL}/communities/COMMUNITY_SLUG_OR_UID/programs"
```

Each program has:
- `programId` — the ID to pass in the grant params
- `metadata.title` — the program name

**Important**: If the user mentions a program/track name, always look up the `programId` and include it in the grant params. Without it, the grant won't appear under that program on the website.

## Output Format

After a successful action, always display:

```
[Action] completed successfully!

Transaction: {transactionHash}
Chain: {chainName} ({chainId})
Smart Account: {smartAccountAddress}
```
