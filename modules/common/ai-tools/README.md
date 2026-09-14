# AI Tools

Agents, slash commands, and skills for agentic coding workflows. The
client-neutral definitions live here; each client consumes them through its own
home module:

- **OpenCode** renders commands and agents from `commands.nix` / `agents.nix` and
  links `base.md` as context plus the `skills/` tree.
- **Pi** currently reuses `base.md` and the `skills/` tree directly. Native Pi
  commands, delegation, and MCP are still in progress (ADR 0015; see the
  [implementation plan](implementation-plan.md)).

See [Proposed Evolution](#proposed-evolution) for the target dual-client
architecture.

## Architecture

```
ai-tools/
├── agents/         # Agent definitions + prompts (e.g. sdd-orchestrator)
├── commands/       # Slash command definitions (e.g. /sdd-init, /sdd-apply)
├── skills/         # Reusable knowledge + protocols (SKILL.md + rules/)
├── registry.nix    # Client-neutral validated registry (commands, agents)
├── roles.nix       # Role/model policy shared by the client adapters
├── agents.nix      # Agent pipeline → OpenCode agent representation
├── commands.nix    # Command pipeline → OpenCode markdown
└── default.nix     # Entry point; derives the OpenCode adapters
```

Each agent/command is a Nix attrset or directory. `registry.nix` validates the
shared definitions — unique identifiers per kind, resolvable agent references —
and `default.nix` derives the OpenCode renderings from those same definitions.
Skills are consumed directly from the `skills/` tree by each client's runtime.

## Agents vs Commands vs Skills

| Kind | Purpose | Structure |
| --- | --- | --- |
| Agent | Autonomous sub-process with tool access | `.nix` + colocated `.md` prompt |
| Command | Slash command expanding to a prompt | `commands/{category}/{name}.nix` |
| Skill | Reusable knowledge read at runtime | `skills/{name}/SKILL.md` + `rules/` |

## What Lives Here

- **SDD workflow**: orchestrator agent, slash-command entry points, and phase
  skills (see `agents/sdd`, `commands/sdd`, `skills/sdd-*`). Commands and phase
  skills have separate inventories; not every phase has its own slash command.
- **Workflow skills**: branch-pr, chained-pr, work-unit-commits,
  cognitive-doc-design, comment-writer, issue-creation.
- **Core skills**: skill-creator, skill-registry, judgment-day, dotfiles-coder,
  nix.

See `AGENTS.md` in this directory for the current full inventory and the
protocols to follow when adding a new agent/command/skill.

## Proposed Evolution

Start with the [value proposal](proposal.md) for expected outcomes, costs,
delivery sequence, and pending decisions.

[ADR 0015](../../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md)
records the audit and proposal for executable workflow contracts in both OpenCode
and Pi, explicit per-home MCP selection, configurable model roles, and selective
skill improvements. It also compares the current gentle-ai SDD workflow and the
still-open engine and successful-close verification choices.
[ADR 0016](../../../docs/decisions/0016-keep-skills-canonical-and-registry-derived.md)
keeps skill authoring separate from index-first discovery and canonical loading.
[ADR 0017](../../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md)
defines migration from current, pinned upstream skills as compatible bundles with
explicit local adaptations and existing-state recovery.
The [implementation plan](implementation-plan.md) tracks dependency-ordered tasks,
including the engine comparison, source pinning, artifact migration, bundle
deployment, and acceptance criteria.
These documents describe the target architecture; full dual-client workflow
support is not implemented yet.

## Adding a New Command / Agent / Skill

1. Add the file under the matching `commands/`, `agents/`, or `skills/` tree.
2. Export through the relevant `*.nix` loader so it reaches the consuming tool.
3. Run `nix fmt` and `nix flake check --no-build` to validate.
4. Update the inventory table in `AGENTS.md`.

## Consumption

Content is authored inside `ai-tools/`; the consuming home modules own
deployment into each client.

- The `opencode` home module wires the rendered commands/agents, the `base.md`
  context, and the `skills/` tree into OpenCode.
- The `pi` home module imports `base.md` and the `skills/` tree directly; native
  SDD commands, delegation, and MCP are part of the proposed evolution above
  (ADR 0015).
