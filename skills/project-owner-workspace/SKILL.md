---
name: project-owner-workspace
description: Help project owners inspect their projects, grants, milestones, completions, updates, indicators, invoices, and payouts.
operations:
  - search_karma_api_docs
  - get_karma_api_operation
  - call_karma_api
---

# Project Owner Workspace

Use this skill when a project owner asks about their projects, grants, milestones, milestone completions, project status, updates, indicators, invoices, or payouts.

Use the Karma API docs and read APIs before answering. Search the API docs for endpoints covering the user's workspace, projects, grants, milestones, completions, indicators, invoices, and payouts, then call `call_karma_api` with concrete read-only `/v2` endpoints under the current user auth.

Use current page context when the user says "this project" or "this milestone." Otherwise find the workspace or project-list endpoint first to identify the relevant project, then call narrower endpoints for status.

For status questions, call the relevant project, grant, milestone, completion, payout, or invoice endpoint before answering. Do not infer status from memory or project names. Return names, statuses, counts, dates, and links only when the response provides them.

Posting updates, submitting milestone completions, and similar changes are write actions. The Karma API tools available here are read-only, so you cannot perform them through this transport. Draft proposed content with the user if helpful, but tell them the change must be made in the Karma product UI, and never claim an update or completion succeeded.

If the Karma API tools are not available in this session, the user's workspace cannot be reached from public data. The Karma MCP server is not connected — follow the `karma-connect` skill to guide the user through connecting and signing in. Do not fabricate records.
