---
name: find-programs
description: Search the Karma Funding Map for funding programs (grants, hackathons, bounties, accelerators, VC funds, RFPs) via the public API. Use when a user asks about funding opportunities, programs, or ecosystem grants.
---

# Funding Program Finder

Search the Karma Funding Map for funding programs via the public API.

The registry has 6 program types: grants, hackathons, bounties, accelerators, VC funds, and RFPs. Use "programs" / "opportunities" / "funding" — not just "grants".

## API

**Base URL**: `https://gapapi.karmahq.xyz`
**Endpoint**: `GET /v2/program-registry/search`
**Auth**: None (public)

### Query Parameters

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

### Program Types

| Value | Description |
|-------|-------------|
| `grant` | Funding programs, ecosystem funds, retroactive/quadratic funding |
| `hackathon` | Time-bound building competitions with prizes and tracks |
| `bounty` | Task-based rewards with defined scope and payout |
| `accelerator` | Cohort programs with mentorship, often equity-based |
| `vc_fund` | Venture capital funds investing in web3 projects |
| `rfp` | Requests for proposals from DAOs/foundations with defined scope and budget |

Omitting `type` returns all types. Multiple types: `type=grant,hackathon`.

### Response Shape

```json
{
  "programs": [{ "id", "programId", "type", "name", "isValid", "isActive", "isOnKarma", "deadline", "submissionUrl", "communities": [{ "uid", "name", "slug", "imageUrl" }], "createdAt", "updatedAt", "metadata": { "title", "description", "shortDescription", "status", "startsAt", "endsAt", "categories", "ecosystems", "networks", "grantTypes", "organizations", "minGrantSize", "maxGrantSize", "programBudget", "website", "projectTwitter", "anyoneCanJoin", "socialLinks": { "twitter", "discord", "website", "orgWebsite", "grantsSite" } } }],
  "count", "totalPages", "currentPage", "hasNext", "hasPrevious"
}
```

### Known Ecosystem Values

```
Ethereum, Optimism, Arbitrum, Base, Polygon, Solana, Cosmos,
Avalanche, Near, Polkadot, Sui, Aptos, Starknet, zkSync,
Scroll, Linea, Mantle, Celo, Gnosis, Fantom, Filecoin,
Internet Computer, Tezos, Algorand, Hedera, MultiversX,
TON, Sei, Injective, Osmosis, Celestia, Berachain, Monad
```

### Known Category Values

```
Funding Opportunity, Grant, DAO Governance, Award,
Program Results, Upcoming Deadline, Retroactive Funding,
Quadratic Funding, Ecosystem Fund, Developer Grant,
Research, Tool
```

## Natural Language → Query Parameters

| User says | Maps to |
|-----------|---------|
| "Ethereum programs" | `ecosystems=Ethereum` |
| "hackathons" | `type=hackathon` |
| "hackathons on Ethereum" | `type=hackathon&ecosystems=Ethereum` |
| "bounties on Solana" | `type=bounty&ecosystems=Solana` |
| "bounties over $500" | `type=bounty&minGrantSize=500` |
| "accelerator programs" | `type=accelerator` |
| "VCs investing in DeFi" | `type=vc_fund&name=DeFi` |
| "open RFPs from Optimism" | `type=rfp&organization=Optimism` |
| "grants and hackathons on Ethereum" | `type=grant,hackathon&ecosystems=Ethereum` |
| "DeFi funding on Optimism" | `ecosystems=Optimism&name=DeFi` |
| "programs over $50K" | `minGrantSize=50000` |
| "funding under $100K" | `maxGrantSize=100000` |
| "infrastructure" | `name=infrastructure` |
| "active programs" | `status=active` |
| "retroactive funding on Optimism" | `ecosystems=Optimism&categories=Retroactive Funding` |
| "programs on Karma" | `onlyOnKarma=true` |
| "what's closing this week" | `sortField=endsAt&sortOrder=asc&status=active` |
| (no query) | Ask what they're looking for |

Budget shorthand: K→000, M→000000 (e.g., $50K → 50000, $1M → 1000000).

## Query Defaults

Always include:

```
isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc
```

Override `sortField` and `sortOrder` when the user asks about deadlines — use `sortField=endsAt&sortOrder=asc`.

## Making the Request

Use `curl` via Bash to call the API. Build the URL from the mapped parameters:

```bash
curl -s "https://gapapi.karmahq.xyz/v2/program-registry/search?isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc&ecosystems=Ethereum"
```

Parse the JSON response and format results as described below.

## Result Format

Include the program type in each result. Adapt the detail line based on type:

```
Found 42 programs (showing top 10):

1. **Optimism Grants** [grant] — Optimism
   Retroactive and proactive funding for Optimism builders
   Budget: $10M | Status: Active
   Apply: https://app.charmverse.io/...

2. **ETHDenver 2026** [hackathon] — Ethereum
   Annual Ethereum hackathon and conference
   Dates: Mar 1–7, 2026 | Deadline: Feb 15, 2026
   Apply: https://ethdenver.com/apply

3. **Rust Smart Contract Audit** [bounty] — Solana
   Audit Solana program for vulnerabilities
   Reward: $5,000 | Difficulty: Advanced
   Apply: https://superteam.fun/...

Showing 10 of 42. Ask for more or narrow your search.
```

### Field Mapping

- **Name**: `metadata.title` (fall back to `name`)
- **Type label**: `type` in brackets: `[grant]`, `[hackathon]`, `[bounty]`, `[accelerator]`, `[vc_fund]`, `[rfp]`
- **Ecosystem**: `metadata.ecosystems` joined with `, ` (fall back to `communities[0].name`)
- **Description**: `metadata.description` truncated to ~120 chars

### Type-Specific Detail Line

- **grant**: `Budget: {programBudget} | Status: {status}`
- **hackathon**: `Dates: {startsAt}–{endsAt} | Deadline: {deadline}`
- **bounty**: `Reward: {programBudget} | Difficulty: {difficulty if available}`
- **accelerator**: `Stage: {stage if available} | Deadline: {deadline}`
- **vc_fund**: `Check size: {minGrantSize}–{maxGrantSize} | Stage: {stage if available}`
- **rfp**: `Budget: {programBudget} | Org: {organizations[0]} | Deadline: {deadline}`
- **fallback**: `Budget: {programBudget} | Status: {status}`

### Common Fields

- **Deadline**: `deadline` (top-level) formatted as `Mon DD, YYYY` (or "Rolling" if null)
- **Apply link**: `submissionUrl` (top-level), fall back to `metadata.socialLinks.grantsSite` or `metadata.website` or `metadata.socialLinks.website` (first non-empty)

## Edge Cases

| Scenario | Response |
|----------|----------|
| No results | "No programs found matching your criteria. Try broadening — remove type, ecosystem, or budget filters." |
| API error | "Could not reach the Karma API. Try again in a moment." |
| No query | Ask: "What kind of funding are you looking for? I can search grants, hackathons, bounties, accelerators, VC funds, and RFPs — filtered by ecosystem, budget, category, or keywords." |
| "more results" / "page 2" | Re-run with `page=2` |
