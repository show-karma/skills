# Karma Skills

These skills are the shared workflow layer for Karma agents.

They describe when and how to use Karma operations. They do not contain transport-specific setup, API-key registration, curl commands, or raw endpoint instructions.

Runtime adapters are responsible for exposing the operations listed in each skill's frontmatter. In-product Karma chat exposes them through the gap-indexer MCP tool surface. External agents may expose the same operations through MCP or another adapter.
