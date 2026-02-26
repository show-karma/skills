---
name: skill-creator
description: Create new Claude Code skills for the Karma ecosystem. Use when building, designing, or scaffolding a new skill — guides through intent capture, interview, SKILL.md writing, validation, and packaging. Specialized for grants management, funding maps, and ecosystem growth tooling.
---

# Karma Skill Creator

Create well-structured Claude Code skills for the Karma ecosystem.

## Skill Creation Process

1. **Understand** the skill with concrete examples
2. **Plan** reusable skill contents (references, assets)
3. **Initialize** the skill directory structure
4. **Write** the skill (implement resources and SKILL.md)
5. **Iterate** based on real usage

## Step 1: Understand the Skill

Ask the user for concrete examples of how the skill will be used:

- "What should this skill do? Can you give 2-3 example prompts?"
- "What would a user say that should trigger this skill?"
- "What Karma-specific context does this need?" (grants, funding maps, ecosystem data)

For Karma domain context, see [karma-context.md](references/karma-context.md).

## Step 2: Plan Reusable Contents

For each example, identify what reusable resources would help:

| Resource Type | When to Use | Example |
|--------------|-------------|---------|
| `references/` | Domain knowledge Claude needs | `references/gap-schema.md` |
| `assets/` | Files used in output | `assets/report-template.md` |

## Step 3: Initialize the Skill

Create the skill directory under `skills/`:

```
skills/<skill-name>/
├── SKILL.md          # Required
├── references/       # Optional
└── assets/           # Optional
```

**Naming rules:**
- kebab-case, lowercase letters, digits, and hyphens only
- Max 64 characters
- Descriptive: `grant-milestone-tracker`, not `tracker`

## Step 4: Write the Skill

### SKILL.md Structure

```yaml
---
name: skill-name
description: What the skill does and when to use it. Include specific triggers.
---
```

The body contains instructions Claude will follow. Key principles:

**Concise is key.** Claude is already smart — only add what it doesn't know. Challenge each paragraph: "Does this justify its token cost?"

**Set appropriate freedom levels:**
- **High freedom** (text instructions): multiple valid approaches, context-dependent
- **Medium freedom** (pseudocode/parameterized scripts): preferred pattern with some variation
- **Low freedom** (exact scripts): fragile operations, consistency critical

**Progressive disclosure:** Keep SKILL.md under 500 lines. Split into reference files when approaching this limit.

### Design Patterns

Consult these guides based on your skill's needs:

- **Multi-step processes**: See [workflows.md](references/workflows.md) for sequential and conditional patterns
- **Output format/quality**: See [output-patterns.md](references/output-patterns.md) for template and example patterns

### What NOT to Include

- README.md, CHANGELOG.md, or other auxiliary docs
- "When to use" sections in the body (put this in the frontmatter description)
- Setup/testing procedures
- Information Claude already knows

## Step 5: Iterate

1. Use the skill on real tasks
2. Note struggles or inefficiencies
3. Update SKILL.md or resources

## Karma Domain Context

For Karma-specific knowledge (platform overview, key repos, domain concepts, suggested skill categories), see [karma-context.md](references/karma-context.md).

**Primary focus areas for skills:**
- Grants management (GAP protocol, milestones, reporting)
- Funding maps (cross-ecosystem funding flows)
- Ecosystem growth (metrics, community health)
