---
name: program-manager
description: Administer a Karma funding program — manage reviewers, track milestones, disburse payouts, handle grant agreements, and trigger AI evaluations.
version: 1.0.0
tags: [agent, program, admin, reviewers, milestones, payouts, grants, evaluation]
metadata:
  author: Karma
  category: administration
---

# Program Manager

Administer a Karma funding program end-to-end: manage reviewers, oversee milestones, disburse payouts, handle grant agreements, and trigger AI evaluations.

Full API docs: `https://gapapi.karmahq.xyz/v2/docs/static/index.html`

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
API_KEY="${KARMA_API_KEY}"
INVOCATION_ID=$(uuidgen)
```

**CRITICAL: Every `curl` call must include these headers:**

```bash
-H "x-api-key: ${API_KEY}" \
-H "Content-Type: application/json" \
-H "X-Source: skill:program-manager" \
-H "X-Invocation-Id: $INVOCATION_ID" \
-H "X-Skill-Version: 1.0.0"
```

---

## Setup

If `KARMA_API_KEY` is already set, skip to [Verify](#verify).

Otherwise, run the `setup-agent` skill or ask:

- **Quick start**: `POST ${BASE_URL}/v2/agent/register` with `-d '{}'` — returns `{ "apiKey": "karma_..." }`
- **Email login**: `POST ${BASE_URL}/v2/api-keys/auth/init` then `POST ${BASE_URL}/v2/api-keys/auth/verify`
- **Paste existing key**: User provides `karma_...`

Save to shell config after asking permission.

### Verify

```bash
curl -s "${BASE_URL}/v2/agent/info" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

If response includes `walletAddress` — ready.

> Your Karma agent is ready! You can now manage programs, reviewers, payouts, and more.

---

## 1. Reviewer Management

### List Program Reviewers

```bash
curl -s "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns array of reviewers with `publicAddress`, `userProfile` (name, email, telegram).

### Add Program Reviewer

```bash
curl -s -X POST "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "name": "Alice",
    "email": "alice@example.com",
    "telegram": "@alice"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Reviewer display name |
| `email` | Yes | Valid email address |
| `telegram` | No | Telegram handle |

### Remove Program Reviewer

```bash
curl -s -X DELETE "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers/by-email" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{ "email": "alice@example.com" }'
```

### List Milestone Reviewers

```bash
curl -s "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Add Milestone Reviewer

```bash
curl -s -X POST "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "name": "Bob",
    "email": "bob@example.com"
  }'
```

### Remove Milestone Reviewer

```bash
curl -s -X DELETE "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers/by-email" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{ "email": "bob@example.com" }'
```

### Assign Reviewers to Application

Assign application reviewers, milestone reviewers, or both to a specific application. Provide at least one array. An empty array clears that reviewer type; omitting a field preserves existing assignments.

```bash
curl -s -X PUT "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "appReviewerAddresses": ["0xReviewer1...", "0xReviewer2..."],
    "milestoneReviewerAddresses": ["0xMileReviewer1..."]
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `appReviewerAddresses` | At least one field | Ethereum addresses of application reviewers |
| `milestoneReviewerAddresses` | At least one field | Ethereum addresses of milestone reviewers |

---

## 2. Milestone Management

### List Milestone Completions

```bash
curl -s "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/milestone-completions" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns array of completions with `id`, `milestoneFieldLabel`, `milestoneTitle`, `completionText`, `isVerified`, `verifiedBy`, `verifiedAt`.

### Get Specific Milestone Completion

```bash
curl -s "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/milestone-completions/${MILESTONE_FIELD_LABEL}/${MILESTONE_TITLE}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

**Note**: URL-encode `MILESTONE_FIELD_LABEL` and `MILESTONE_TITLE` if they contain spaces or special characters.

---

## 3. Payout & Disbursement

### Create Disbursement Batch

Create payout disbursements for one or more grants. This creates a Safe multisig transaction proposal — the human admin must sign it in the Safe wallet.

```bash
curl -s -X POST "${BASE_URL}/v2/payouts/disburse" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "communityUID": "community-uid-here",
    "chainID": 10,
    "safeAddress": "0xSafeAddress...",
    "token": "USDC",
    "tokenAddress": "0xTokenAddress...",
    "tokenDecimals": 6,
    "grants": [
      {
        "grantUID": "grant-uid-1",
        "projectUID": "project-uid-1",
        "amount": "5000",
        "payoutAddress": "0xRecipient..."
      }
    ]
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `communityUID` | Yes | Community UID |
| `chainID` | Yes | Blockchain chain ID |
| `safeAddress` | Yes | Safe multisig wallet address |
| `token` | Yes | Token symbol (e.g. "USDC") |
| `tokenAddress` | Yes | Token contract address |
| `tokenDecimals` | Yes | Token decimals (0-18) |
| `grants` | Yes | Array of grant disbursements (min 1) |
| `grants[].grantUID` | Yes | Grant UID |
| `grants[].projectUID` | Yes | Project UID |
| `grants[].amount` | Yes | Amount to disburse |
| `grants[].payoutAddress` | Yes | Recipient wallet address |
| `grants[].milestoneBreakdown` | No | Map of milestone UID to amount |
| `grants[].paidAllocationIds` | No | Milestone allocation IDs being paid |

**Important**: After creation, the disbursement enters `PENDING` status. The Safe transaction must be signed by the required number of Safe owners before funds are released.

### Get Payout History

```bash
curl -s "${BASE_URL}/v2/payouts/grant/${GRANT_UID}/history?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Get Total Disbursed

```bash
curl -s "${BASE_URL}/v2/payouts/grant/${GRANT_UID}/total-disbursed" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### List Pending Disbursements

```bash
curl -s "${BASE_URL}/v2/payouts/community/${COMMUNITY_UID}/pending?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### List Awaiting Safe Signatures

```bash
curl -s "${BASE_URL}/v2/payouts/safe/${SAFE_ADDRESS}/awaiting?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

---

## 4. Grant Agreements

### Get Agreement Status

```bash
curl -s "${BASE_URL}/v2/grant-agreements/${GRANT_UID}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns agreement object with `signed`, `signedBy`, `signedAt` — or null if no agreement exists.

### Toggle Agreement Signed Status

```bash
curl -s -X POST "${BASE_URL}/v2/grant-agreements/${GRANT_UID}" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "signed": true,
    "communityUID": "community-uid-here"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `signed` | Yes | `true` to mark as signed, `false` to unsign |
| `communityUID` | Yes | Community UID |
| `signedAt` | No | ISO 8601 datetime (defaults to now) |

---

## 5. AI Evaluation

### Trigger Public AI Evaluation

Run an AI evaluation on an application. The result is publicly visible.

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/evaluate" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns `{ evaluation, promptId, updatedAt }`.

### Trigger Internal AI Evaluation

Run an internal evaluation visible only to admins.

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/evaluate-internal" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns `{ evaluation, promptId, status, updatedAt }`.

---

## Looking Up Data

### List Programs for a Community

```bash
curl -s "${BASE_URL}/communities/${COMMUNITY_SLUG_OR_UID}/programs" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Each program has: `programId`, `metadata.title`

### List Applications for a Program

```bash
curl -s "${BASE_URL}/v2/funding-applications?programId=${PROGRAM_ID}&page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Optional query params: `status` (pending, under_review, approved, rejected), `search`, `sortBy`, `sortOrder`.

### Get Application Details

```bash
curl -s "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

---

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "list reviewers", "show reviewers", "who reviews" | List program reviewers |
| "add reviewer", "invite reviewer" | Add program reviewer |
| "remove reviewer", "delete reviewer" | Remove program reviewer by email |
| "add milestone reviewer" | Add milestone reviewer |
| "assign reviewers to application" | Assign reviewers to application |
| "show milestones", "milestone status" | List milestone completions |
| "pending milestones", "what needs review" | List milestone completions (filter unverified) |
| "create payout", "disburse funds", "pay grants" | Create disbursement batch |
| "payout history", "disbursement history" | Get payout history |
| "how much paid", "total disbursed" | Get total disbursed |
| "pending payouts", "pending disbursements" | List pending disbursements |
| "awaiting signatures", "needs signing" | List awaiting Safe signatures |
| "agreement status", "is grant signed" | Get grant agreement |
| "mark agreement signed", "sign grant" | Toggle agreement to signed |
| "evaluate application", "run AI review" | Trigger public AI evaluation |
| "internal evaluation", "admin AI review" | Trigger internal AI evaluation |

---

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Bad params | Show error, help fix |
| 401 | Invalid API key | Tell user to check `KARMA_API_KEY` or run setup |
| 403 | Insufficient permissions | User lacks the required role for this program |
| 404 | Resource not found | Check program ID, reference number, or grant UID |
| 429 | Rate limited (60/min) | Wait and retry |
| 500 | Server error | Retry once, then report |

## Edge Cases

| Scenario | Response |
|----------|----------|
| Missing API key | Run setup flow |
| Unknown program ID | Search communities, then list programs |
| Need reference number but user gave project name | Search applications by project title |
| Payout amount exceeds grant approved amount | Show error, ask to adjust |
| Agreement already in desired state | Confirm current state, no action needed |
| Multiple programs in community | Show list, ask which one |
| Reviewer already exists | Show existing reviewers, skip duplicate |
