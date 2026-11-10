---
name: structure-codebase
description: "Trigger: creating or reviewing a repository tree, deciding where files or packages belong, reducing flat folders, organizing by feature, route, use case, bounded context, workflow, or endpoint, structuring frontend state/data/UI ownership, making inside/outside boundaries visible, planning folder migrations, or enforcing package and import direction. Selects the lightest structure that makes the project's real seams easy to see and mechanically difficult to violate; one module's contract and responsibility design is a separate concern."
license: MIT
metadata:
  author: aytordev
  version: "1.0.0"
---

# Structure Codebase

Design the source tree as a truthful map of meaning, ownership, runtime
boundaries, and change cohesion. Do not start from a universal template. Select
the lightest structure that makes this project's real seams easy to see and
mechanically difficult to violate.

This skill owns physical placement and dependency enforcement. Which coherent
responsibility and caller-facing contract a module should own is a design
concern (the codebase-design companion, when installed). A flatter tree alone
is not a complexity-reduction result: a physical move removes files, not the
decisions, states, and dependencies the system must still execute.

`rules/` and `references/` are bundled with this skill. Repository paths refer
to the target repository, not to files beside this skill.

## Activation Contract

Use this skill when:

- Creating or reviewing repository trees, folder names, or package placement.
- Reducing flat folders or organizing by feature, route, screen, use case,
  bounded context, workflow, or endpoint.
- Structuring frontend route, feature, state, data, and design-system
  ownership.
- Deciding whether an inside/outside boundary is real, and where ports,
  adapters, and composition roots belong.
- Planning a folder migration or choosing import/package enforcement.

## Hard Rules

1. **Folder names make claims; tooling proves them.** Names such as `hexagon`,
   `adapters`, or `composition` are useful at real seams and harmful when they
   replace product meaning or claim boundaries that do not exist. Every claim
   that matters gets a package boundary, export rule, or architecture test.
2. **Select the smallest honest shape** for this project's signals
   (`rules/shape-selection.md`); never reproduce a template blindly, and never
   give a project architecture it has not earned.
3. **Inspect before naming.** Read the actual system — routes, packages,
   imports, tests, conventions, ownership signals — before proposing
   directories. Candidate boundaries are hypotheses until language, invariants,
   ownership, or dependency direction justify them.
4. **Scope is preserved.** Do not move files for a suggestion-only request, and
   do not broaden a folder change into a domain redesign without authorization.
5. **Every proposed directory owns something now.** Every new directory shown
   must own at least one named file, package, or concrete responsibility. Draw
   no empty symmetric skeletons; state future folders in prose.
6. **Protect required framework locations.** Do not fight, duplicate, or
   conceal a framework's route/discovery tree; keep required entry files thin
   and delegate behavior into feature-oriented modules.
7. **Separate semantic work from mechanical movement** in any migration
   (`references/enforcement-and-migration.md`); never label provider-dependent
   code as inside before dependency inversion makes the claim true.

## Execution Steps

1. **PRESERVE SCOPE** — determine whether the request is an audit, proposal,
   migration plan, or implementation; act accordingly.
2. **INSPECT** — read project rules, package manifests, imports, routes,
   tests, generated code, workspace and boundary tooling, and co-change
   signals; record uncertainty as hypotheses.
3. **SELECT THE SHAPE** — classify the project and pick the smallest honest
   shape (`rules/shape-selection.md`); test whether a hexagon is earned before
   introducing inside/outside vocabulary.
4. **PRODUCE STRUCTURE AND RULES TOGETHER** — annotated tree, placement rules,
   dependency directions, proportionate enforcement, and a staged migration
   where the existing tree changes (`rules/proposal-contract.md`).
5. **KEEP COHESION HONEST** — colocate what changes together, expose explicit
   public APIs, give reuse purpose-named owners, and apply the composition-root
   and frontend rules (`rules/cohesion-and-boundaries.md`).
6. **ENFORCE AND MIGRATE PROPORTIONATELY** — use the enforcement ladder, the
   dependency matrix, and the safe migration sequence
   (`references/enforcement-and-migration.md`); test discovery at the deepest
   proposed path before moving packages there.
7. **CHECK COMPLETION** against the questions in the Output Contract.

Read the relevant reference before producing a target tree:

- `references/visible-hexagon.md` — opted-in ports-and-adapters backends; DDD
  plus hexagonal boundaries; test actors, read models, package isolation.
- `references/backend-patterns.md` — feature-first services, BFFs,
  framework-constrained backends, operational/CLI code, small packages,
  monorepo grouping.
- `references/frontend-patterns.md` — frontend structures, design systems,
  meta-framework runtime boundaries.
- `references/enforcement-and-migration.md` — enforcement ladder, dependency
  matrix, safe migration sequence.
- `references/research-notes.md` — source-backed rationale for named
  approaches.

## Output Contract

Every proposal states: the selected shape and its evidence; an annotated tree
distinguishing grouping directories, real packages, and executable hosts, with
only evidence-backed target paths; placement rules for new files; allowed and
forbidden dependency directions; proportionate automated enforcement; a staged
migration when an existing tree must change; and assumptions, deferred
decisions, and structures intentionally not introduced.

Before finishing, check: can a newcomer identify the product capabilities
before the framework; is any claimed inside/outside boundary mechanically
true; are bounded contexts justified by language and model authority; are
endpoints and framework entrypoints thin; is concrete construction owned by an
application entry point; are small and non-hexagonal projects spared
ceremony; are frontend route, feature, UI-reuse, state/data, and runtime
owners explicit; do package discovery and boundary checks support the proposed
depth; does the proposal state where the next new file belongs and what it may
import?

## References

- `rules/shape-selection.md` — the core model, the shape table, earned
  hexagons.
- `rules/proposal-contract.md` — scope, inspection, the proposal's required
  parts, anti-patterns.
- `rules/cohesion-and-boundaries.md` — colocated change, sharing, composition
  roots, DDD placement.
- `references/visible-hexagon.md` — backend inside/outside targets.
- `references/backend-patterns.md` — backend grammars by project shape.
- `references/frontend-patterns.md` — frontend and design-system structures.
- `references/enforcement-and-migration.md` — enforcement and migration.
- `references/research-notes.md` — named-approach rationale.
- `references/provenance.md` — upstream source, revision, and licence notice.

Companion skills are optional here. When a module-design, architecture-audit,
seam-finding, or complexity-reduction skill is not installed, apply the rules
directly: design a module's responsibility before placing its files, treat a
repository-wide investment scan as its own evidence-backed exercise, remember
that ports are designed-in seams while structural boundaries still need
mechanical enforcement, and never present a physical move as a net-mechanism
reduction without that separate evidence.
