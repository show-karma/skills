# Karma Funding Map API Reference

**Base URL**: `https://gapapi.karmahq.xyz`
**Endpoint**: `GET /v2/program-registry/search`
**Auth**: None (public)

## Required Headers

Every request must include these tracking headers:

```bash
INVOCATION_ID=$(uuidgen)  # generate once per skill invocation, reuse across all requests
```

| Header | Value | Purpose |
|--------|-------|---------|
| `X-Source` | `skill:find-funding-opportunities` | Distinguish skill traffic from other API consumers |
| `X-Invocation-Id` | `$INVOCATION_ID` | Group the 1–4 curl calls per query into one trace |
| `X-Skill-Version` | Value of `metadata.version` from this skill's frontmatter | Track adoption of skill updates |

## Query Parameters

| Param | Type | Default | Notes |
|-------|------|---------|-------|
| `page` | int | 1 | 1-indexed |
| `limit` | int | 12 | Max 100 |
| `name` | string | — | Text search on title (case-insensitive regex) |
| `type` | string | — | Comma-separated: `grant,hackathon,bounty,accelerator,vc_fund,rfp` |
| `isValid` | enum | `accepted` | `accepted` / `rejected` / `pending` / `all` |
| `status` | enum | — | `active` / `inactive` (computed from deadline/endsAt) |
| `ecosystems` | string | — | Comma-separated: `Ethereum,Optimism` |
| `categories` | string | — | Comma-separated |
| `networks` | string | — | Comma-separated |
| `grantTypes` | string | — | Comma-separated |
| `communities` | string | — | Comma-separated community UIDs |
| `minGrantSize` | int | — | Min grant/reward size in USD |
| `maxGrantSize` | int | — | Max grant/reward size in USD |
| `sortField` | enum | `updatedAt` | `createdAt` / `updatedAt` / `startsAt` / `endsAt` / `name` |
| `sortOrder` | enum | `desc` | `asc` / `desc` |
| `onlyOnKarma` | bool | false | Only programs tracked on Karma |
| `communityUid` | string | — | Filter by community |
| `organization` | string | — | Filter by org name |

## Program Types

| Value | Description |
|-------|-------------|
| `grant` | Funding programs, ecosystem funds, retroactive/quadratic funding |
| `hackathon` | Time-bound building competitions with prizes and tracks |
| `bounty` | Task-based rewards with defined scope and payout |
| `accelerator` | Cohort programs with mentorship, often equity-based |
| `vc_fund` | Venture capital funds investing in web3 projects |
| `rfp` | Requests for proposals from DAOs/foundations with defined scope and budget |

Omitting `type` returns all types. Multiple types: `type=grant,hackathon`.

## Response Shape

```json
{
  "programs": [{ "id", "programId", "type", "name", "isValid", "isActive", "isOnKarma", "deadline", "submissionUrl", "communities": [{ "uid", "name", "slug", "imageUrl" }], "createdAt", "updatedAt", "metadata": { "title", "description", "shortDescription", "status", "startsAt", "endsAt", "categories", "ecosystems", "networks", "grantTypes", "organizations", "minGrantSize", "maxGrantSize", "programBudget", "website", "projectTwitter", "anyoneCanJoin", "socialLinks": { "twitter", "discord", "website", "orgWebsite", "grantsSite" } } }],
  "count", "totalPages", "currentPage", "hasNext", "hasPrevious"
}
```

## Known Ecosystem Values

```
Ethereum, Optimism, Arbitrum, Base, Polygon, Solana, Cosmos,
Avalanche, Near, Polkadot, Sui, Aptos, Starknet, zkSync,
Scroll, Linea, Mantle, Celo, Gnosis, Fantom, Filecoin,
Internet Computer, Tezos, Algorand, Hedera, MultiversX,
TON, Sei, Injective, Osmosis, Celestia, Berachain, Monad
```

## Known Category Values

```
Funding Opportunity, Grant, DAO Governance, Award,
Program Results, Upcoming Deadline, Retroactive Funding,
Quadratic Funding, Ecosystem Fund, Developer Grant,
Research, Tool
```

## Communities Endpoint

`GET /v2/communities?limit=100`

Response:
```json
{ "payload": [{ "uid": "0x...", "details": { "name": "GEN Ukraine", "slug": "gen-ukraine-community" } }, ...] }
```

Slugs are not guessable (e.g., "GEN Ukraine" → `gen-ukraine-community`), so always fetch the full list and match by name (case-insensitive, partial match).
