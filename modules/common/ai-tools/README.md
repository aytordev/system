# AI Tools

Agents, slash commands, and skills for agentic coding workflows. Consumed by
OpenCode through a Nix pipeline (`agents.nix` / `commands.nix` / `skills.nix` in
`modules/common/ai-tools`).

## Architecture

```
ai-tools/
├── agents/         # Autonomous sub-processes (e.g. sdd-orchestrator)
├── commands/       # Slash commands (e.g. /sdd-init, /sdd-apply)
├── skills/         # Reusable knowledge + protocols (SKILL.md + rules/)
├── agents.nix      # Agent pipeline → per-tool output
├── commands.nix    # Command pipeline → per-tool output
└── default.nix     # Entry point; exposes the opencode adapters
```

Each agent/command is a Nix attrset or directory. `agents.nix` /
`commands.nix` render them into the format OpenCode expects
(markdown/agent-configs). Skills are consumed directly from the `skills/` tree by
the tool's runtime.

## Agents vs Commands vs Skills

| Kind | Purpose | Structure |
| --- | --- | --- |
| Agent | Autonomous sub-process with tool access | `.nix` + colocated `.md` prompt |
| Command | Slash command expanding to a prompt | `commands/{category}/{name}.nix` |
| Skill | Reusable knowledge read at runtime | `skills/{name}/SKILL.md` + `rules/` |

## What Lives Here

- **SDD workflow**: orchestrator agent + init/explore/propose/spec/design/
  tasks/apply/verify/archive commands and skills (see
  `agents/sdd`, `commands/sdd`, `skills/sdd-*`).
- **Workflow skills**: branch-pr, chained-pr, work-unit-commits,
  cognitive-doc-design, comment-writer, issue-creation.
- **Core skills**: skill-creator, skill-registry, judgment-day, dotfiles-coder,
  nix.

See `AGENTS.md` in this directory for the current full inventory and the
protocols to follow when adding a new agent/command/skill.

## Adding a New Command / Agent / Skill

1. Add the file under the matching `commands/`, `agents/`, or `skills/` tree.
2. Export through the relevant `*.nix` loader so it reaches the consuming tool.
3. Run `nix fmt` and `nix flake check --no-build` to validate.
4. Update the inventory table in `AGENTS.md`.

## Consumption

The output is wired into OpenCode's config by the `opencode` home module. You do
not normally touch `ai-tools` from a home config; you add content inside
`ai-tools/` and let the loaders propagate it.
