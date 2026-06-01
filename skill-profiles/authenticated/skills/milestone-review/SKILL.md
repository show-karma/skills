---
name: milestone-review
description: Help milestone reviewers find projects and milestones ready for review.
operations:
  - search_karma_api_docs
  - get_karma_api_operation
  - call_karma_api
  - get_my_workspace
  - list_milestone_completions
  - get_milestone_completion
  - get_project_details
  - list_project_milestones
---

# Milestone Review

Use this skill when a milestone reviewer asks which projects, grants, milestones, or completions are ready for their review.

Use Karma API docs and read APIs before answering milestone reviewer queue questions.

When the user asks what a named reviewer needs to review, search the API docs for reviewer profiles, reviewer assignments, and pending milestone verification endpoints. Use `call_karma_api` only with concrete read-only `/v2` endpoints under the current user auth.

For named-reviewer questions, do not answer from an unfiltered community queue. Resolve the reviewer through documented user/reviewer APIs, then filter or join the pending verification queue by the assigned milestone reviewer address. If multiple people match the name, use reviewer assignment data when it disambiguates; otherwise ask the user to choose.

When the user asks for milestone counts scoped to a program, round, or batch (for example, "In batch 1, how many projects still have pending milestones?"), search the API docs for the same endpoint the frontend page uses, then call that API with the program filter. Do not list applications or projects one by one and sum them yourself when a frontend-backed endpoint already returns the answer.

Use documented milestone report, project update, funding application, and reviewer APIs for broader milestone progress questions, such as total pending milestone counts by project/grant, past-due counts, reviewer assignments, or submitted completions awaiting verification.

Return project names, grant titles, pending milestone counts, past-due counts, due dates, and links when the operation provides them.

If only project or milestone identifiers are available, present those identifiers clearly and avoid inventing missing names, links, or statuses.

Milestone review is about verifying completion evidence. It is not the same as reviewing applications.

Do not use the knowledge base for milestone queues or completion status.
