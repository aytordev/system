# AI Tools

Agents, slash commands, and skills for agentic coding workflows. The
client-neutral definitions live here; each client consumes them through its own
home module:

- **OpenCode** renders commands and agents from `commands.nix` / `agents.nix` and
  links `base.md` as context plus the `skills/` tree.
- **Pi** deploys generated phase commands, a bounded child-worker adapter, the
  local MCP bridge, and the same `base.md` + `skills/` tree through
  `modules/home/programs/terminal/tools/pi/`.

Both clients consume the same registry, role policy, skills, and `aytordev-sdd`
engine adapter. See [Support Matrix](#support-matrix) for what is verified in
each client and [verification-report.md](verification-report.md) (T16) for the
evidence, commands, and open gaps.

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

## Support Matrix

Verified against the frozen revisions and clients in
[verification-report.md](verification-report.md) (T16). `Supported` means a
deterministic check exercises the behavior; `Partial`/`Advisory`/`Unverified`
name the residual gap; `Documented` means the procedure exists but was not
executed.

| Capability | OpenCode | Pi | Evidence |
| --- | --- | --- | --- |
| Commands + argument preservation | Supported | Supported | `ai-tools-renderers`, `ai-tools-contract`, `ai-tools-pi-workflow`; scripted-provider |
| Role/model routing | Supported | Supported (session-level) | `ai-tools-roles`, `ai-tools-permissions`; `ai-tools-pi-workflow`; scripted-provider |
| Home-scoped MCP selection | Supported | Supported (local bridge) | `ai-tools-mcp`; `ai-tools-pi-mcp-bridge` |
| Persistence modes (Engram/OpenSpec/hybrid/none) | Supported | Supported | `gentle-ai-engine`, `ai-tools-sdd-persistence`, `ai-tools-sdd-research` |
| SDD complete/resume | Supported | Supported | `ai-tools-archive`, `ai-tools-sdd-handoffs`, `ai-tools-legacy-compat`, `ai-tools-pi-workflow` |
| Independent review | Supported (enforced) | Advisory (unverified write gate) | `ai-tools-permissions`; `ai-tools-pi-workflow` |
| Added methods + lightweight routing | Supported | Supported | `ai-tools-method-routing`, `ai-tools-workflow-routing`, `ai-tools-testing-scope` |
| Reversible deployment | Documented | Documented | `legacy-compatibility.md`; plan T08 |
| Canonical skills + loading | Supported | Supported | `ai-tools-skill-contract`, `ai-tools-loading`, `ai-tools-inventory`, `ai-tools-dependencies` |
| Explicit state + closure | Supported | Supported | `ai-tools-sdd-persistence`, `ai-tools-sdd-handoffs`, `ai-tools-archive` |
| Upstream migration | Supported | Supported | `ai-tools-bundles`; `upstream-sources.md`, `bundle-verification.md` |
| Live-model execution | Not run | Not run | verification-report.md §5 |
| Pi permission enforcement | n/a | Unverified | `client-capabilities.md` blocker 1 |

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
These documents describe the implemented architecture; the dual-client workflow
delivery and its evidence are recorded in
[verification-report.md](verification-report.md).

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
- The `pi` home module imports `base.md` and the `skills/` tree and deploys the
  generated phase commands, bounded child-worker adapter, and local MCP bridge.
