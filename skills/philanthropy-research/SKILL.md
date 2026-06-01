---
name: philanthropy-research
description: Research grantmakers, nonprofits, grant transactions, totals, filings, and prospect-fit evidence using Karma philanthropy data.
operations:
  - search_organizations
  - search_grants
  - aggregate_grants
  - get_irs_990
  - run_sql
---

# Philanthropy Research

Use this skill for questions about funders, nonprofits, grant transactions, historical giving, foundation filings, prospect lists, or funding patterns.

Start with the narrowest read tool that matches the question. Use organization search for entity discovery, grant search for transaction examples, aggregate grants for totals and rankings, and filing lookup for 990 details.

For totals, rankings, or comparisons, prefer `aggregate_grants` or another aggregate-capable tool. Do not list many grants and sum amounts manually unless no aggregate tool can answer the question.

For SQL, use read-only queries only. Keep the query scoped to the user's question and avoid selecting unnecessary columns.

Ground organization names, EINs, amounts, years, recipients, funders, and filing claims in tool results from this turn. If the result set is partial, say what was searched and what limitation remains.

Do not invent contact information or application procedures. Use web research tools only when they are available and the user asks for open-web enrichment.
