# Local AI Knowledge

This subtree owns exactly four self-contained skill packages.
The official native Gentle AI installer owns Pi's workflow. See
[README.md](README.md) for ownership and operator onboarding.

## Rules

- `ai-skills.nix` is the shared Home Manager distributor, imported explicitly by
  `libraries/system/common/default.nix` (`mkHomeModules`). Keep it out of system
  module imports; retain `aytordev.programs.terminal.tools.ai-skills` for now.
- `scripts/prepare-pi-skills.sh` is an explicit operator step, not an activation hook.
- Preserve the portable `SKILL.md` identities and matching `metadata.json`.
- Export the neutral collection at `$XDG_DATA_HOME/aytordev/skills` whenever
  `ai-skills` is enabled. Publish the four directories recursively as file links
  for enabled Pi/OpenCode clients; never own their profiles or whole skills roots.
- The old Pi root needs the explicit, ownership-checked preactivation step in
  the README. Never add a destructive activation hook or force file collisions.
- Bundle optional resolver guidance inside `skill-registry/references/`; each
  folder must work when copied alone. Keep target-repository facts distinct from
  bundled resources, and state filesystem/terminal prerequisites.
- Host-native mechanisms own discovery and execution. Pen import is manual;
  do not invent scanning, MCP transport, hooks, or tool availability for it.
- The local registry defaults to session-only. Explicit file persistence uses
  `.ai-local/skill-registry.md`; never overwrite Shell's `.atl/skill-registry.md`.
- Do not restore local agents, commands, orchestration, vendor code, or updater
  wrappers. OpenCode retains its independent client configuration.
- Validate with inventory, skill-contract, dependencies, docs-links, and the
  package/publication ownership check.

## Current Inventory

### Skills

| Name | Purpose |
|------|---------|
| dotfiles-coder | Repository architecture and Nix configuration patterns |
| nix | Nix authoring, operational references, and package-diff helper |
| skill-creator | Local skill authoring and metadata contract |
| skill-registry | Explicitly invoked local knowledge index |

`dotfiles-coder/rules/patterns-module.md` remains the canonical module template.
