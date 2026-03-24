---
name: funding-program-manager
description: Create and manage funding programs on Karma — create programs in the registry, configure intake forms, apply to programs, manage reviewers, applications, milestones, payouts, grant agreements, and AI evaluation. Use when user says "create a program", "new funding program", "set up grants program", "configure intake form", "add form fields", "apply to program", "submit application", "apply for grant", "manage program", "list reviewers", "add reviewer", "remove reviewer", "review applications", "approve application", "reject application", "application status", "list applications", "milestone completions", "pending milestones", "create payout", "disbursement", "payout history", "grant agreement", "sign agreement", "evaluate application", "AI score", "application comment", "enable applications", "update program", or any funding program administration action.
version: 1.1.0
tags: [program, reviewer, application, milestone, payout, agreement, evaluation, admin]
metadata:
  author: Karma
  category: program-admin
---

# Funding Program Manager

Manage funding programs end-to-end on the Karma protocol: reviewers, applications, milestones, payouts, grant agreements, and AI evaluation.

Full API docs: `https://gapapi.karmahq.xyz/v2/docs/static/index.html`

```bash
BASE_URL="${KARMA_API_URL:-https://gapapi.karmahq.xyz}"
API_KEY="${KARMA_API_KEY}"
INVOCATION_ID=$(uuidgen)
```

**CRITICAL: Every authenticated `curl` call must include these headers** (public endpoints like "List Community Programs" do not require `x-api-key`):

```bash
-H "x-api-key: ${API_KEY}"
-H "X-Source: skill:funding-program-manager"
-H "X-Invocation-Id: $INVOCATION_ID"
-H "X-Skill-Version: 1.0.0"
```

---

## Setup

If `KARMA_API_KEY` is already set, skip to [Verify](#verify).

Otherwise use the `AskUserQuestion` tool with these options:

- Question: "You need a Karma API key to continue. How would you like to set it up?"
- Options: ["Quick start — Generate instantly (no account needed)", "Email login — Link to existing Karma account", "I already have a key"]

### Quick Start (No Account Needed)

```bash
curl -s -X POST "${BASE_URL}/v2/agent/register" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{}'
```

Returns `{ "apiKey": "karma_..." }` — shown only once.

**Important**: Always send `-d '{}'` — an empty body causes a 400 error.

### Email Login

1. Ask for email
2. `POST ${BASE_URL}/v2/api-keys/auth/init` with `{ "email": "..." }`
3. Ask for code → `POST ${BASE_URL}/v2/api-keys/auth/verify` with `{ "email": "...", "code": "...", "name": "claude-agent" }`
4. Returns `{ "key": "karma_..." }`

### Save API Key

After obtaining the key, save it automatically based on the environment:

**If `CLAUDE_PLUGIN_DATA` is set** (plugin user — CLI or Cowork):

```bash
mkdir -p "${CLAUDE_PLUGIN_DATA}"
echo '{"apiKey": "karma_..."}' > "${CLAUDE_PLUGIN_DATA}/credentials.json"
export KARMA_API_KEY="karma_..."
```

**If not set** (standalone CLI user): Ask to save to shell config:

```bash
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then SHELL_RC="$HOME/.bashrc"; fi
grep -q 'KARMA_API_KEY' "$SHELL_RC" 2>/dev/null && sed -i.bak 's/export KARMA_API_KEY=.*/export KARMA_API_KEY="karma_..."/' "$SHELL_RC" || echo '\n# Karma API Key\nexport KARMA_API_KEY="karma_..."' >> "$SHELL_RC"
export KARMA_API_KEY="karma_..."
```

### Verify

```bash
curl -s "${BASE_URL}/v2/agent/info" \
  -H "x-api-key: ${KARMA_API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

If response includes `walletAddress` → ready.

---

## 1. Program Lifecycle

Creating a program that accepts applications requires three steps:

1. **Create program** in the program registry (public listing)
2. **Create funding config** for that program (enables application management)
3. **Configure intake form** (defines the fields applicants fill out)

### Step 1: Create Program in Registry

Creates a new program in the public program registry.

```bash
curl -s -X POST "${BASE_URL}/v2/program-registry" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "metadata": {
      "title": "My Grants Program",
      "description": "Fund public goods builders...",
      "communityRef": "COMMUNITY_UID",
      "socialLinks": { "grantsSite": "https://example.com/apply" },
      "adminEmails": ["admin@example.com"],
      "financeEmails": ["finance@example.com"],
      "currency": "USDC",
      "programBudget": "500000",
      "startsAt": "2026-04-01",
      "endsAt": "2026-12-31"
    },
    "type": "grant",
    "deadline": "2026-06-30",
    "submissionUrl": "https://example.com/apply"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `metadata.title` | Yes | Program name |
| `metadata.description` | Yes | Program description |
| `metadata.communityRef` | Yes | Community UID (string or array) |
| `metadata.socialLinks.grantsSite` | Yes | URL to the grants/application site |
| `metadata.adminEmails` | Yes (for community admins) | Admin contact emails |
| `metadata.financeEmails` | Yes (for community admins) | Finance contact emails |
| `metadata.currency` | No | Funding currency (e.g. "USDC", "OP") |
| `metadata.programBudget` | No | Total budget amount |
| `metadata.shortDescription` | No | Short summary (max 100 chars) |
| `metadata.startsAt` | No | Program start date |
| `metadata.endsAt` | No | Program end date |
| `metadata.anyoneCanJoin` | No | Whether anyone can apply |
| `metadata.invoiceRequired` | No | Whether invoice is required |
| `type` | No | `grant` (default), `hackathon`, `bounty`, `accelerator`, `vc_fund`, `rfp` |
| `deadline` | No | Application deadline (date string) |
| `submissionUrl` | No | External application URL |
| `chainID` | No | Blockchain ID |

Returns the created program with `programId`. Save it for the next steps.

#### Gathering Program Information

When the user wants to create a program, present the required and key optional fields:

> To create your funding program, I'll need the following. **Title**, **description**, **community**, **grants site URL**, and **contact emails** are required:
>
> - **Title**: Program name
> - **Description**: What does this program fund?
> - **Community**: Which community is this for?
> - **Grants Site URL**: Where do applicants go?
> - **Admin Emails**: Admin contact email(s)
> - **Finance Emails**: Finance contact email(s)
> - **Type**: Grant / Hackathon / Bounty / Accelerator / VC Fund / RFP (default: Grant)
> - **Budget**: Total program budget
> - **Currency**: Funding currency (e.g. USDC, OP)
> - **Deadline**: Application deadline
> - **Start / End Dates**: Program duration

### Step 2: Create Funding Config

After the program exists in the registry, create its funding configuration to enable application management.

```bash
curl -s -X POST "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "isEnabled": true,
    "formSchema": null,
    "reviewers": []
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `isEnabled` | No | Enable applications (default: false) |
| `formSchema` | No | Intake form schema (null = no form yet, configure in Step 3) |
| `postApprovalFormSchema` | No | Post-approval form schema |
| `kycFormUrl` | No | KYC form URL |
| `kybFormUrl` | No | KYB form URL |
| `reviewers` | No | Initial reviewers array |

### Step 3: Configure Intake Form

Define the fields applicants must fill out. The form must contain at least one email field.

```bash
curl -s -X PUT "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "formSchema": {
      "fields": [
        {
          "id": "field_email",
          "label": "Contact Email",
          "type": "email",
          "required": true,
          "placeholder": "your@email.com"
        },
        {
          "id": "field_project_name",
          "label": "Project Name",
          "type": "text",
          "required": true,
          "placeholder": "Your project name"
        },
        {
          "id": "field_description",
          "label": "Project Description",
          "type": "textarea",
          "required": true,
          "description": "Describe what your project does and its impact"
        },
        {
          "id": "field_funding_amount",
          "label": "Requested Funding",
          "type": "number",
          "required": true,
          "placeholder": "50000"
        },
        {
          "id": "field_category",
          "label": "Category",
          "type": "select",
          "required": false,
          "options": [
            { "value": "defi", "label": "DeFi" },
            { "value": "infrastructure", "label": "Infrastructure" },
            { "value": "public-goods", "label": "Public Goods" }
          ]
        }
      ]
    }
  }'
```

Each field in `formSchema.fields`:

| Property | Required | Description |
|----------|----------|-------------|
| `id` | Yes | Unique field ID (e.g. `field_email`, `field_name`) |
| `label` | Yes | Display label — also used as key in application data |
| `type` | Yes | `text`, `textarea`, `number`, `email`, `url`, `select` |
| `required` | No | Whether the field is mandatory (default: false) |
| `placeholder` | No | Placeholder text |
| `description` | No | Help text shown below the field |
| `options` | For `select` | Array of `{ value, label }` |

**Important**: The form must include at least one `email` type field for application tracking.

#### After Full Setup

> Your program is live and ready to accept applications!
>
> - **Program**: {title}
> - **Program ID**: {programId}
> - **Applications**: {isEnabled ? "Enabled" : "Disabled"}
> - **Form Fields**: {fieldCount} fields configured
>
> Next steps: Add reviewers, or share the application link with potential applicants.

---

## 2. Program Management

### Get Program Details

```bash
curl -s "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### List Community Programs

```bash
curl -s "${BASE_URL}/v2/funding-program-configs/community/${COMMUNITY_UID}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

No auth required — public endpoint.

### Update Program in Registry

Update program metadata in the program registry.

```bash
curl -s -X PUT "${BASE_URL}/v2/program-registry/${PROGRAM_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "metadata": {
      "title": "Updated Program Name",
      "description": "Updated description...",
      "communityRef": "COMMUNITY_UID",
      "socialLinks": { "grantsSite": "https://example.com/apply" }
    }
  }'
```

**Important**: Fetch current program details first and merge changes — the update replaces metadata fields.

### Update Funding Config

Update the funding configuration (enable/disable applications, update forms).

```bash
curl -s -X PUT "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "isEnabled": true,
    "formSchema": { ... },
    "postApprovalFormSchema": { ... }
  }'
```

### Generate Program Report (Application Statistics)

```bash
curl -s "${BASE_URL}/v2/funding-applications/program/${PROGRAM_ID}/statistics" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

---

## 3. Application Management

### List Applications for a Program

```bash
curl -s "${BASE_URL}/v2/funding-applications/program/${PROGRAM_ID}?page=1&limit=20&status=${STATUS}&search=${SEARCH}&sortBy=createdAt&sortOrder=desc" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Query params (all optional):

| Param | Values |
|-------|--------|
| `status` | `pending`, `under_review`, `approved`, `rejected`, `revision_requested`, `resubmitted` |
| `search` | Search by email, reference number, or project title |
| `sortBy` | `createdAt`, `updatedAt`, `status`, `applicantEmail`, `referenceNumber`, `projectTitle`, `aiEvaluationScore` |
| `sortOrder` | `asc`, `desc` |
| `page` | Page number (default: 1) |
| `limit` | Items per page (default: 20, max: 100) |

### Get Application Details

```bash
curl -s "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Reference number format: `APP-XXXXX-XXXXX`

### Update Application Status

```bash
curl -s -X PUT "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/status" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "status": "approved",
    "reason": "Strong proposal with clear milestones",
    "approvedAmount": "50000",
    "approvedCurrency": "USDC"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `pending`, `under_review`, `approved`, `rejected`, `revision_requested` |
| `reason` | No | Reason for the status change |
| `approvedAmount` | When approving | Amount approved (positive number as string) |
| `approvedCurrency` | When approving | Currency (e.g. "USDC", "OP", "USD") |

---

## 4. Apply to a Funding Program

Applying requires knowing the program's form fields first. Always fetch the form schema before asking the user for input.

### Step 1: Get the Intake Form

```bash
curl -s "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Look at `applicationConfig.formSchema.fields` in the response. Each field has:

| Property | Description |
|----------|-------------|
| `id` | Internal field ID |
| `label` | Display label — **use this as the key in applicationData** |
| `type` | `text`, `textarea`, `number`, `email`, `url`, `select` |
| `required` | Whether the field must be filled |
| `placeholder` | Hint text |
| `description` | Help text |
| `options` | For `select` fields: `[{ value, label }]` |

Skip fields with `deleted: true`.

### Step 2: Gather Answers from the User

Present the form fields to the user and collect their answers. Example prompt:

> To apply to **{programName}**, please provide the following:
>
> - **Project Name** (required): Your project's name
> - **Description** (required): What does your project do?
> - **Funding Amount**: How much are you requesting?
> - **Team Size**: Number of team members
>
> You'll also need your **email address** for application tracking.

### Step 3: Get AI Feedback (Optional)

Check if the program has real-time AI evaluation enabled by looking at `applicationConfig.formSchema.aiConfig.enableRealTimeEvaluation` in the program config from Step 1.

If **enabled**, call the evaluate-realtime endpoint with the user's answers:

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${PROGRAM_ID}/evaluate-realtime" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "applicationData": {
      "Project Name": "My DeFi Protocol",
      "Description": "A decentralized lending platform..."
    }
  }'
```

**Response**:

```json
{
  "success": true,
  "data": { "score": 8, "decision": "approve", "strengths": [...], "concerns": [...] },
  "promptId": "prompt-123"
}
```

Show the AI feedback to the user:

> **AI Feedback** (score: {score}/10 — {decision})
>
> **Strengths**: {strengths}
> **Concerns**: {concerns}
>
> *This AI review is for guidance only and may not be fully accurate.*
>
> Would you like to revise your answers or proceed to submit?

If the user wants to revise, go back to Step 2. If they want to proceed, save the evaluation for Step 5.

**If not enabled or evaluation fails**: Skip this step — the user can still submit without AI feedback.

### Step 4: Validate Access Code (If Gated)

Some programs require an access code. Check if `applicationConfig.formSchema.settings.accessCode` exists in the program config. If so, ask the user for it and validate:

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${PROGRAM_ID}/validate-access-code" \
  -H "Content-Type: application/json" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{ "accessCode": "user-provided-code" }'
```

No auth required for validation.

### Step 5: Submit the Application

**IMPORTANT**: The `applicationData` keys must be the **field labels** (not field IDs). This matches how the frontend stores form data.

If AI evaluation was performed in Step 3, include the `aiEvaluation` field with the stringified result:

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${PROGRAM_ID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "applicantEmail": "applicant@example.com",
    "applicationData": {
      "Project Name": "My DeFi Protocol",
      "Description": "A decentralized lending platform...",
      "Funding Amount": "50000",
      "Team Size": "5"
    },
    "aiEvaluation": {
      "evaluation": "{\"score\": 8, \"decision\": \"approve\", ...}",
      "promptId": "prompt-123"
    },
    "accessCode": "optional-code"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `applicantEmail` | Yes | Applicant's email (used for notifications) |
| `applicationData` | Yes | Form responses keyed by **field label** |
| `aiEvaluation` | No | `{ evaluation: "<stringified result>", promptId }` from Step 3 |
| `accessCode` | If gated | Access code for gated programs |

**Response** (201 Created):

```json
{
  "referenceNumber": "APP-ABCD1234-XYZ789",
  "status": "pending",
  "programId": "...",
  "applicantEmail": "applicant@example.com",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

After submission:

> Your application has been submitted!
>
> - **Reference**: {referenceNumber}
> - **Program**: {programName}
> - **Status**: Pending
>
> You'll receive updates at {applicantEmail}.

---

## 5. Program Reviewers

### List Program Reviewers

```bash
curl -s "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Add Program Reviewer

```bash
curl -s -X POST "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "name": "Alice Smith",
    "email": "alice@example.com",
    "telegram": "@alice_reviews"
  }'
```

### Remove Program Reviewer

```bash
curl -s -X DELETE "${BASE_URL}/v2/funding-program-configs/${PROGRAM_ID}/reviewers/by-email" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{ "email": "alice@example.com" }'
```

---

## 6. Milestone Reviewers

### List Milestone Reviewers

```bash
curl -s "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Add Milestone Reviewer

```bash
curl -s -X POST "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "name": "Bob Jones",
    "email": "bob@example.com",
    "telegram": "@bob_milestones"
  }'
```

### Remove Milestone Reviewer

```bash
curl -s -X DELETE "${BASE_URL}/v2/programs/${PROGRAM_ID}/milestone-reviewers/by-email" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{ "email": "bob@example.com" }'
```

---

## 7. Application Reviewer Assignment

### Assign Reviewers to Application

```bash
curl -s -X PUT "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/reviewers" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "appReviewerAddresses": ["0x1234..."],
    "milestoneReviewerAddresses": ["0x5678..."]
  }'
```

Both arrays are optional — provide at least one. Addresses must be valid Ethereum addresses (lowercase).

---

## 8. Milestone Completions

### List Milestone Completions for an Application

```bash
curl -s "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/milestone-completions" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Returns completions with `isVerified`, `verifiedBy`, `verifiedAt`, and `verificationComment` fields.

---

## 9. Payout Disbursements

### Create Disbursement Batch

```bash
curl -s -X POST "${BASE_URL}/v2/payouts/disburse" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "communityUID": "community-uid",
    "chainID": 10,
    "safeAddress": "0xsafe...",
    "token": "USDC",
    "tokenAddress": "0xtoken...",
    "tokenDecimals": 6,
    "grants": [
      {
        "grantUID": "grant-uid",
        "projectUID": "project-uid",
        "amount": "5000",
        "payoutAddress": "0xrecipient..."
      }
    ]
  }'
```

All addresses must be valid Ethereum addresses (lowercase, `0x` + 40 hex chars).

### Get Payout History for a Grant

```bash
curl -s "${BASE_URL}/v2/payouts/grant/${GRANT_UID}/history?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Get Total Disbursed for a Grant

```bash
curl -s "${BASE_URL}/v2/payouts/grant/${GRANT_UID}/total-disbursed" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### List Pending Disbursements

```bash
curl -s "${BASE_URL}/v2/payouts/community/${COMMUNITY_UID}/pending?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### List Disbursements Awaiting Safe Signatures

```bash
curl -s "${BASE_URL}/v2/payouts/safe/${SAFE_ADDRESS}/awaiting?page=1&limit=20" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

---

## 10. Grant Agreements

### Get Grant Agreement

```bash
curl -s "${BASE_URL}/v2/grant-agreements/${GRANT_UID}" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Toggle Grant Agreement (Sign/Unsign)

```bash
curl -s -X POST "${BASE_URL}/v2/grant-agreements/${GRANT_UID}" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "signed": true,
    "communityUID": "community-uid"
  }'
```

---

## 11. AI Evaluation

### Trigger Public AI Evaluation

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/evaluate" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

No request body — evaluation uses the application's existing data.

### Trigger Internal AI Evaluation (Admin-Only)

```bash
curl -s -X POST "${BASE_URL}/v2/funding-applications/${REFERENCE_NUMBER}/evaluate-internal" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

Internal evaluations are only visible to program admins.

---

## 12. Application Comments

### List Comments (Admin)

```bash
curl -s "${BASE_URL}/v2/applications/${REFERENCE_NUMBER}/comments?admin=true" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0"
```

### Add Comment

```bash
curl -s -X POST "${BASE_URL}/v2/applications/${REFERENCE_NUMBER}/comments" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${API_KEY}" \
  -H "X-Source: skill:funding-program-manager" -H "X-Invocation-Id: $INVOCATION_ID" -H "X-Skill-Version: 1.0.0" \
  -d '{
    "content": "This application looks promising. Strong team and clear deliverables.",
    "authorName": "Program Admin"
  }'
```

| Param | Required | Description |
|-------|----------|-------------|
| `content` | Yes | Comment text (1-10000 chars) |
| `authorName` | No | Display name (max 100 chars) |

---

## Natural Language Mapping

| User says | Action |
|-----------|--------|
| "create a program", "new funding program", "set up a grants program" | Create program in registry → create funding config → configure intake form |
| "configure intake form", "add form fields", "set up application form" | Configure intake form fields |
| "update program", "rename program", "change program description" | Update program in registry (fetch current details first, merge changes) |
| "enable applications", "disable applications" | Update funding config `isEnabled` |
| "list reviewers", "who reviews this program" | List program reviewers |
| "add reviewer", "invite reviewer" | Add program reviewer |
| "remove reviewer" | Remove program reviewer by email |
| "list milestone reviewers" | List milestone reviewers |
| "add milestone reviewer" | Add milestone reviewer |
| "remove milestone reviewer" | Remove milestone reviewer |
| "assign reviewers to application" | Assign application reviewers |
| "apply to program", "submit application", "apply for grant" | Get form → collect answers → AI feedback → submit |
| "what fields does this program need" | Get program application form schema |
| "get AI feedback", "score my application", "evaluate my draft" | Run real-time AI evaluation on draft answers |
| "list applications", "show applications" | List applications for program |
| "application details", "show application" | Get application by reference |
| "approve application" | Update status to `approved` (requires amount + currency) |
| "reject application" | Update status to `rejected` |
| "request revision" | Update status to `revision_requested` |
| "milestone completions", "show milestones" | List milestone completions |
| "pending milestones", "unverified milestones" | List milestone completions, filter by `isVerified: false` |
| "create payout", "disburse funds" | Create disbursement batch |
| "payout history" | Get payout history for grant |
| "total disbursed", "how much paid" | Get total disbursed |
| "pending payouts" | List pending disbursements |
| "awaiting signatures" | List disbursements awaiting Safe signatures |
| "grant agreement", "agreement status" | Get grant agreement |
| "sign agreement", "mark agreement signed" | Toggle agreement to signed |
| "evaluate application", "AI score" | Trigger public AI evaluation |
| "internal evaluation", "admin AI score" | Trigger internal AI evaluation |
| "add comment", "leave note" | Add application comment |
| "show comments", "list comments" | List application comments |
| "program stats", "application statistics" | Get program report |
| "program details", "show program" | Get program details |
| "community programs", "list programs" | List community programs |

---

## Error Handling

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Bad params | Show error, help fix |
| 401 | Invalid API key | Tell user to check `KARMA_API_KEY` or run setup |
| 403 | Insufficient permissions | User lacks the required role for this program |
| 404 | Not found | Check reference number or program ID |
| 429 | Rate limited (60/min) | Wait and retry |
| 500 | Server error | Retry once, then report |

## Edge Cases

| Scenario | Response |
|----------|----------|
| Missing required field | Ask user for it |
| API key not set | Run setup flow |
| Need reference number but user gave name | Search applications by name/email |
| Approving without amount | Ask for approved amount and currency |
| Multiple programs in community | Show list, ask which one |
| Reviewer already exists | Show the 409 error message |
| Ethereum address not lowercase | Normalize to lowercase before sending |
| "Create a program" | Full 3-step flow: create in registry → create funding config → configure intake form |
| Intake form has no email field | Reject — form must have at least one email field for tracking |
| Program limit exceeded (409) | Community already has a program — non-staff users are limited to 1 per community |
| Update program without fetching first | Always fetch current details and merge — PUT replaces metadata |
