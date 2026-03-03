# Funding API Reference

## API

**Base URL**: `https://gapapi.karmahq.xyz`
**Endpoint**: `GET /v2/program-registry/search`
**Auth**: None (public)

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
  "programs": [{
    "id", "programId", "type", "name", "isValid", "isActive", "isOnKarma",
    "deadline", "submissionUrl",
    "communities": [{ "uid", "name", "slug", "imageUrl" }],
    "createdAt", "updatedAt",
    "metadata": {
      "title", "description", "shortDescription", "status",
      "startsAt", "endsAt", "categories", "ecosystems", "networks",
      "grantTypes", "organizations", "minGrantSize", "maxGrantSize",
      "programBudget", "website", "projectTwitter", "anyoneCanJoin",
      "socialLinks": { "twitter", "discord", "website", "orgWebsite", "grantsSite" }
    }
  }],
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

## Field Mapping

- **Name**: `metadata.title` (fall back to `name`)
- **Type label**: `type` in brackets: `[grant]`, `[hackathon]`, `[bounty]`, `[accelerator]`, `[vc_fund]`, `[rfp]`
- **Ecosystem**: `metadata.ecosystems` joined with `, ` (fall back to `communities[0].name`)
- **Description**: `metadata.description` truncated to ~120 chars

## Type-Specific Detail Line

- **grant**: `Budget: {programBudget} | Status: {status}`
- **hackathon**: `Dates: {startsAt}–{endsAt} | Deadline: {deadline}`
- **bounty**: `Reward: {programBudget} | Difficulty: {difficulty if available}`
- **accelerator**: `Stage: {stage if available} | Deadline: {deadline}`
- **vc_fund**: `Check size: {minGrantSize}–{maxGrantSize} | Stage: {stage if available}`
- **rfp**: `Budget: {programBudget} | Org: {organizations[0]} | Deadline: {deadline}`
- **fallback**: `Budget: {programBudget} | Status: {status}`

## Common Fields

- **Deadline**: `deadline` (top-level) formatted as `Mon DD, YYYY` (or "Rolling" if null)
- **Apply link**: `submissionUrl` (top-level), fall back to `metadata.socialLinks.grantsSite` or `metadata.website` or `metadata.socialLinks.website` (first non-empty)
