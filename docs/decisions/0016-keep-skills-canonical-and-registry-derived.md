# ADR 0016: Keep Skills Canonical and the Registry Derived

Status: Historical / superseded (originally Proposed)
Date: 2026-09-14

> The local workflow below has been retired. See the [current ownership and
> adoption guide](../../modules/common/ai-tools/README.md). Original reasoning
> and references, including removed code, are preserved as historical evidence.

## Decision

Keep **both `skill-creator` and `skill-registry`**, with distinct responsibilities.
`skill-creator` owns authoring and validation of the canonical skill package;
`skill-registry` discovers and indexes that package without rewriting its
instructions. Delegators select exact skill paths, and executors read the selected
`SKILL.md` and the references required for their task. Generated compact summaries
must not replace the original runtime contract. The owner selected this index-first
direction during the extension of [ADR 0015](0015-adopt-executable-ai-workflow-contracts.md).

The overlap to remove is not discovery versus authoring, but the registry acting
as a second author of rules. Keep a single authoring contract, allow progressive
loading, and make index generation deterministic. This preserves the intent of
domain skills while avoiding an expensive model-generated summary at refresh time.
The [implementation plan] tracks migration of every producer and consumer together.

## Responsibility boundaries

| Layer | Owns | Does not own |
| --- | --- | --- |
| `skill-creator` | Package structure, metadata requirements, authoring/update guidance, validation. | Which skills a task should execute. |
| Nix asset catalog | Reproducible bundled resources and client projections at configuration time. | Discovery of arbitrary project skills created later. |
| `skill-registry` | Runtime index of available skills, source/scope, descriptions, exact paths, and freshness. | Reinterpreting skill rules or declaring workflow phases complete. |
| Resolver and client adapter | Select relevant skills, preserve scoped project conventions, resolve native paths. | Replacing canonical content with an authoritative generated digest. |
| Executor | Read the selected contracts and report what it actually loaded. | Starting another lifecycle merely because it loaded a skill. |

The Nix catalog and runtime skill index serve different times and scopes. Reuse
native client discovery when it supplies the required facts; do not add another
scanner merely to mirror it.

## Evidence

Local baseline: `3752d5c43840671467487e9805ef867c2816f5b8`.
Comparison: gentle-ai [`be49554794917ae92a6dc9dbfa2eb3db5cf70084`][gentle-registry].
The local census was evaluated with Nix; the remaining findings come from source
contracts, not a measured claim that summaries have already degraded model output.

| ID | Local finding | Required correction |
| --- | --- | --- |
| K1 | Creator's structure lists `SKILL.md`, scripts, references, and assets, while 16 skills use `rules/`, all 21 have `metadata.json`, and two use `modules/`. | Document the actual supported extensions; this is an incomplete contract, not evidence that these directories are forbidden. |
| K2 | Creator's process requires `init_skill.py` and `package_skill.py`, which are absent from the skill tree. | Provide a tested available mechanism or replace the instruction with the actual repository workflow. |
| K3 | Creator recommends progressive loading and `references/`; registry generates 5–15-line rules and the loading protocol forbids reading originals when those rules are injected. | Index and load original content; migrate the resolver, phase protocol, orchestrator, and review workflow together. |
| K4 | Registry expects text after literal `Trigger:`, but `dotfiles-coder`, `nix`, and creator descriptions do not contain it. Pi's native/configurable roots are not explicit in its scan list. | Parse full descriptions; discover the selected clients' actual roots and scope. Do not require a textual marker as the only route to discovery. |
| K5 | Registry has a session cache but no content/version invalidation contract; global duplicates use first-found order and creator is excluded from domain indexing. | Define deterministic precedence, surface ambiguous/shadowed entries, and distinguish inventory from invocation eligibility. |
| K6 | Registry always writes `.atl/`, may edit `.gitignore`, and saves to Engram whenever available; `sdd-init` repeats this independently of artifact mode. | Make refresh respect the selected persistence contract. Read-only listing and `none` must not write a registry or edit project files. |
| K7 | Name/description are duplicated in JSON metadata and frontmatter; convention scanning includes every path referenced by a root index. | Choose canonical metadata and validate or derive duplicates; preserve subtree scope instead of applying every referenced convention globally. |

Evidence: [creator structure], [creator process], [progressive loading],
[registry scan], [registry output], [registry persistence], [loading protocol],
[resolver], and [convention scan].

## Alternatives considered

| Choice | Benefit | Cost / reason for disposition |
| --- | --- | --- |
| Merge creator and registry | One entry point. | Mixes infrequent authoring with frequent discovery and does not solve competing sources of truth; rejected. |
| Keep authoritative compact summaries | Small per-delegation payload. | Loses conditions/references, adds summary generation and invalidation, and may distort meaning; rejected as the default. |
| Keep summaries as optional aids | Could reduce repeated reading. | Adds another cache and equivalence problem; defer until measurements justify it, never make the digest authoritative. |
| Index exact paths and load selected contracts | Preserves author intent and enables deterministic refresh. | Children spend reads/tokens on selected content; mitigate through concise entry points and on-demand references. Selected. |

## Consequences

- Preserve the existing directory layout during migration. Formalize optional
  `rules/`, `modules/`, resources, and metadata rather than moving files to imitate
  another repository. `SKILL.md` remains the portable entry point.
- Align metadata/provenance with actual sources and licenses. Derive or validate
  `metadata.json` while it has consumers; do not silently remove compatibility data.
- Apply the pinned-bundle migration policy in
  [ADR 0017](0017-migrate-ai-skills-as-pinned-compatible-bundles.md): updated
  authoring/loading contracts and their consumers must reach deployment together.
- Migrate `injected`/compact-rules consumers to one versioned loading result that
  distinguishes paths supplied from files actually read. Old caches must be
  rejected or regenerated; they cannot silently satisfy the new contract.
- Support configured Pi/OpenCode roots, Nix symlinks, project precedence, explicit
  duplicate handling, and source freshness. An index cache is not a memory backend.
- Keep phase-only SDD skills distinguishable from automatically selected domain
  skills. Inventory and dependency checks still see every skill; avoid silently
  dropping arbitrary user skills solely because of a reserved name prefix.
- Keep skill audit/update guidance in creator initially. gentle-ai's additional
  [skill-improver] is useful prior art, but creating a third local owner would
  duplicate creator's existing update responsibility without demonstrated need.
- gentle-ai has already adopted [index-first loading] and a [native indexer] with
  content-based invalidation, symlink handling, and read-only listing. Adopt those
  principles, not its unconditional `.atl/` writes or all-client scan policy.

[implementation plan]: ../ai-tools/implementation-plan.md
[creator structure]: ../../modules/common/ai-tools/skills/skill-creator/rules/anatomy-structure.md
[creator process]: ../../modules/common/ai-tools/skills/skill-creator/rules/process-steps.md
[progressive loading]: ../../modules/common/ai-tools/skills/skill-creator/rules/principles-progressive.md
[registry scan]: ../../modules/common/ai-tools/skills/skill-registry/rules/execution-scan-skills.md
[registry output]: ../../modules/common/ai-tools/skills/skill-registry/rules/execution-write-registry.md
[registry persistence]: ../../modules/common/ai-tools/skills/skill-registry/rules/execution-persist.md
[loading protocol]: ../../modules/common/ai-tools/skills/_shared/skill-loading.md
[resolver]: ../../modules/common/ai-tools/skills/_shared/skill-resolver.md
[convention scan]: ../../modules/common/ai-tools/skills/skill-registry/rules/execution-scan-conventions.md
[gentle-registry]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/skill-registry/SKILL.md
[index-first loading]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/docs/skill-registry.md
[native indexer]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/skillregistry/registry.go
[skill-improver]: https://github.com/Gentleman-Programming/gentle-ai/blob/be49554794917ae92a6dc9dbfa2eb3db5cf70084/internal/assets/skills/skill-improver/SKILL.md
