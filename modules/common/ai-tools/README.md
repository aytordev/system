# AI Tools: Native Gentle AI and Published Skills

Nix installs Pi, the official public Gentle AI CLI **5.0.0**, Engram
**3.7.2**, the GGA review CLI **2.10.1**, and Node/npm. The official native
installer owns the Pi profile, Shell package, private engine, extensions, and
workflow. Building this flake does **not** install Shell or validate its live
runtime/data compatibility.

The matching upgrade target is [Gentle Shell **5.0.0**](https://github.com/Gentleman-Programming/gentle-shell/releases/tag/v5.0.0),
which ships the private Gentle AI **5.0.0** runtime. This is a target, not a
claim about the installed profile. The operator pins Shell with upstream's
`pi install npm:gentle-pi@5.0.0`; the version lives in `~/.pi/agent/settings.json`,
not in this flake. `pi update` skips versioned npm specs, and the banner-filter
merge matches the bare or pinned source and preserves the pin. Upstream tested
Shell 5.0.0 with Pi **1.6.0**; its npm manifest declares Pi **≥1.2.0** and Node
**`^22.19.0 || >=23.6.0`**. After installing, approve the version-keyed script
with `npm install-scripts approve gentle-pi@5.0.0` (postinstall provisions the
private engine), restart Pi, then run `gentle-ai sync`.

The Engram pair is unchanged: core **3.7.2** with the **`gentle-engram@0.8.0`**
companion, installed through the core's own `engram setup pi`. Engram validates
core and companion together. `settings.json` may hold exactly one versioned
`npm:gentle-engram@<version>` entry: a bare `npm:gentle-engram` beside it is a
duplicate registration of the same server, not a fallback.

Shell 4 raises its native prerequisites, and Shell 4.2 raises the Pi floor
again: the host Pi must be at least **1.2.0** (Shell 4.0 accepted **0.99.1**)
and Node at least **22.19**. Its workflow is ODD-only: v4 retired
upstream's Strict TDD selector and the SDD/OpenSpec workflow, and this
repository must not re-add them. The v4 `sync` also retires the
`pi-mcp-adapter` extension in favor of Pi's built-in MCP client; sequence that
replacement only after the live profile already satisfies the Pi prerequisite.

Shell 4.1 changes what this profile does automatically: native review now
fires only for **`high`** risk — a `medium` candidate reports
`review_due: false` with `under_budget` and gets no automatic review — and the
review provider contract moved to **1.3.0**, an additive change. After the
upgrade, `gentle-ai sync` retires installed Gentle-owned SDD artifacts and
refreshes orchestrator prompts, permissions, and reviewer assets.

Shell 4.3 pins its private engine at Gentle AI **4.2.0**; Shell **4.4.0**
through **4.6.0** bundle Gentle AI **4.3.1**; Shell **4.7.0** pins Gentle AI
**4.4.0**, Shell **4.8.0** pins Gentle AI
**4.5.0**, and Shell **4.9.0** pins Gentle AI **4.6.0**. Engine
4.2.0 moved the review provider contract, from 1.3.0 to **1.4.0**, which
adds a `routing` bundle entry carrying Gentle AI's ODD routing canon; Shell
renders its own ODD steps from that block instead of hand-copying them. Engine
4.5.0 moves the same contract to **1.5.0** with one additive stop reason, so a
review that stops at `correction_required` or `escalated` can return its
non-blocking findings; the review integration contract stays at `v2`, the
capability identity at `capabilities/v2.6`. Engine
4.6.0 moves the same contract to **1.6.0**: when a worker exhausts its
corrections, the orchestrator becomes responsible for what happens next. The
module path stayed at `/v4` in that release. [Gentle AI **5.0.0**](https://github.com/Gentleman-Programming/gentle-ai/releases/tag/v5.0.0)
moves the Go module to `/v5` and removes legacy v1 review authority. The provider
bundle stays at **1.6.0** with updated routing and orchestration assets. The
`capabilities/v2.6` identifier is unchanged, but its payload is now compact-only
and native STATUS returns `v9`; refresh capability discovery rather than assuming
the old feature set still applies.

A versioned Shell pin does not survive on its own. Any `gentle-ai install` — including a
narrow `--component persona` run — re-registers the agent's npm packages and
writes the entry as the bare `npm:gentle-pi`, dropping the `@<version>` that
keeps `pi update` from moving it. `--dry-run` does not warn: it reports
`Components order: persona` and `Auto-added dependencies: none` even when the
package entry is rewritten. Re-run `pi install npm:gentle-pi@<version>` after any
`gentle-ai install`; that restores the pin, keeps the banner filter, and `sync`
then leaves it alone.

The persona is upstream-owned for the same reason `settings.json` is, and its
lever is upstream's own flag: `gentle-ai install --agent pi --component persona
--persona <name>` persists the choice where `sync` reads it, so `sync` afterwards
reports no managed actions and never rewrites the file. This module must not
declare it — a Nix-declared `~/.pi/gentle-ai/persona.json` would have two writers
and oscillate between activation and `sync`. The value on this machine is
`neutral`.

`~/.pi/agent/npm/package-lock.json` is upstream-owned as well: it records what
`pi install` resolves, and this repository neither declares nor regenerates it.
Running `npm install` there by hand changes it in ways upstream did not —
`--package-lock-only` recomputes the ideal tree and adds uninstalled peer
entries. `gentle-ai sync` also normalizes managed ranges to its own defaults, so
a tighter hand-set range is relaxed on the next `sync`.

The two Gentle AI executables on this machine are **independent pins**, and the
Nix one is not the engine a Pi session runs. The PATH binary
(`/etc/profiles/per-user/<user>/bin/gentle-ai`) comes from this flake's
`packages/gentle-ai` pin and serves operator commands such as `gentle-ai sync`.
The session engine is Shell's *package-local* runtime, resolved by
`lib/gentle-ai-binary.ts` (`gentleAiBinaryPath`) at
`~/.pi/agent/npm/node_modules/gentle-pi/.gentle-ai/v<version>/gentle-ai`, which
never falls back to `PATH`. Bumping the flake pin therefore moves the operator
CLI only; changing the engine requires the Shell bump, so the two can legitimately
sit at different versions.

Shell ≥ 3.4.0 registers the first-party `ask_user_question` tool, and Pi refuses
to load two extensions that register the same tool name. A competing provider
such as `@juicesharp/rpiv-ask-user-question` must therefore not be installed
(`pi remove npm:@juicesharp/rpiv-ask-user-question`); Shell owns the name.

Shell 3.5.0 added upstream's `gentle-shell` launcher. It ships as a package
`bin`, so it is **not** on the login `PATH`: Pi prepends its own `<agent dir>/bin`
only for the processes it spawns and does not link package bins into it, and
`npm prefix -g` resolves inside the read-only Nix store, so upstream's documented
`npm i -g gentle-pi` path cannot apply here. Reach it by absolute path
(`~/.pi/agent/npm/node_modules/.bin/gentle-shell`) or publish that directory on
the session path. `gentle-shell --link` reuses `~/.pi/agent`; the default mode is
an isolated `~/.gentle-shell/agent` home that carries none of the Nix-managed
surface (local skills, `models.json`, the startup header, Engram).

## Ownership

| Owner | Surface |
| --- | --- |
| Nix capabilities | Pi, public `gentle-ai`, Engram, Node/npm, runtime environment, and Pi's palette-generated `themes/aytordev.json`; activation seeds only an absent `theme` key |
| Official `gentle-ai install --agent pi` | Native Pi profile, Shell package and private engine, extensions/workflow |
| This `ai-tools/` subtree | Skill ownership catalog, fifty-five authored sources, private upstream preparation recipes, and publication |
| `packages/{impeccable-engine,impeccable-skills,modern-web-guidance}/package.nix` | Direct-import adapters for existing package discovery; no pins or recipe bodies |
| `ai-skills` capability | Catalog-derived neutral collection, recursive Pi file publication, and the declared guidance CLI dependency for Pi |

The development suite enables these capabilities with overridable defaults.
The distributor lives in `modules/common/ai-tools/ai-skills.nix`, explicitly
imported by `libraries/system/common/default.nix` through `mkHomeModules`.
It is a Home Manager module despite its shared source location; its existing
`aytordev.programs.terminal.tools.ai-skills` option namespace is retained.
Pi exposes only `enable` and `package`. There is no local workflow adapter,
launcher, updater, generated prompt, or activation-time native installer.

Engram exports `ENGRAM_BIN` for native subprocess selection,
`ENGRAM_DATA_DIR=$XDG_DATA_HOME/engram`, and `ENGRAM_NO_UPDATE_CHECK=1`.
`GENTLE_AI_NO_SELF_UPDATE=1` protects the Nix-owned public CLI. Update Nix-owned
executables through their Nix pins; native Shell/package/private-engine updates
remain upstream-owned. This replacement does not migrate Engram data.

## Skill ownership and updates

[`catalog.nix`](catalog.nix) is the fifty-eight-entry, pure-data ownership inventory.
It records source locations, kind, manual update policy, structured origins,
provenance pointers, and the packaged skill releases and runtime dependencies. It is not a module, runtime
registry, updater, or discovery mechanism. `ai-skills.nix` derives publication
names and sources from it; the existing namespace, paths, and guards do not change.

| Kind | Skills | Maintenance |
| --- | --- | --- |
| `local` | `dotfiles-coder`, `nix` | Edit local content manually; frontmatter and `metadata.json` remain canonical |
| `adapted` | `acceptance-review`, `api-design`, `aytordev-pen-ops`, `bff-design`, `bff-entry-points`, `characterisation-tests`, `ci-debugging`, `cli-design`, `codebase-design`, `debugging`, `diagrams`, `domain-driven-design`, `double-check`, `evaluate-existing-solutions`, `event-sourcing`, `expectations`, `find-gaps`, `find-skills`, `finding-seams`, `folder-structure`, `front-end-testing`, `functional`, `graph-engineering`, `hexagonal-architecture`, `improve-codebase-architecture`, `mutation-testing`, `observability`, `panel-review`, `planning`, `production-parity-skill-builder`, `react-performance`, `react-testing`, `reduce-system-complexity`, `refactoring`, `render-code-shape`, `secure-oauth-oidc`, `skill-creator`, `skill-registry`, `specification`, `stack-pull-requests`, `story-splitting`, `storyboard`, `structure-codebase`, `tdd`, `teach-me`, `technical-writing`, `test-design-reviewer`, `testing`, `twelve-factor`, `typescript-strict`, `ubiquitous-language`, `wtf`, `xstate` | Review upstream evidence manually and retain deliberate local contracts |
| `upstream` | `impeccable` | Update catalog pins/hashes manually as a coherent skill-and-engine pair; preserve upstream bytes |
| `packaged-adaptation` | `chrome-extensions`, `modern-web-guidance` | Update the shared GoogleChrome pin manually and recheck the offline and safety adaptations |

Adapted entries expose `origin.repository`, the upstream content `path`, and
`baseline.{role,revision}`. Their `originalImportRevision` and `lastSyncRevision`
are explicitly null where unknown; the fifty `import-baseline` entries record the
exact revision their bytes were
authored from, because that revision is known rather than inferred. Local entries
have `origin = null`: no external update source, including Nix's independently
authored implementation.
For every entry, `tracking = null` means no configured branch, release channel,
or feed; `update` describes manual maintenance, not update discovery.

Impeccable's `source.payloadPath` identifies the original upstream skill tree;
`source.subdir` identifies its packaged destination. Its linked engine release
records the verified revision and `tagPrefix`; the download tag is that prefix
plus `engine.version`. Both recipes consume these locations/tag data, keeping
update knowledge in the catalog without rewriting the external payload.

Detailed provenance stays in its existing documents, not a second prose ledger.
Pen's [provenance notice](skills/aytordev-pen-ops/references/provenance.md) records
its concept-level adaptation and MIT notice. Every skill adapted from
`citypaul/.dotfiles` bundles its own notice with the imported revision, for
example the [functional](skills/functional/references/provenance.md) and
[ci-debugging](skills/ci-debugging/references/provenance.md) ones. The
[Nix skill](skills/nix/SKILL.md)
records independent local implementation with behavior-level inspiration, not
an imported upstream skill. The creator/registry
[historical comparison](../../../docs/ai-tools/upstream-sources.md) uses Gentle AI
v2.9.0 as an audit baseline: it does **not** identify their original-import or
last-synchronized revisions, which remain unknown. No tracking branch or
automatic synchronization policy is implied.

Private standalone `callPackage` recipes live in
[`upstream/impeccable/engine.nix`](upstream/impeccable/engine.nix) and
[`upstream/impeccable/skill.nix`](upstream/impeccable/skill.nix). They consume
catalog pins without Home Manager/config dependencies. The public package files
are direct imports so `callPackage` still sees the recipes' named arguments.
Package discovery, overlays, and public output names remain unchanged.

For an approved update, edit content or pins at these owners, retain required
notices, and run inventory, metadata/dependency, publication, and Impeccable
checks. Inventory expansion additionally requires explicit approval and updated
independent expectations; see the
[creator workflow](skills/skill-creator/rules/process-steps.md).

## Published skills

Fifty-five authored sources (two local, fifty-three adapted) remain under

- `acceptance-review` — read-only review of a change against its acceptance contract.
- `api-design` — HTTP API contracts: compatibility, errors, idempotency, quotas
- `aytordev-pen-ops` — Pen session operations from observed capabilities:
- `bff-design` — backend-for-frontend shape, adoption, and ownership
- `bff-entry-points` — endpoint classification, prepared registrars, authorization boundaries
- `characterisation-tests` — pins existing behaviour before changing untested code.
- `ci-debugging` — CI failure diagnosis with provider evidence and environment deltas.
- `cli-design` — streams, exit codes, secrets, composability, stability
- `codebase-design` — in-process module and package contracts, plus deep-module consolidation
- `debugging` — preserve evidence, reproduce and localize, one hypothesis at a time
- `diagrams` — evidence and authority, accessibility, validation of diagrams
- `domain-driven-design` — bounded contexts, aggregates, domain services, and placement
- `dotfiles-coder` — repository architecture and configuration patterns.
- `double-check` — independent second review of a finished artifact.
- `evaluate-existing-solutions` — evidence-based build-versus-adopt evaluation.
- `event-sourcing` — event modelling, decider and rehydration, projections, versioning
- `expectations` — routes a learning to the artifact that owns its truth.
- `find-gaps` — tightens a written artifact one confirmed answer at a time.
- `find-skills` — verification before recommending, installation authorization
- `finding-seams` — introduces seams so untestable dependencies become controllable
- `folder-structure` — deprecation alias that delegates the retired convention and stops when alone
- `front-end-testing` — browser-observable claims, harness choice, evidence boundaries.
- `functional` — immutable domain data, pure-function boundaries, composition,
- `graph-engineering` — graph-derived parallel skill application and impact analysis
- `hexagonal-architecture` — ports and adapters, wiring, testing boundaries, anti-patterns
- `improve-codebase-architecture` — ranks where architecture investment pays off
- `mutation-testing` — mutation gate, survivor triage, and diff-scoped runs.
- `nix` — authoring rules, operational references, and package-diff helper.
- `observability` — wide events, SLOs and alerting, telemetry hygiene and placement
- `panel-review` — multi-lens review with adversarial verification to PR-readiness.
- `planning` — vertical slices, known-good increments, delivery and review cadence
- `production-parity-skill-builder` — derives a skill from a production system, parity map first
- `react-performance` — measurement method first, house rules, anti-patterns
- `react-testing` — React component behaviour, integrity, and browser-mode rules.
- `reduce-system-complexity` — whole-path reduction of branches, states, layers and jobs
- `refactoring` — behaviour-preserving assessment with a labelled reply contract.
- `render-code-shape` — citation contract, render format, findings and boundaries
- `secure-oauth-oidc` — RFC 9700 boundaries, OIDC validation, and false assurances
- `skill-creator` — local skill authoring and metadata contract.
- `skill-registry` — explicitly invoked local index; session-only by default.
- `specification` — example map, accountable review, spec review template
- `stack-pull-requests` — units and decisions, stack design, verification, merge order
- `story-splitting` — capability slices and the quality of a split story
- `storyboard` — page structure, embedding safety, review lifecycle
- `structure-codebase` — repository tree and package placement decisions
- `tdd` — RED-GREEN-REFACTOR with a bounded loop and one mutation gate.
- `teach-me` — tutoring protocol where the learner does the thinking
- `technical-writing` — reader-first structure, receipts for claims, docs as behaviour
- `test-design-reviewer` — eight-property test review with file-level evidence.
- `testing` — behaviour-first tests, factories, and mutation-aware planning.
- `twelve-factor` — twelve-factor conformance for deployable services
- `typescript-strict` — strict-mode boundary typing, declaration forms, schema
- `ubiquitous-language` — one glossary per bounded context, mechanically enforced
- `wtf` — plain-language explanation of unfamiliar code or terms
- `xstate` — statechart modelling before code, actors, and diagrams


Each source folder is self-contained: standard `SKILL.md` name/description plus
its original rules, references, and scripts. Resolver guidance is bundled in
`skill-registry/references/skill-resolver.md`; no sibling support folder is needed.
`metadata.json` is our authored-source validation convention, not a universal
client requirement.

**`impeccable`** comes from
`${pkgs.aytordev.impeccable-skills}/share/impeccable`, not the authored tree.
The catalog pins upstream **4.4.0** at commit
`114ea1d3838fca73b253af45f873b9c4f5f213c8`, preserving all 54 payload files
(including 42 references) unchanged. It adds only upstream LICENSE/NOTICE.md and
the official **0.1.6** engine at the launcher's supported sibling path,
`scripts/bin/{darwin-arm64,linux-x64}/impeccable`. There is no local metadata,
prompt override, updater, or workflow wrapper. See the
[catalog](catalog.nix) for pin ownership and the
[package guide](../../../packages/README.md) for the external bundle contract.

Impeccable replaces `aytordev-interface-design` and `aytordev-design-system`.
`aytordev-pen-ops` and unrelated skills remain unchanged. Upstream guidance does
not establish that a host has browser/Pen tools or authorize their use.

**`modern-web-guidance`** and **`chrome-extensions`** come from the pinned
GoogleChrome **1.0.2** npm release, prepared by Nix without npm lifecycle scripts.
The first skill uses the CLI on `PATH` when Pi and `ai-skills` are both enabled:

```sh
modern-web-guidance search "light dismiss dialog"
modern-web-guidance retrieve "light-dismiss-a-dialog"
```

Search, list, and retrieve use bundled data; the CLI does not download updates,
report telemetry, or install skills. The neutral collection includes both folders
when Pi is disabled but does not add the CLI to `PATH`. A copied skill retains its
documents and license notices; running search still requires the Nix CLI.
The extensions skill retains the Manifest V3 references and recommends strict
CSP, isolation, and validated messages instead of executing untrusted code.
See the [release and adaptation provenance](upstream/modern-web-guidance/PROVENANCE.md).

| Publication | Path | Enabled when |
| --- | --- | --- |
| Neutral collection | `${config.xdg.dataHome}/aytordev/skills` (normally `~/.local/share/aytordev/skills`) | `ai-skills.enable`, even with Pi disabled |
| Pi / Gentle Shell | `~/.pi/agent/skills/<name>` | `ai-skills.enable` and `pi.enable` |

The neutral collection assembles links to the fifty-five authored folders and
three packaged skills. Client publication is recursive: each skill directory stays
real and its managed files are symlinks,
matching Pi's native per-file layout. The client profile and whole skills root
remain writable for native owners; additional native files survive. Source edits
reach these linked locations on Nix activation; client reload behavior is native.
`~/.agents/skills` is not a local publication target: upstream compatibility
refreshes may write unnamespaced skills there.

Shell 3.5's packaged names are `gentle-ai-skill-creator` and
`gentle-ai-skill-registry`, even though their folder names omit the prefix.
Pi's `/skill:skill-creator` and `/skill:skill-registry` select our local names;
Shell's `/skill-creation` selects its upstream namespaced skill. Shell's registry
excludes literal `skill-registry`, but native Pi discovery still sees it.
Shell natively indexes user Pi skills, follows links, and its orchestrator/generic
worker instructions select by task and files, pass exact skill paths, and read
originals. This repository publishes knowledge; upstream performs that dynamic
selection and execution. Native materialized review has no tools, and inclusion
of these skill contents there is unverified: this is not an all-subagent guarantee.

The local registry writes only on explicit request: `file` mode uses
`.ai-local/skill-registry.md`, and `engram` mode uses topic
`aytordev/local-skill-registry`. It never writes Shell's generated
`.atl/skill-registry.md`, injects prompts, or schedules refreshes. Its scanner
reads full `SKILL.md` frontmatter and follows links; upstream Impeccable needs no
`metadata.json` or registry adapter. Native Pi likewise discovers the entry point.

## Other clients: Pen manual import

The [Agent Skills format](https://agentskills.io/specification) makes the folders
portable; discovery, injection, and available tools are host-specific.
`dotfiles-coder` describes `aytordev/system`, not arbitrary projects. Nix operations
need a filesystem, terminal, and Nix; the report helper also needs Python 3.
Creator edits need filesystem writes; registry Engram persistence is optional and
needs Engram tools. Models without those capabilities can use knowledge but must
not claim they executed scripts or verified changes. No credentials or private
Engram data are exported with this collection.

[Pen's documented flow](https://docs.pen.dev/core-concepts/ai-agents#use-skills)
is **Add SKILL.md file…** from the slash menu. Select a skill's `SKILL.md` or
containing folder; the folder name becomes its menu name. Keep that location,
and re-add the same file after edits to reload it. Removing a skill's entry in
Pen with its trash icon does not delete the skill folder or its files from
disk. Pen does not document automatic
scanning of our collection or `.agents`, and its `read_skill()` MCP tool serves
Pen's design instructions, not this custom collection.

Pen's handling of Nix/store symlinks is unverified. If importing directly from the
neutral collection is unsuitable, make an ordinary self-contained copy outside
managed profiles. These commands are operator instructions, not activation code:

```sh
collection="${XDG_DATA_HOME:-$HOME/.local/share}/aytordev/skills"
export_dir="$(mktemp -d "$HOME/aytordev-skills-export.XXXXXX")"
for name in aytordev-pen-ops dotfiles-coder impeccable nix skill-creator skill-registry; do
    cp -RL "$collection/$name" "$export_dir/$name"
    chmod -R u+w "$export_dir/$name"
done
```

Import a folder from that export and keep it while registered. Copies do not
auto-refresh: after a source update and activation, explicitly export again and
re-add the chosen file in Pen. Checks prove copied resources remain complete;
actual Pen import and model capabilities have not been validated. Impeccable's
copied launcher is checked with the native Darwin sibling engine offline; Linux
runtime execution and browser/design operations remain unverified. Copies carry
the engine for the package's target platform, not a universal binary.

## Adoption: backup, prepare, activate, onboard

These are operator instructions; repository verification does not execute them.

**Already using per-file skill links?** The Impeccable replacement needs no
preparation script or native reinstall. On the next reviewed activation, Home
Manager removes unchanged managed links for the two retired skills and publishes
Impeccable. Native additions and foreign replacements remain untouched; a
foreign `SKILL.md` can therefore keep a retired name discoverable. Inspect those
files yourself rather than deleting their folders. Historical whole-root
migration instructions below still apply only to the older layout.

1. **Before activation or onboarding, make consistent backups of both Pi and
   Engram.** Stop all Engram writers: Pi and other clients, MCP children,
   HTTP servers, background services, and any sync/import jobs. Prevent automatic
   restarts, then snapshot the **entire closed** `ENGRAM_DATA_DIR` (normally
   `$XDG_DATA_HOME/engram`) into a new private backup location, including any
   remaining WAL/SHM files. Verify the saved database's integrity before
   proceeding. Alternatively, use SQLite's online backup API for a consistent
   database snapshot, with a separate copy of supporting files; **never copy
   only an active database file**. Keep writers stopped during the transition.
   Back up the Pi profile with managed links resolved to preserve their contents,
   and record native user files. The HM-generated Nan `models.json` will cease
   to be managed; its referenced SOPS secret is not deleted by this change.
2. **Prepare the old Pi skill root before activation.** If
   `~/.pi/agent/skills` is the old whole-directory HM symlink, run from this repo:

   ```sh
   bash modules/common/ai-tools/scripts/prepare-pi-skills.sh
   ```

   This one-time source script is neither installed nor an activation hook. It
   accepts only the exact `/nix/store/<hash>-home-manager-files/.pi/agent/skills`
   link with a whole-directory source entry containing the four retained skills.
   It refuses symlinked parent directories, foreign roots, and **any existing**
   `skills.hm-before-native` backup. It reserves that private directory and moves
   the link itself to `skills.hm-before-native/skills`, without following it or
   removing its contents. Stop on any refusal; do not force or delete the
   conflicting path. A fresh or already-real skill root needs no preparation.
   The preserved link is not a substitute for the content backup in step 1.
3. Activate the reviewed Nix generation. Pi receives the per-file recursive
   layout after preparation, while Home Manager preserves native additions. On
   Darwin, an unrelated real-file collision can be backed up as `.hm.old`; an
   existing regular backup blocks activation. Inspect any collision rather
   than forcing it. Do not recursively delete the profile.
4. **Start a new terminal with a fresh login environment** after activation;
   if the terminal application still inherits old session variables, log out
   and back in. A nested shell inherits variables and Home Manager's session
   guard, so it is not evidence of a refreshed environment. Diagnose selection with
   `command -v pi gentle-ai engram node npm` and inspect `ENGRAM_BIN`,
   `ENGRAM_DATA_DIR`, `ENGRAM_NO_UPDATE_CHECK`, and `GENTLE_AI_NO_SELF_UPDATE`.
   Confirm the intended Nix executables win over older copies, `ENGRAM_BIN`
   selects that same Engram, the directory is the backed-up one, and both no-update
   variables equal `1` before resuming any writers.
5. Run **`gentle-ai install --agent pi`** using that public CLI and environment.
   The stable official installer reuses Engram on `PATH`; successful installation
   does **not** establish live compatibility with the pinned Engram **3.7.2**
   or its data.
   Complete provider configuration and authentication through native setup;
   Nix no longer supplies Pi models or credentials. Review the backup when
   restoring provider preferences rather than copying the retired extensions.
6. Start Pi and check native Shell loading and the local skill commands.
   Live Shell installation, model calls, and data compatibility require this
   separate operator verification.

## Verification and history

`checks/gentle-ai-engine` now checks package enable/disable/override behavior,
environment, no profile/adapter ownership, and exact current skill-list publication with
client guards, standalone neutral export, custom HOME/XDG paths, byte-for-byte
projections, and isolated dereferenced copies with resolvable support. It also
regresses the pinned public CLI's exact `version` output by running the real
binary offline under isolated HOME/XDG with the self-update guard, expecting
no native onboarding profile. Retained
AI checks cover the independent fifty-eight-entry ownership/shape contract (including
invalid catalog fixtures), authored-only dependencies/metadata, and documentation
links. `checks/impeccable` verifies thin adapters, standalone recipe arguments,
adapter/private package identity parity on both platforms, upstream byte fidelity,
and the pinned offline engine; publication checks compare the complete package in neutral/Pi exports
and execute the published and copied launcher without fallback downloads.
`checks/modern-web-guidance` verifies the legal notices, offline CLI search and
retrieval, absence of runtime network/installer actions, and the adapted
extension instructions. Publication checks cover both GoogleChrome folders and
the CLI's enable guards. Theme transition tests retain real Home Manager collision and orphan-link
coverage using a surviving themed app's managed theme directory (Yazi flavors).
`checks/ai-skills-transition` executes the exact preparation script followed by
the pinned HM collision/link fragments over the synthetic old Pi layout, with
and without Darwin's `hm.old` backups. It also checks foreign-content and backup
refusal. A separate nine-skill per-file fixture verifies removal of both
retired publications with and without `hm.old`, preserving native files and
foreign real-file/symlink replacements. Native profile and memory migration
remain operator actions.

The eleven records under `docs/ai-tools/` describe the retired local dual-client
workflow. They remain historical evidence, not current onboarding instructions.
