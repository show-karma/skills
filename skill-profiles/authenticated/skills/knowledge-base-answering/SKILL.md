---
name: knowledge-base-answering
description: Answer program and community process questions from Karma knowledge-base content.
operations:
  - searchKnowledgeBase
---

# Knowledge Base Answering

Use this skill for procedural, conceptual, or operational questions about a specific community, program, guide, policy, eligibility rule, deadline, or process.

Call the `searchKnowledgeBase` operation before answering. In Karma's in-product agent runtime, use `call_karma_operation` with `operationId: "searchKnowledgeBase"`. For how-to or step-by-step questions, set `topK` to 8 on the first search.

If results exist, answer from the retrieved chunks. Cite the `source` URL for each fact when a source is present. Attach a source only to facts that came from that same result.

If no results exist, say the topic is not covered in the community knowledge base. Do not answer from general knowledge for community-specific process questions.

Do not begin with a source preamble like "Based on the knowledge base" or "According to the docs." The first sentence should answer the question directly.

For procedural answers, list all retrieved steps in source order as a numbered list. Do not replace the answer with only a link to the guide.

Do not direct users to generic Karma support channels. If a program-specific contact channel appears in retrieved chunks, use that. Otherwise say the knowledge base does not include a contact for that question.
