---
name: find-programs
description: Search the Karma Funding Map for funding programs (grants, hackathons, bounties, accelerators, VC funds, RFPs) via the public API. Use when user says "find programs", "search grants", "funding opportunities", "hackathons", "bounties", or asks about ecosystem funding.
version: 0.1.0
tags: [agent, programs, search, funding]
metadata:
  author: Karma
  category: discovery
---

# Funding Program Finder

Search the Karma Funding Map for funding programs via the public API. No API key required.

See [Funding API Reference](../references/funding-api.md) for full query parameters, response shape, and field mappings.

## Program Types

The registry has 6 types: grants, hackathons, bounties, accelerators, VC funds, and RFPs. Use "programs" / "opportunities" / "funding" — not just "grants".

## Natural Language Mapping

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
| "active programs" | `status=active` |
| "what's closing this week" | `sortField=endsAt&sortOrder=asc&status=active` |
| (no query) | Ask what they're looking for |

Budget shorthand: K→000, M→000000 (e.g., $50K → 50000, $1M → 1000000).

## Making the Request

Always include defaults: `isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc`

Override sort when user asks about deadlines: `sortField=endsAt&sortOrder=asc`

```bash
curl -s "https://gapapi.karmahq.xyz/v2/program-registry/search?isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc&ecosystems=Ethereum"
```

**URL encoding:** Percent-encode values with spaces (e.g., `Retroactive%20Funding`).

## Result Format

```
Found 42 programs (showing top 10):

1. **Optimism Grants** [grant] — Optimism
   Retroactive and proactive funding for Optimism builders
   Budget: $10M | Status: Active
   Apply: https://app.charmverse.io/...

Showing 10 of 42. Ask for more or narrow your search.
```

See [Funding API Reference](../references/funding-api.md) for type-specific detail lines and field mappings.

## Edge Cases

| Scenario | Response |
|----------|----------|
| No results | "No programs found. Try broadening — remove type, ecosystem, or budget filters." |
| API error | "Could not reach the Karma API. Try again in a moment." |
| No query | Ask: "What kind of funding are you looking for? I can search grants, hackathons, bounties, accelerators, VC funds, and RFPs." |
| "more results" / "page 2" | Re-run with `page=2` |
