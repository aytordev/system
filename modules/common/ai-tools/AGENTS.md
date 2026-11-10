# Local AI Knowledge

This subtree owns the fifty-six-entry skill catalog, fifty-five authored skill packages,
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
  fifty-five local folders. Upstream `impeccable` comes from
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
| api-design | HTTP API contracts: compatibility, errors, idempotency, quotas |
| aytordev-pen-ops | Observed-capability Pen session operations: inspection, authorized bounded edits, verification |
| bff-design | backend-for-frontend shape, adoption, and ownership |
| bff-entry-points | endpoint classification, prepared registrars, authorization boundaries |
| characterisation-tests | Pins existing behaviour before changing untested code |
| ci-debugging | CI failure diagnosis: provider evidence, reproduction, environment deltas |
| cli-design | streams, exit codes, secrets, composability, stability |
| codebase-design | in-process module and package contracts, plus deep-module consolidation |
| debugging | preserve evidence, reproduce and localize, one hypothesis at a time |
| diagrams | evidence and authority, accessibility, validation of diagrams |
| domain-driven-design | bounded contexts, aggregates, domain services, and placement |
| dotfiles-coder | Repository architecture and Nix configuration patterns |
| double-check | Independent second review of a finished artifact |
| evaluate-existing-solutions | Evidence-based build-versus-adopt evaluation |
| event-sourcing | event modelling, decider and rehydration, projections, versioning |
| expectations | Routing a learning to its durable owner |
| find-gaps | Tightens a written artifact one confirmed answer at a time |
| find-skills | verification before recommending, installation authorization |
| finding-seams | introduces seams so untestable dependencies become controllable |
| folder-structure | deprecation alias that delegates the retired convention and stops when alone |
| front-end-testing | Browser-observable claims, harness choice, and evidence boundaries |
| functional | Immutable domain data, pure-function boundaries, composition, and error values |
| graph-engineering | graph-derived parallel skill application and impact analysis |
| hexagonal-architecture | ports and adapters, wiring, testing boundaries, anti-patterns |
| impeccable | Packaged upstream design skill with complete references, scripts, and pinned sibling engine |
| improve-codebase-architecture | ranks where architecture investment pays off |
| mutation-testing | Mutation gate, survivor triage, and diff-scoped runs |
| nix | Nix authoring, operational references, and package-diff helper |
| observability | wide events, SLOs and alerting, telemetry hygiene and placement |
| panel-review | Multi-lens review with adversarial verification to PR-readiness |
| planning | vertical slices, known-good increments, delivery and review cadence |
| production-parity-skill-builder | derives a skill from a production system, parity map first |
| react-performance | measurement method first, house rules, anti-patterns |
| react-testing | React component behaviour, integrity, and browser-mode rules |
| reduce-system-complexity | whole-path reduction of branches, states, layers and jobs |
| refactoring | Behaviour-preserving assessment with a labelled reply |
| render-code-shape | citation contract, render format, findings and boundaries |
| secure-oauth-oidc | RFC 9700 boundaries, OIDC validation, and false assurances |
| skill-creator | Local skill authoring and metadata contract |
| skill-registry | Explicitly invoked local knowledge index |
| specification | example map, accountable review, spec review template |
| stack-pull-requests | units and decisions, stack design, verification, merge order |
| story-splitting | capability slices and the quality of a split story |
| storyboard | page structure, embedding safety, review lifecycle |
| structure-codebase | repository tree and package placement decisions |
| tdd | RED-GREEN-REFACTOR with a bounded feedback loop and one mutation gate |
| teach-me | tutoring protocol where the learner does the thinking |
| technical-writing | reader-first structure, receipts for claims, docs as behaviour |
| test-design-reviewer | Eight-property test review with file-level evidence |
| testing | Behaviour-first tests, factories, and mutation-aware planning |
| twelve-factor | twelve-factor conformance for deployable services |
| typescript-strict | Strict-mode boundary typing, declaration forms, schemas, and compiler checks |
| ubiquitous-language | one glossary per bounded context, mechanically enforced |
| wtf | plain-language explanation of unfamiliar code or terms |
| xstate | statechart modelling before code, actors, and diagrams |

Fifty-five rows are authored locally: `dotfiles-coder` and `nix` are `local`;
the other fifty-three are `adapted`. `impeccable` is the one intact `upstream`
package. The fifty `citypaul` adaptations record the exact upstream revision
their bytes came from; the `historical-comparison` ones keep unknown import
revisions null.
Licences are per package, not per repository. Nine adaptations carry nested MIT
notices from their own authors — `acceptance-review`, `reduce-system-complexity`,
`render-code-shape`, `technical-writing`, and `wtf` (Adam Bulmer);
`codebase-design` and `improve-codebase-architecture` (Matt Pocock);
`api-design` (Addy Osmani); `find-skills` (Vercel, Inc.) — and `cli-design` is
**CC BY-SA 4.0**, not MIT, because it adapts the Command Line Interface
Guidelines. Each notice is reproduced verbatim, with its attribution and pinned
upstream revision, in that package's provenance.
Local metadata/dependency checks inspect only `skills/`; publication checks
cover all fifty-six.

`dotfiles-coder/rules/patterns-module.md` remains the canonical module template.
