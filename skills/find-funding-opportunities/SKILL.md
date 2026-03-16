---
name: find-funding-opportunities
description: Search the Karma Funding Map for funding programs (grants, hackathons, bounties, accelerators, VC funds, RFPs) via the public API. Use when user says "find grants", "search hackathons", "look for bounties", "explore funding", "programs on Optimism", "what can I apply to", "funding opportunities", or asks about programs over or under a budget.
version: 1.3.0
tags: [programs, search, funding, discovery]
metadata: {"author": "Karma", "category": "discovery"}
---

# Funding Program Finder

Search the Karma Funding Map for funding programs via the public API.

6 program types: grants, hackathons, bounties, accelerators, VC funds, and RFPs. Use "programs" / "opportunities" / "funding" — not just "grants".

For full API parameters and response shape, see [references/api-reference.md](references/api-reference.md).

## Step 1: Map the User's Request

| User says | Maps to |
|-----------|---------|
| "Ethereum programs" | ecosystem query for `Ethereum` |
| "hackathons" | `type=hackathon` |
| "hackathons on Ethereum" | `type=hackathon` + ecosystem query |
| "bounties on Solana" | `type=bounty` + ecosystem query |
| "bounties over $500" | `type=bounty&minGrantSize=500` |
| "VCs investing in DeFi" | `type=vc_fund&name=DeFi` |
| "open RFPs from Optimism" | `type=rfp&organization=Optimism` |
| "grants and hackathons on Ethereum" | `type=grant,hackathon` + ecosystem query |
| "programs over $50K" | `minGrantSize=50000` |
| "funding under $100K" | `maxGrantSize=100000` |
| "active programs" | `status=active` |
| "retroactive funding on Optimism" | `categories=Retroactive%20Funding` + ecosystem query |
| "programs on Karma" | `onlyOnKarma=true` |
| "what's closing this week" | `sortField=endsAt&sortOrder=asc&status=active` |
| (no query) | Ask what they're looking for |

Budget shorthand: K→000, M→000000. URL-encode spaces: `categories=Retroactive%20Funding`.

## Step 2: Execute the Query

**CRITICAL: Every request must include tracking headers. Never omit them.**

### Non-ecosystem queries (single request)

```bash
INVOCATION_ID=$(uuidgen)
H=(-H "X-Source: skill:find-funding-opportunities" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.3.0")
BASE="https://gapapi.karmahq.xyz/v2/program-registry/search?isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc"

curl -s "${H[@]}" "${BASE}&type=hackathon"
```

### Ecosystem queries (parallel — single bash call)

Many programs lack the `ecosystems` metadata field and are only linked via `communities`. To get complete results, run the community lookup and all search queries **in parallel in a single bash call**, then merge.

```bash
INVOCATION_ID=$(uuidgen)
H=(-H "X-Source: skill:find-funding-opportunities" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.3.0")
BASE="https://gapapi.karmahq.xyz/v2/program-registry/search?isValid=accepted&limit=10&sortField=updatedAt&sortOrder=desc"
EXTRA=""  # append user filters: &type=grant, &minGrantSize=50000, etc.
NAME="Ethereum"  # the ecosystem the user asked for

# Run community lookup + ecosystems + name queries in parallel
curl -s "${H[@]}" "https://gapapi.karmahq.xyz/v2/communities?limit=100" > /tmp/kf_communities.json &
curl -s "${H[@]}" "${BASE}${EXTRA}&ecosystems=${NAME}" > /tmp/kf_eco.json &
curl -s "${H[@]}" "${BASE}${EXTRA}&name=${NAME}" > /tmp/kf_name.json &
wait

# Resolve community UID and fetch by communityUid
COMMUNITY_UID=$(python3 -c "
import json
data = json.load(open('/tmp/kf_communities.json'))
name = '${NAME}'.lower()
for c in data.get('payload', []):
    if name in c.get('details', {}).get('name', '').lower():
        print(c['uid']); break
" 2>/dev/null)

if [ -n "$COMMUNITY_UID" ]; then
  curl -s "${H[@]}" "${BASE}${EXTRA}&communityUid=${COMMUNITY_UID}" > /tmp/kf_com.json
else
  echo '{"programs":[]}' > /tmp/kf_com.json
fi

# Merge and deduplicate by id
python3 -c "
import json
seen = {}
for f in ['/tmp/kf_eco.json', '/tmp/kf_com.json', '/tmp/kf_name.json']:
    try:
        for p in json.load(open(f)).get('programs', []):
            seen[p['id']] = p
    except: pass
result = list(seen.values())
print(json.dumps({'programs': result, 'count': len(result)}, indent=2))
"
```

Replace `{NAME}` / `${NAME}` with the ecosystem the user asked for. The community lookup, ecosystems query, and name query all run simultaneously — the only sequential step is the communityUid query after resolving the UID (~1 extra API call). This keeps the community list fresh while cutting total wall time in half vs. the old sequential approach.

## Step 3: Format Results

```
Found {count} programs (showing top 10):

1. **{title}** [{type}] — {ecosystems}
   {description, ~120 chars}
   {detail line} | Deadline: {deadline or "Rolling"}
   Apply: {submissionUrl}

Showing 10 of {count}. Ask for more or narrow your search.
```

**Field mapping:**
- **Name**: `metadata.title` (fall back to `name`)
- **Type**: `type` in brackets: `[grant]`, `[hackathon]`, `[bounty]`, `[accelerator]`, `[vc_fund]`, `[rfp]`
- **Ecosystem**: `metadata.ecosystems` joined with `, ` (fall back to `communities[0].name`)
- **Deadline**: `deadline` formatted as `Mon DD, YYYY` (or "Rolling" if null)
- **Apply link**: `submissionUrl`, fall back to `metadata.socialLinks.grantsSite` or `metadata.website`

**Type-specific detail:**
- **grant**: `Budget: {programBudget} | Status: {status}`
- **hackathon**: `Dates: {startsAt}–{endsAt}`
- **bounty**: `Reward: {programBudget}`
- **accelerator**: `Stage: {stage if available}`
- **vc_fund**: `Check size: {minGrantSize}–{maxGrantSize}`
- **rfp**: `Budget: {programBudget} | Org: {organizations[0]}`

## Edge Cases

| Scenario | Action |
|----------|--------|
| No results | Broaden filters one at a time (remove type, then budget, then keyword). If ecosystem query: results were already merged from 3 sources. Report "No programs found — try broadening." |
| No query | Ask: "What kind of funding are you looking for? I can search grants, hackathons, bounties, accelerators, VC funds, and RFPs — by ecosystem, budget, category, or keywords." |
| "more results" / "page 2" | Re-run with `page=2` |
| Missing fields | "N/A" for budget, "Rolling" for deadline, skip missing description. Never fail on missing optional fields. |
| API error (5xx/timeout) | "The Karma API is temporarily unavailable. Try again in a moment." |
