---
name: application-review
description: Help application reviewers find assigned applications and understand review state.
operations:
  - list_assigned_applications
  - get_application_details
  - preview_add_application_comment
  - commit_add_application_comment
---

# Application Review

Use this skill when a reviewer asks about applications assigned to them, pending review work, review comments, application status, applicants, or links to applications.

For "what applications do I need to review" or similar queue questions, call `list_assigned_applications` or the available workspace tool before answering. Return application identifiers, project or applicant names, statuses, and links when the tool provides them.

If the tool result does not include links, do not invent links. Say what identifiers are available and offer to open or fetch details for a specific application if the tool surface supports it.

For comments or feedback, confirm the exact text with the user before submitting it. Never claim a comment was posted unless the write tool succeeds.

Do not use the knowledge base for application records or reviewer queues.
