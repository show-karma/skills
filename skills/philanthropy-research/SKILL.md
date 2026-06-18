---
name: philanthropy-research
description: Research grantmakers, nonprofits, grant transactions, totals, filings, and prospect-fit evidence using Karma philanthropy data.
operations:
  - search_karma_api_docs
  - get_karma_api_operation
  - call_karma_api
---

# Philanthropy Research

Use this skill for questions about funders, nonprofits, grant transactions, historical giving, foundation filings, prospect lists, or funding patterns.

Use the Karma API docs and read APIs before answering. Search the API docs for philanthropy endpoints covering organizations, foundations, grants, and 990 filings, then call `call_karma_api` with concrete read-only `/v2` endpoints. Ground every organization name, EIN, amount, year, recipient, funder, and filing claim in a response from this turn.

Prefer an endpoint that returns the answer directly. For a single foundation's filings or 990 detail, find the foundation or filing endpoint and call it. For totals, rankings, or comparisons, prefer an endpoint that returns an aggregate over listing many grants and summing amounts manually.

Some philanthropy capabilities — free-text organization or grant search, large aggregations, and raw SQL — are not exposed as read-only `/v2` endpoints, so the read-only API tools here cannot run them. When the question needs one of these and no GET endpoint answers it, say what you searched and what the read-only surface cannot do, rather than guessing. Those broader queries are available in the Karma product.

If the result set is partial, say what was searched and what limitation remains. Do not invent contact information or application procedures.

If the Karma API tools are not available in this session, the Karma MCP server is not connected — follow the `karma-connect` skill to guide the user through connecting and signing in. Use open-web research tools only when they are available and the user asks for open-web enrichment.
