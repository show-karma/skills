---
name: application-review
description: Help application reviewers find assigned applications and understand review state.
operations:
  - search_karma_api_docs
  - get_karma_api_operation
  - call_karma_api
---

# Application Review

Use this skill when a reviewer asks about applications assigned to them, pending review work, review comments, application status, applicants, or links to applications.

Use the Karma API docs and read APIs before answering. Search the API docs for endpoints covering reviewer assignments, funding applications, and application review state, then call `call_karma_api` with concrete read-only `/v2` endpoints under the current user auth. Do not answer reviewer queue questions from memory or from project names.

For "what applications do I need to review" or similar queue questions, find the endpoint that returns the reviewer's assigned or pending applications, then return application identifiers, project or applicant names, statuses, and links when the response provides them.

If the response does not include links, do not invent them. Present the identifiers that are available and offer to fetch details for a specific application.

Posting comments or submitting feedback is a write action. The Karma API tools available here are read-only, so you cannot post a comment through this transport. You can draft the exact comment text with the user, but tell them the submission itself must happen in the Karma product UI, and never claim a comment was posted.

If the Karma API tools are not available in this session, the reviewer's queue cannot be reached from public data. The Karma MCP server is not connected — follow the `karma-connect` skill to guide the user through connecting and signing in. Do not fabricate a queue.

Do not use the knowledge base for application records or reviewer queues.
