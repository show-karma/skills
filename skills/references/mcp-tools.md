# Karma MCP Tools — Reference

Karma exposes its read surface through the Model Context Protocol. When the
`karma` MCP server is registered (it ships with this plugin via `.mcp.json`),
Claude Code surfaces these tools natively — call them by name, do **NOT**
shell out to `curl` for the same data.

The MCP server is at `${KARMA_API_URL:-https://gapapi.karmahq.xyz}/mcp` and
authenticates with `x-api-key: ${KARMA_API_KEY}` (set by the `setup-agent`
skill).

Why prefer MCP over REST in skills:

- **Single source of truth.** Tool descriptions, input schemas, and auth all
  live on the server. Skills don't redefine them.
- **No leaked credentials.** The skill never quotes the API key in prose.
- **Composed workflows.** Tools like `get_project_disbursement_total` answer
  one user question end-to-end; the equivalent REST flow needs 3–5 calls.
- **Endorsed pattern.** See Anthropic's
  [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
  — *"Skills can complement Model Context Protocol (MCP) servers by teaching
  agents more complex workflows that involve external tools and software."*

## When to use MCP vs. REST

| User intent | Use this MCP tool | REST fallback (only if no MCP equivalent) |
|---|---|---|
| Find a project / community / program by name | `karma_search_discover` | `GET /v2/projects?q=…` |
| Project status / completion % | `karma_project_get_status` | `GET /v2/projects/:slug` |
| Project full record | `karma_project_get_details` | `GET /v2/projects/:slug` |
| List a project's milestones | `karma_project_list_milestones` | `GET /v2/projects/:slug` |
| Milestones completed in a specific program | `karma_project_get_progress_in_program` | *(no single REST endpoint — multi-call chain)* |
| How much disbursed to a project (total + per-grant breakdown) | `karma_project_get_disbursement_total` | *(no single REST endpoint — multi-call chain)* |
| Who got funded in a program + amounts | `karma_program_get_funding_summary` | *(no single REST endpoint — multi-call chain)* |
| Per-payout history for one grant | *(no MCP tool — REST only)* | `GET /v2/payouts/grant/:uid/history` |
| Community overview (programs, stats) | `karma_community_get_overview` | `GET /v2/communities/:slug` |
| Program details | `karma_program_get_details` | `GET /v2/funding-program-configs/:programId` |
| Program report (counts, status breakdown) | `karma_program_generate_report` | *(MCP only)* |
| Process / workflow questions ("how do I submit a milestone update?") | `karma_process_answer_question` | *(MCP only)* |
| User's own projects + applications | `karma_user_get_workspace` | *(MCP only)* |

Tool names listed above are the **namespaced aliases** (`karma_*`). Each tool
also ships under a legacy unprefixed name (e.g. `discover`,
`get_project_status`) — both work; prefer the namespaced form in new prose.

## Calling pattern

In a SKILL.md, refer to MCP tools by name, **not** by JSON-RPC payload:

> *Bad:* `curl -X POST $BASE_URL/mcp -d '{"jsonrpc":"2.0", …}'`
>
> *Good:* "Call `karma_project_get_disbursement_total` with
> `{"projectIdOrSlug": "<slug>"}` and read `.summary` from the response."

Claude Code routes the call through MCP automatically. Each response is a
typed envelope with a one-sentence `summary`, structured `data`,
`identifiers` for chaining, and `nextActions` to steer follow-up calls.

## Write actions

Write actions (creating projects, attesting milestones, etc.) still go
through the agent execute REST endpoint at `POST /v2/agent/execute` —
that's a separate transactional surface that returns `txHash`/`uid` and
does not belong in MCP. Keep the existing `agent-api.md` reference for
those flows.

## Local development

To point at a local server, set `KARMA_API_URL=http://localhost:3005`
**before** opening Claude Code. The `.mcp.json` template substitutes
that into the URL on session start.
