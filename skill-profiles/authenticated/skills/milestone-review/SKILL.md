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

Use the milestone report operations before answering milestone reviewer queue questions.

When the user asks what a named reviewer needs to review, first resolve the reviewer with `resolveReviewer`, then call `getMilestoneReport` filtered by `reviewerAddress`, sorted by `pendingMilestones` descending. In Karma's in-product agent runtime, call these through `call_karma_operation`.

Use `getPendingVerificationMilestones` only when the user specifically asks for submitted milestone completions awaiting verification. Do not treat that as the full milestone review queue; the frontend milestones report uses `getMilestoneReport`.

Return project names, grant titles, pending milestone counts, past-due counts, due dates, and links when the operation provides them.

If only project or milestone identifiers are available, present those identifiers clearly and avoid inventing missing names, links, or statuses.

Milestone review is about verifying completion evidence. It is not the same as reviewing applications.

Do not use the knowledge base for milestone queues or completion status.
