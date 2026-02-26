# Contributing to Karma Skills

Thanks for your interest in contributing skills to the Karma ecosystem!

## Skill Structure

Every skill lives in its own directory under `skills/` and must contain at minimum a `SKILL.md` file:

```
skills/
└── my-skill-name/
    ├── SKILL.md          # Required — skill definition
    └── references/       # Optional — reference docs
```

## Naming Conventions

- **Directory name**: kebab-case, max 64 characters (e.g., `grant-milestone-tracker`)
- **Must be descriptive**: the name should clearly indicate what the skill does
- **Prefix with domain** when helpful: `grant-`, `funding-`, `ecosystem-`

## SKILL.md Requirements

Every `SKILL.md` must include YAML frontmatter with these fields:

```yaml
---
name: My Skill Name
description: A one-line description (max 120 characters)
version: 0.1.0
tags: [grants, funding-maps, ecosystem-growth]
---
```

The body of `SKILL.md` contains the skill instructions that Claude will follow.

## Validation Checklist

Before submitting, verify your skill manually:

- [ ] `SKILL.md` exists with valid YAML frontmatter (`name`, `description`)
- [ ] Name is kebab-case, max 64 characters
- [ ] Description is a single line, max 120 characters
- [ ] Body contains clear instructions for Claude

## PR Process

1. Fork the repository
2. Create a feature branch: `git checkout -b add-skill/my-skill-name`
3. Add your skill under `skills/`
4. Run through the validation checklist above
5. Open a PR with:
   - What the skill does
   - Example use cases
   - Any dependencies or requirements

## Code of Conduct

Be respectful, constructive, and collaborative. We're all building toward better grants infrastructure.
