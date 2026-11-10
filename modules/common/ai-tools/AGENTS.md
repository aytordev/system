# Local AI Knowledge

This subtree owns the thirteen-entry skill catalog, twelve authored skill packages,
private Impeccable preparation recipes, and publication of the unmodified
packaged upstream skill.
The official native Gentle AI installer owns Pi's workflow. See
[README.md](README.md) for ownership and operator onboarding.

## Rules

- `catalog.nix` is pure ownership data: names, kinds, sources, manual update
  policies, structured origins/baseline roles, tracking, provenance pointers,
  and Impeccable payload/release pins. Null tracking means no configured channel;
  null import/sync revisions mean unknown, not the comparison revision. Local
  entries have no external update source. Keep versions/descriptions in local
  frontmatter/metadata and detailed provenance in its existing documents.
- `upstream/impeccable/{engine,skill}.nix` owns standalone package preparation,
  with no config/Home Manager dependencies. The public `packages/` entry points
  must stay direct imports, preserving `callPackage` argument introspection.
  Do not move ownership back into package adapters or change package discovery.
- Derive publication from the catalog, not a second name/source list. Manual
  updates only: no tracking branch, automatic synchronizer, or runtime registry.
- `ai-skills.nix` is the shared Home Manager distributor, imported explicitly by
  `libraries/system/common/default.nix` (`mkHomeModules`). Keep it out of system
  module imports; retain `aytordev.programs.terminal.tools.ai-skills` for now.
- `scripts/prepare-pi-skills.sh` is an explicit operator step, not an activation hook.
- Preserve authored `SKILL.md` identities and matching `metadata.json` in the
  twelve local folders. Upstream `impeccable` comes from
  `${pkgs.aytordev.impeccable-skills}/share/impeccable`; do not impose local
  metadata, rewrite upstream files, or vendor its payload here.
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
| aytordev-pen-ops | Observed-capability Pen session operations: inspection, authorized bounded edits, verification |
| ci-debugging | CI failure diagnosis: provider evidence, reproduction, environment deltas |
| dotfiles-coder | Repository architecture and Nix configuration patterns |
| expectations | Routing a learning to its durable owner |
| functional | Immutable domain data, pure-function boundaries, composition, and error values |
| impeccable | Packaged upstream design skill with complete references, scripts, and pinned sibling engine |
| nix | Nix authoring, operational references, and package-diff helper |
| refactoring | Behaviour-preserving assessment with a labelled reply |
| skill-creator | Local skill authoring and metadata contract |
| skill-registry | Explicitly invoked local knowledge index |
| tdd | RED-GREEN-REFACTOR with a bounded feedback loop and one mutation gate |
| testing | Behaviour-first tests, factories, and mutation-aware planning |
| typescript-strict | Strict-mode boundary typing, declaration forms, schemas, and compiler checks |

Twelve rows are authored locally: `dotfiles-coder` and `nix` are `local`;
`aytordev-pen-ops`, `ci-debugging`, `expectations`, `functional`, `refactoring`,
`skill-creator`, `skill-registry`, `tdd`, `testing`, and `typescript-strict`
are `adapted`. `impeccable` is the one intact `upstream` package. The seven
`import-baseline` adaptations record the exact upstream revision their bytes came
from; the `historical-comparison` ones below keep unknown import revisions null.
Local metadata/dependency checks inspect only `skills/`; publication checks
cover all thirteen. Native Pi and the local registry discover upstream through
`SKILL.md` without requiring `metadata.json`.

`dotfiles-coder/rules/patterns-module.md` remains the canonical module template.
