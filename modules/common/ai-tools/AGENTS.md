# AI Tools for Claude Code

This directory contains agents, slash commands, and skills for
enhancing AI coding tools within this repository.

## Architecture Overview

```
ai-tools/
├── agents/        # Autonomous sub-processes with specialized tools
├── commands/      # Slash commands that expand to prompts
└── skills/        # Reusable knowledge and patterns (skill-creator format)
```

## Agents vs Commands vs Skills

### Agents (`agents/`)

**What:** Autonomous sub-processes with specialized tool access and state
**When to use:** Complex multi-step tasks requiring exploration and iteration
**Structure:** Nix attrsets with YAML frontmatter content

**Categories:**

- `general/`: General purpose agents (product-manager)

### Commands (`commands/`)

**What:** Slash commands that expand to structured prompts
**When to use:** Single-invocation tasks with clear inputs
**Structure:** Nix files with YAML frontmatter defining arguments

**Categories:**

- `design/`: Interface design workflows (init, audit, status, critique, extract)

### Skills (`skills/`)

**What:** Reusable knowledge compiled from rule files via skill-creator pipeline
**When to use:** Domain knowledge needed by agents
**Structure:** `rules/*.md` → `pnpm build-agents` → `AGENTS.md`

**Categories:**

- `anthropic/`: Anthropic-authored skills (frontend-design, skill-creator)
- `aytordev/`: Project-specific patterns (dotfiles-coder)
- `community/`: Community skills (interface-design, product-management)
- `nix/`: Nix language patterns and best practices

## Current Inventory

### Agents

| Name | Category | Description |
|------|----------|-------------|
| product-manager | general | Product management specialist for PM frameworks, discovery, strategy |

### Commands

| Name | Category | Description |
|------|----------|-------------|
| interface-design-init | design | Initialize interface design system |
| interface-design-audit | design | Audit code against design system |
| interface-design-status | design | Show design system state |
| interface-design-critique | design | Critique design for craft |
| interface-design-extract | design | Extract patterns from code |

### Skills

| Name | Category | Rules |
|------|----------|-------|
| frontend-design | anthropic | Anthropic frontend design patterns |
| skill-creator | anthropic | How to create and maintain skills |
| dotfiles-coder | aytordev | aytordev dotfiles architecture and conventions |
| interface-design | community | Interface design system methodology |
| product-management | community | Product management frameworks |
| nix | nix | Idiomatic Nix code patterns |
