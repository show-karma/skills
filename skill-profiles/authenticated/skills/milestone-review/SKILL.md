---
name: milestone-review
description: Help milestone reviewers find projects and milestones ready for review.
operations:
  - get_my_workspace
  - resolveReviewer
  - getMilestoneReport
  - getPendingVerificationMilestones
  - list_milestone_completions
  - get_milestone_completion
  - get_project_details
  - list_project_milestones
---

# Milestone Review

Use this skill when a milestone reviewer asks which projects, grants, milestones, or completions are ready for their review.

Use milestone review operations before answering milestone reviewer queue questions.

When the user asks what a named reviewer needs to review, first resolve the reviewer with `resolveReviewer`, then call `getPendingVerificationMilestones` filtered by that reviewer's `reviewerAddress`. In Karma's in-product agent runtime, call these through `call_karma_operation`.

For named-reviewer questions, never call `getPendingVerificationMilestones` without `reviewerAddress`. An unfiltered call returns the whole community queue, not that reviewer's queue. If `resolveReviewer` returns multiple possible people, use the reviewer address that appears in the community/program reviewer configuration when available; otherwise ask the user to choose.

Use `getMilestoneReport` for broader milestone progress questions, such as total pending milestone counts by project/grant, past-due counts, or all milestone status for a reviewer. Do not use it as the primary source for "needs to review", "ready for review", or "awaiting review" questions unless the user asks for broader project-level progress rather than submitted completions.

Return project names, grant titles, pending milestone counts, past-due counts, due dates, and links when the operation provides them.

If only project or milestone identifiers are available, present those identifiers clearly and avoid inventing missing names, links, or statuses.

Milestone review is about verifying completion evidence. It is not the same as reviewing applications.

Do not use the knowledge base for milestone queues or completion status.
