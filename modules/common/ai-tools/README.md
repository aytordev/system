# AI Tools: Native Gentle AI and Published Skills

Nix installs Pi, the official public Gentle AI CLI **3.7.0**, Engram
**2.0.0-rc.11**, and Node/npm. The official native installer owns the Pi profile,
Shell package, private engine, extensions, and workflow. Building this flake
does **not** install Shell or validate its live runtime/data compatibility.

The Shell package is pinned by upstream's own documented upgrade path,
`pi install npm:gentle-pi@<version>`, so its version lives in
`~/.pi/agent/settings.json` rather than in this flake; a versioned npm spec is
skipped by `pi update`, which is what keeps it from drifting. The pin is
currently **`npm:gentle-pi@3.7.0`**. The banner-filter
merge matches the bare or pinned source and preserves the pin. Updating Shell
is an operator action: run the upstream `pi install` command, then
`gentle-ai sync`.

That pin does not survive on its own. Any `gentle-ai install` — including a
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
| Nix package capabilities | Pi, public `gentle-ai`, Engram, Node/npm, runtime environment |
| Official `gentle-ai install --agent pi` | Native Pi profile, Shell package and private engine, extensions/workflow |
| This `ai-tools/` subtree | Skill ownership catalog, five authored sources, private upstream preparation recipes, and publication |
| `packages/impeccable-{engine,skills}/package.nix` | Direct-import adapters for existing package discovery; no pins or recipe bodies |
| `ai-skills` capability | Catalog-derived neutral collection and recursive Pi file publication |

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

[`catalog.nix`](catalog.nix) is the six-entry, pure-data ownership inventory.
It records source locations, kind, manual update policy, structured origins,
provenance pointers, and Impeccable's skill/engine pins and dependency. It is not a module, runtime
registry, updater, or discovery mechanism. `ai-skills.nix` derives publication
names and sources from it; the existing namespace, paths, and guards do not change.

| Kind | Skills | Maintenance |
| --- | --- | --- |
| `local` | `dotfiles-coder`, `nix` | Edit local content manually; frontmatter and `metadata.json` remain canonical |
| `adapted` | `aytordev-pen-ops`, `skill-creator`, `skill-registry` | Review upstream evidence manually and retain deliberate local contracts |
| `upstream` | `impeccable` | Update catalog pins/hashes manually as a coherent skill-and-engine pair; preserve upstream bytes |

Adapted entries expose `origin.repository`, the upstream content `path`, and
`baseline.{role,revision}`. Their `originalImportRevision` and `lastSyncRevision`
are explicitly null where unknown. Local entries have `origin = null`: no
external update source, including Nix's independently authored implementation.
For every entry, `tracking = null` means no configured branch, release channel,
or feed; `update` describes manual maintenance, not update discovery.

Impeccable's `source.payloadPath` identifies the original upstream skill tree;
`source.subdir` identifies its packaged destination. Its linked engine release
records the verified revision and `tagPrefix`; the download tag is that prefix
plus `engine.version`. Both recipes consume these locations/tag data, keeping
update knowledge in the catalog without rewriting the external payload.

Detailed provenance stays in its existing documents, not a second prose ledger.
Pen's [provenance notice](skills/aytordev-pen-ops/references/provenance.md) records
its concept-level adaptation and MIT notice. The [Nix skill](skills/nix/SKILL.md)
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

Five authored sources (two local, three adapted) remain under
`modules/common/ai-tools/skills/`:

- `aytordev-pen-ops` — Pen session operations from observed capabilities:
  inspection, authorized bounded edits, verification.
- `dotfiles-coder` — repository architecture and configuration patterns.
- `nix` — authoring rules, operational references, and package-diff helper.
- `skill-creator` — local skill authoring and metadata contract.
- `skill-registry` — explicitly invoked local index; session-only by default.

Each source folder is self-contained: standard `SKILL.md` name/description plus
its original rules, references, and scripts. Resolver guidance is bundled in
`skill-registry/references/skill-resolver.md`; no sibling support folder is needed.
`metadata.json` is our authored-source validation convention, not a universal
client requirement.

The sixth skill, **`impeccable`**, comes from
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

| Publication | Path | Enabled when |
| --- | --- | --- |
| Neutral collection | `${config.xdg.dataHome}/aytordev/skills` (normally `~/.local/share/aytordev/skills`) | `ai-skills.enable`, even with Pi disabled |
| Pi / Gentle Shell | `~/.pi/agent/skills/<name>` | `ai-skills.enable` and `pi.enable` |

The neutral collection assembles links to the five authored folders and the
upstream package. Client publication is recursive: each skill directory stays
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
worker/SDD instructions select by task and files, pass exact skill paths, and read
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
   does **not** establish compatibility with our pinned **2.0.0-rc.11** or its data.
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
projections, and isolated dereferenced copies with resolvable support. Retained
AI checks cover the independent six-entry ownership/shape contract (including
invalid catalog fixtures), authored-only dependencies/metadata, and documentation
links. `checks/impeccable` verifies thin adapters, standalone recipe arguments,
adapter/private package identity parity on both platforms, upstream byte fidelity,
and the pinned offline engine; publication checks compare the complete package in neutral/Pi exports
and execute the published and copied launcher without fallback downloads.
Theme transition tests retain real Home Manager collision and orphan-link
coverage using a surviving themed app's managed theme directory (Yazi flavors).
`checks/ai-skills-transition` executes the exact preparation script followed by
the pinned HM collision/link fragments over the synthetic old Pi layout, with
and without Darwin's `hm.old` backups. It also checks foreign-content and backup
refusal. A separate seven-skill per-file fixture verifies removal of both
retired publications with and without `hm.old`, preserving native files and
foreign real-file/symlink replacements. Native profile and memory migration
remain operator actions.

The eleven records under `docs/ai-tools/` describe the retired local dual-client
workflow. They remain historical evidence, not current onboarding instructions.
