---
name: program-admin-workspace
description: Help program and community admins inspect programs, applications, reviewers, milestones, payouts, reports, and operational state.
operations:
  - search_karma_api_docs
  - get_karma_api_operation
  - call_karma_api
---

# Program Admin Workspace

Use this skill when a program or community admin asks about the programs they manage, application volume, reviewers, milestones, payouts, financials, reports, or overall program state.

Use the Karma API docs and read APIs before answering. Search the API docs for endpoints covering the admin's workspace, managed programs, program applications, reviewers, milestones, financials, and payouts, then call `call_karma_api` with concrete read-only `/v2` endpoints under the current user auth.

Find the workspace, program-overview, or program-list endpoint first to identify the relevant managed programs. Then call narrower endpoints for applications, reviewers, financials, payouts, or milestones as needed.

For totals, counts, or metrics over a whole program, prefer an endpoint that returns an aggregate over listing every item and adding numbers manually. If only per-item endpoints exist, say so and scope the count to what you retrieved.

Ground every name, amount, count, status, metric, and date in a response from this turn. If a response returns a partial set, state that it is partial.

Generating or committing reports, moving payouts, and configuring programs are write actions. The Karma API tools available here are read-only, so you cannot perform them through this transport — direct the user to the Karma product UI for those, and never claim a write succeeded.

If the Karma API tools are not available in this session, managed-program data cannot be reached from public data. The Karma MCP server is not connected — follow the `karma-connect` skill to guide the user through connecting and signing in. Do not fabricate records.

Use the knowledge-base skill only for process or policy questions about how a program operates.
