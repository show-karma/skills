---
name: project-owner-workspace
description: Help project owners inspect their projects, grants, milestones, completions, updates, indicators, invoices, and payouts.
operations:
  - get_my_workspace
  - get_project_details
  - list_project_milestones
  - get_project_status
  - list_my_grants
---

# Project Owner Workspace

Use this skill when a project owner asks about their projects, grants, milestones, milestone completions, project status, updates, indicators, invoices, or payouts.

Use current page context when the user says "this project" or "this milestone." Otherwise start with the workspace or project list tool to identify the relevant project.

For status questions, call the relevant project, grant, milestone, completion, payout, or invoice tool before answering. Do not infer status from memory or project names.

For requested changes, preview proposed changes first when a preview tool exists. Present the proposed diff or summary and wait for explicit approval before using any commit tool.

Never claim an update, milestone, completion, or other write succeeded unless the commit tool returns success.
