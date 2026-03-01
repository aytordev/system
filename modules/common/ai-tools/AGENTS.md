# AI Tools

Agents, slash commands, and skills for enhancing AI coding tools. Consumed by Claude Code, OpenCode, and Gemini CLI through a multi-tool Nix pipeline.

## Architecture

```
ai-tools/
├── agents/        # Autonomous sub-processes with specialized tools
├── commands/      # Slash commands that expand to prompts
├── skills/        # Reusable knowledge and patterns (skill-creator format)
├── agents.nix     # Agent pipeline (Nix → multi-tool output)
├── commands.nix   # Command pipeline (Nix → multi-tool output)
└── default.nix    # Entry point
```

## Agents vs Commands vs Skills

### Agents (`agents/`)

**What:** Autonomous sub-processes with specialized tool access and state
**When to use:** Complex multi-step tasks requiring exploration and iteration
**Structure:** Nix attrsets with colocated `.md` prompt files

### Commands (`commands/`)

**What:** Slash commands that expand to structured prompts
**When to use:** Single-invocation tasks with clear inputs
**Structure:** Nix attrsets with `description`, `allowedTools`, `prompt`, and optional `argumentHint`

### Skills (`skills/`)

**What:** Reusable knowledge following the skill-creator pattern
**When to use:** Domain knowledge read by sub-agents at runtime
**Structure:** `SKILL.md` (index + protocol) + `rules/` (execution steps + constraints) + `references/` (templates, optional)

## Current Inventory

### Agents

| Name | Category | Description |
|------|----------|-------------|
| sdd-orchestrator | sdd | SDD delegate-only orchestrator — coordinates spec-driven development via sub-agents |

### Commands

| Name | Category | Description |
|------|----------|-------------|
| sdd-init | sdd | Initialize SDD context in current project |
| sdd-explore | sdd | Explore and investigate an idea (read-only) |
| sdd-new | sdd | Start a new change (explore then propose) |
| sdd-continue | sdd | Continue next SDD phase in dependency chain |
| sdd-ff | sdd | Fast-forward all planning phases |
| sdd-apply | sdd | Implement tasks from the change |
| sdd-verify | sdd | Validate implementation against specs |
| sdd-archive | sdd | Sync specs and archive completed change |

### Skills

| Name | Category | Description |
|------|----------|-------------|
| skill-creator | core | How to create and maintain skills |
| dotfiles-coder | core | aytordev dotfiles architecture and conventions |
| nix | core | Idiomatic Nix code patterns and best practices |
| sdd-init | sdd | Initialize SDD context — detect stack, bootstrap persistence |
| sdd-explore | sdd | Investigate codebase and compare approaches |
| sdd-propose | sdd | Create change proposal with intent, scope, approach |
| sdd-spec | sdd | Write delta specifications (ADDED/MODIFIED/REMOVED) |
| sdd-design | sdd | Create technical design document |
| sdd-tasks | sdd | Break down change into phased task checklist |
| sdd-apply | sdd | Implement tasks following specs and design |
| sdd-verify | sdd | Quality gate — validate implementation matches specs |
| sdd-archive | sdd | Sync delta specs to main specs, archive change |
