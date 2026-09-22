# Local AI Knowledge

This subtree owns the repository's self-contained skill packages.
The official native Gentle AI installer owns Pi's workflow. See
[README.md](README.md) for ownership and operator onboarding.

## Rules

- `ai-skills.nix` is the shared Home Manager distributor, imported explicitly by
  `libraries/system/common/default.nix` (`mkHomeModules`). Keep it out of system
  module imports; retain `aytordev.programs.terminal.tools.ai-skills` for now.
- `scripts/prepare-pi-skills.sh` is an explicit operator step, not an activation hook.
- Preserve the portable `SKILL.md` identities and matching `metadata.json`.
- Export the neutral collection at `$XDG_DATA_HOME/aytordev/skills` whenever
  `ai-skills` is enabled. Publish the managed skill directories recursively as file links
  for the enabled Pi client; never own its profile or whole skills root.
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
  wrappers. Native Gentle AI owns the Pi workflow.
- Validate with inventory, skill-contract, dependencies, docs-links, and the
  package/publication ownership check.

## Current Inventory

### Skills

| Name | Purpose |
|------|---------|
| aytordev-design-system | Design-system discovery and evolution: tokens, component anatomy/states, adoption and migration |
| aytordev-interface-design | Interface design and read-only evidence-based review for the consuming project's system |
| aytordev-pen-ops | Observed-capability Pen session operations: inspection, authorized bounded edits, verification |
| dotfiles-coder | Repository architecture and Nix configuration patterns |
| nix | Nix authoring, operational references, and package-diff helper |
| skill-creator | Local skill authoring and metadata contract |
| skill-registry | Explicitly invoked local knowledge index |

`dotfiles-coder/rules/patterns-module.md` remains the canonical module template.
