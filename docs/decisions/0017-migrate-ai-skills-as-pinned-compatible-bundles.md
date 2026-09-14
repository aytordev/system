# ADR 0017: Migrate AI Skills as Pinned Compatible Bundles

Status: Proposed
Date: 2026-09-14

## Decision

Use current gentle-ai skills as the migration baseline, frozen at a reviewed
commit, and update them in **compatible bundles** with their shared protocols,
resources, runtime dependencies, and client adapters. Keep a small, traceable
`system` derivation rather than indefinitely preserving older local instructions
or replacing the entire skills directory without checking its contracts.

This makes newer upstream behavior usable and future updates reviewable. A bundle
may span several implementation tasks, but its producer/consumer contract must be
coherent before deployment. [ADR 0015](0015-adopt-executable-ai-workflow-contracts.md)
owns workflow policy and the pending engine choice;
[ADR 0016](0016-keep-skills-canonical-and-registry-derived.md) owns canonical
authorship and index-first loading. The [proposal] explains the value and the
[implementation plan] owns migration tasks and evidence.

## Source and compatibility policy

- At migration start, review changes since the audited gentle-ai revision
  `be49554794917ae92a6dc9dbfa2eb3db5cf70084` and freeze the chosen current revision.
  That audit pin is evidence, not a claim that it will still be the newest version.
  Record a release tag too when applicable; the exact commit remains authoritative.
- Use one gentle-ai revision for interdependent SDD assets. Keep khanelinix-derived
  methods separately pinned to their own source. Do not mix incompatible shared
  protocols, validators, or model-tier projections from unrelated revisions.
- Record source repository, commit, original path, license/attribution, local path,
  dependency bundle, adaptation rationale, and verification for each adopted item.
  Classify behavior as preserved, adapted, or explicitly deferred; a deferment must
  not be advertised as a supported capability.
- Preserve local policy through configuration and adapters where possible. Keep
  unavoidable content patches explicit. Use the authoring contract to organize
  current content; retaining `rules/` or `modules/` does not require retaining
  obsolete instructions.
- If compatibility work rejects the selected revision, deliberately choose a new
  candidate and rerun affected comparisons/checks. Do not allow `main` or `latest`
  to move the target during implementation or at runtime.

## Migration bundles

| Bundle | Must move together | Reason |
| --- | --- | --- |
| Authoring | Creator guidance, supported package layout, metadata rules, and validation. | The contract must describe the resources actually deployed. |
| Discovery/loading | Registry, resolver, executor loading, `skill_resolution`, cache migration, and SDD/review consumers. | Mixing compact-rule producers with path-loading consumers loses the contract. |
| SDD execution | Selected phase skills, `_shared` protocols, templates, strict-mode resources, commands/agents, and engine contracts. | Current upstream phases require specific state, locators, validators, and result shapes. |
| Auxiliary workflows | Each selected inherited workflow with its required dependencies and local policy adaptations. | Updating PR/review/writing methods must preserve explicit local authority and scope. |
| New methods | Only approved additions with a concrete invocation boundary and dependency closure. | A larger upstream catalog is not itself a reason to deploy every skill. |

Core repairs can land before optional capability growth. Compatibility is required
for each deployed bundle, not a mandate to combine all work into one large diff.

## Engine-dependent migration

| Selected engine | Migration approach | Tradeoff |
| --- | --- | --- |
| Pinned gentle-ai CLI | Align the selected assets with the CLI's exact runtime/schema contract; retain a local Pi adapter and configure local policy where supported. | Less divergence, but stronger coupling to upstream schemas, packaging, and behavior. |
| Local bounded engine | Port current skill behavior to equivalent local interfaces, with an explicit compatibility/adaptation map and shared Pi/OpenCode contract tests. | More control, but local ownership of semantic parity and future update work. |

T19 chooses the engine after a comparison/prototype. Neither branch is authorized
merely by selecting newer skills. Copying native CLI calls into prompts before a
compatible engine exists does not complete migration.

## Existing state and rollback

Classify existing registry caches, task/progress artifacts, spec scenario syntax,
verification reports, and backend locators as directly compatible, convertible,
or requiring a retained legacy reader/manual decision. Test migrations on copies;
retain original bytes/observation references and a recovery path. Do not delete
memory or turn historical verification into a PASS for the current candidate.

Code rollback and data rollback are distinct. Restoring a Home Manager generation
does not reverse an artifact or database format change. A bundle cannot be
deployed to either client until its read/continue behavior and rollback boundary
are known. Unknown legacy formats must stop with a useful explanation rather than
silently restarting a change or overwriting its artifacts.

## Consequences

- Benefit: source revisions and local adaptations make updates reproducible and
  reviewable, while bundle checks prevent mixed-version protocol failures.
- Cost: provenance, compatibility fixtures, and artifact migration must be
  maintained. Keep this record beside the existing catalog; do not create a
  marketplace or a generic synchronization framework to perform one migration.
- Validate structural contracts and actual Pi/OpenCode behavior. Tests with a
  scripted provider establish execution compatibility; selected live-model
  scenarios assess instruction quality separately.
- Future updates compare the previous source revision, the new source revision,
  and local adaptations. Revalidate affected bundles, then deliberately advance
  the recorded pin. Remove a local workaround only after its replacement is
  demonstrated and its removal is in scope.

[proposal]: ../../modules/common/ai-tools/proposal.md
[implementation plan]: ../../modules/common/ai-tools/implementation-plan.md
