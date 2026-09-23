# AI Tools: Native Gentle AI and Local Skills

Nix installs Pi, the official public Gentle AI CLI **3.6.0**, Engram
**2.0.0-rc.11**, and Node/npm. The official native installer owns the Pi profile,
Shell package, private engine, extensions, and workflow. Building this flake
does **not** install Shell or validate its live runtime/data compatibility.

The Shell package is pinned by upstream's own documented upgrade path,
`pi install npm:gentle-pi@<version>`, so its version lives in
`~/.pi/agent/settings.json` rather than in this flake; a versioned npm spec is
skipped by `pi update`, which is what keeps it from drifting. The banner-filter
merge matches the bare or pinned source and preserves the pin. Updating Shell
is an operator action: run the upstream `pi install` command, then
`gentle-ai sync`.

## Ownership

| Owner | Surface |
| --- | --- |
| Nix package capabilities | Pi, public `gentle-ai`, Engram, Node/npm, runtime environment |
| Official `gentle-ai install --agent pi` | Native Pi profile, Shell package and private engine, extensions/workflow |
| Local `ai-skills` capability | Neutral skill collection and thin recursive Pi publication |

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

## Local skills

Sources remain under `modules/common/ai-tools/skills/`:

- `aytordev-design-system` — design-system discovery and evolution: tokens,
  component anatomy/states, adoption and migration.
- `aytordev-interface-design` — interface design and read-only evidence-based
  review for the consuming project's system.
- `aytordev-pen-ops` — Pen session operations from observed capabilities:
  inspection, authorized bounded edits, verification.
- `dotfiles-coder` — repository architecture and configuration patterns.
- `nix` — authoring rules, operational references, and package-diff helper.
- `skill-creator` — local skill authoring and metadata contract.
- `skill-registry` — explicitly invoked local index; session-only by default.

Each source folder is self-contained: standard `SKILL.md` name/description plus
its original rules, references, and scripts. Resolver guidance is bundled in
`skill-registry/references/skill-resolver.md`; no sibling support folder is needed.
`metadata.json` is our validation convention, not a universal client requirement.

| Publication | Path | Enabled when |
| --- | --- | --- |
| Neutral collection | `${config.xdg.dataHome}/aytordev/skills` (normally `~/.local/share/aytordev/skills`) | `ai-skills.enable`, even with both clients disabled |
| Pi / Gentle Shell | `~/.pi/agent/skills/<name>` | `ai-skills.enable` and `pi.enable` |

The neutral collection links to the canonical source tree. Client publication is
recursive: each skill directory stays real and its managed files are symlinks,
matching Pi's native per-file layout. The client profile and whole skills root
remain writable for native owners; additional native files survive. Source edits
reach these linked locations on Nix activation; client reload behavior is native.
`~/.agents/skills` is not a local publication target: upstream compatibility
refreshes may write unnamespaced skills there.

Shell 3.4's packaged names are `gentle-ai-skill-creator` and
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
`.atl/skill-registry.md`, injects prompts, or schedules refreshes.

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
for name in aytordev-design-system aytordev-interface-design aytordev-pen-ops dotfiles-coder nix skill-creator skill-registry; do
    cp -RL "$collection/$name" "$export_dir/$name"
    chmod -R u+w "$export_dir/$name"
done
```

Import a folder from that export and keep it while registered. Copies do not
auto-refresh: after a source update and activation, explicitly export again and
re-add the chosen file in Pen. Checks prove copied resources remain complete;
actual Pen import, model capabilities, and execution have not been validated.

## Adoption: backup, prepare, activate, onboard

These are operator instructions; repository verification does not execute them.

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
AI checks cover inventory, dependencies, metadata, and documentation links.
Theme transition tests retain real Home Manager collision and orphan-link
coverage using a surviving themed app's managed theme directory (Yazi flavors).
`checks/ai-skills-transition` executes the exact preparation script followed by
the pinned HM collision/link fragments over the synthetic old Pi layout, with
and without Darwin's `hm.old` backups. It also checks foreign-content and backup
refusal. Native profile and memory migration remain operator actions.

The eleven records under `docs/ai-tools/` describe the retired local dual-client
workflow. They remain historical evidence, not current onboarding instructions.
