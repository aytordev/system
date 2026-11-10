# Local AI Knowledge

This subtree owns the twenty-three-entry skill catalog, twenty-two authored skill packages,
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
  twenty-two local folders. Upstream `impeccable` comes from
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
| acceptance-review | Read-only acceptance review of a change against its contract |
| aytordev-pen-ops | Observed-capability Pen session operations: inspection, authorized bounded edits, verification |
| characterisation-tests | Pins existing behaviour before changing untested code |
| ci-debugging | CI failure diagnosis: provider evidence, reproduction, environment deltas |
| dotfiles-coder | Repository architecture and Nix configuration patterns |
| double-check | Independent second review of a finished artifact |
| evaluate-existing-solutions | Evidence-based build-versus-adopt evaluation |
| expectations | Routing a learning to its durable owner |
| find-gaps | Tightens a written artifact one confirmed answer at a time |
| front-end-testing | Browser-observable claims, harness choice, and evidence boundaries |
| functional | Immutable domain data, pure-function boundaries, composition, and error values |
| impeccable | Packaged upstream design skill with complete references, scripts, and pinned sibling engine |
| mutation-testing | Mutation gate, survivor triage, and diff-scoped runs |
| nix | Nix authoring, operational references, and package-diff helper |
| panel-review | Multi-lens review with adversarial verification to PR-readiness |
| react-testing | React component behaviour, integrity, and browser-mode rules |
| refactoring | Behaviour-preserving assessment with a labelled reply |
| skill-creator | Local skill authoring and metadata contract |
| skill-registry | Explicitly invoked local knowledge index |
| tdd | RED-GREEN-REFACTOR with a bounded feedback loop and one mutation gate |
| test-design-reviewer | Eight-property test review with file-level evidence |
| testing | Behaviour-first tests, factories, and mutation-aware planning |
| typescript-strict | Strict-mode boundary typing, declaration forms, schemas, and compiler checks |

Twenty-two rows are authored locally: `dotfiles-coder` and `nix` are `local`;
the other twenty are `adapted`. `impeccable` is the one intact `upstream` package.
The seventeen `import-baseline` adaptations record the exact upstream revision
their bytes came from; the `historical-comparison` ones keep unknown import
revisions null. One of them, `acceptance-review`, carries a nested MIT
`LICENSE` from its own author instead of the repository license.
Local metadata/dependency checks inspect only `skills/`; publication checks
cover all twenty-three.

`dotfiles-coder/rules/patterns-module.md` remains the canonical module template.
