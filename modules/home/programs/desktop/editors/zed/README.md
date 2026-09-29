# Zed: reviewed upstream snapshots, owned preferences

This Home Manager capability adapts [jellydn/zed-101-setup at
`aab371cdb1118b2da74c1d75e2bd822c77d2523f`](https://github.com/jellydn/zed-101-setup/tree/aab371cdb1118b2da74c1d75e2bd822c77d2523f)
without importing personal paths, external search tasks or permissive AI policy.
Upstream settings/keymap material is MIT, Copyright (c) 2024 Huynh Duc Dung;
see [LICENSE.upstream](LICENSE.upstream). The immutable generation also archives
upstream's raw LICENSE. Only the **37 reviewed settings and 46 bindings** in the
selected profile are consumed; raw settings/keymap/tasks and normalized archives
are inert evidence, not executable configuration. Unsupported keys, provider
choices and task commands in those archives do not become active.

## Use the existing capability

Enable `aytordev.programs.desktop.editors.zed.enable` through your home or suite.
The existing `package` and `theme` overrides remain supported; no new options are
needed. `config.nix` remains a pure theme adapter for Sora/Kanagawa and generated
fallbacks. This change does not activate Home Manager or edit live Zed files.

| Area | Adopted | Deliberate boundary |
| --- | --- | --- |
| Editing | Bracket colors, code-lens menu, code actions, which-key (500 ms), relative numbers, whitespace and scroll margins | Existing Monaspice fonts/sizes and theme policy; no Maple styling or global hard tabs |
| Git/navigation | Inline blame, tree view, count badge, diff stats, icons and diagnostics | Project, Git, outline and agent stay on the right; collaboration stays left |
| Agent | Ask profile, confirmation by default, right sidebar, silent notifications and single-file review | No chosen agent model/provider, favorite models, ACP/MCP setup, custom profiles, sandbox grants or trust-all policy |
| Languages | Python ty + Ruff; gopls/Rust analyzer formatters; Go tabs and Rust/JSON spaces; Markdown save formatting off, line length 80 | TypeScript inlay hints and Tailwind class attributes retained; project indentation is not globally overridden |
| Search/tasks | Native file finder and project/buffer search | No codemux path, FFF dependency, upstream install script or global task definitions |
| Privacy/editor | Telemetry remains false/false; private-value redaction | Terminal-local `EDITOR` derives from the selected package (`zeditor --wait`); global Neovim ownership and the system shell remain intact |

The existing Zed edit-prediction setting is retained, independently of agent model
selection. AI features require the user's runtime account/model configuration;
this module provisions neither credentials nor subscriptions. Ask/confirm is a
safe default, not a sandbox or a guarantee against existing user overrides.

## Layers and customization

| File | Responsibility |
| --- | --- |
| `default.nix` | Sole capability/option boundary; enable/package/theme and HM wiring |
| `snapshot.json`, `snapshots/<revision>-<manifest hash>/` | Pointer and immutable raw/normalized/policy/profile/manifest evidence |
| `adoption.json` | Pending exact-value selection policy for the next reviewed refresh |
| `profile.nix` | Constrained relative pointer, manifest/profile hash and schema checks; audited target provenance; pure composition |
| `preferences.nix` | Owned fonts, language preferences, layout, extensions, privacy/agent defaults and package-derived terminal `EDITOR` |
| `keymaps.nix` | Owned differences only, plus explicit source chord exclusions |
| `config.nix` | Unchanged pure theme resolver: explicit override → official exact theme → generated fallback → none |
| `update.py`, `updater.nix` | Manually invoked, packaged refresh/verification; never edits owned preferences or live files |

Settings compose recursively **selected upstream → owned preferences → theme**.
Lists replace at that source boundary. Source setting paths can be excluded in
`preferences.nix`; `theme` and `icon_theme` are excluded so opt-out cannot inherit
upstream appearance. Leaf preferences use `mkDefault`: a normal HM definition
replaces one scalar or an entire list without losing sibling settings. Lists are
leaves, not concatenated defaults. Privacy/redaction and agent ask/confirm use
ordinary priority; they are defaults, not enforcement. A stronger explicit user
definition such as `mkForce` can override them.

Use the existing HM API in a home module; no additional public options:

```nix
{ lib, pkgs, ... }: {
  aytordev.programs.desktop.editors.zed = {
    enable = true;
    package = pkgs.zed-editor; # Replaceable; terminal EDITOR follows this package.
    theme = { mode = "none"; }; # Or "Custom Theme", or null to follow the family.
  };
  programs.zed-editor = {
    userSettings = {
      buffer_font_size = 20;
      which_key.delay_ms = 250; # Retains which_key.enabled.
      languages.Python.language_servers = [ "ty" "ruff" ]; # Replaces the default list.
    };
    extensions = [ "nix" ]; # Additive; use lib.mkForce [ "nix" ] to replace all.
    userKeymaps = lib.mkAfter [
      { context = "Workspace"; bindings."ctrl-alt-n" = "workspace::NewFile"; }
    ]; # Use lib.mkForce [ ... ] to replace the entire configured list.
  };
}
```

Source keymaps compose by **exact context and chord**:

- Omitted and `null` contexts both mean global; scoped contexts must be strings.
  Matching normalizes globals without changing the source block's representation.
- Repeated source contexts with disjoint selected chords remain separate and in
  their original order, including intervening contexts. Selected context/chord
  collisions are rejected.
- Owned chords merge into the **last** matching block and are removed from all
  earlier same-context blocks, so the owned value wins. Truly new contexts append;
  later owned blocks win over earlier owned values. Empty source blocks stay put.
- Action arrays are atomic, with any JSON value allowed as their parameter;
  `null` bindings are real Zed disable values, never deletion markers.
- To remove source chords from **every** matching block, use
  `{ context = "..."; chords = [ "..." ]; }` in `keymaps.nix`'s
  `excludedBindings`; `context = null` also matches omitted/global contexts.
  Exclusions run before owned additions, which may deliberately restore a chord.

These are maintainer data edits, not new user options. HM's mutable runtime merger
still groups contexts, so it does **not** preserve all source ordering; these
composition guarantees apply to the declared/generated keymaps, not live merging.

## Verify, review, then explicitly apply

Run from the repository root. These use the flake's pinned Python/json5 package,
not global installations. Nix evaluation never downloads upstream configuration
or uses import-from-derivation; only a manually invoked refresh fetches upstream.
The first Nix invocation may still realize the updater package from Nix caches.

**Offline verify** checks the active immutable generation, all archived hashes,
and reproduction of its normalized documents/profile from its archived policy:

```sh
nix run --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets 'path:.#checks.aarch64-darwin.integration-zed-upstream.updater' -- verify --root "$PWD/modules/home/programs/desktop/editors/zed"
```

An edited root `adoption.json` is **pending**: verify validates the archived policy,
not that pending edit. Ordinary module evaluation checks only consumed
manifest/profile bytes and their identity/schema/provenance; the offline updater
check owns complete raw/normalized reproduction.

**Report-only refresh** is read-only with respect to the repository/live config;
it fetches the four upstream files and prints a report without publishing:

```sh
REV=aab371cdb1118b2da74c1d75e2bd822c77d2523f # Choose a full reviewed commit SHA.
nix run --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets 'path:.#checks.aarch64-darwin.integration-zed-upstream.updater' -- refresh --root "$PWD/modules/home/programs/desktop/editors/zed" --rev "$REV"
```

Review source/license hashes, settings/keymap deltas, policy errors and the
effective selected profile. The report supplies task **before/after hashes**, not
task-content deltas: separately inspect changed upstream tasks manually.
Unknown/unselected fields stay inert. A changed
selection fails closed: edit the exact `expected` value in root `adoption.json`
only after reviewing compatibility, or remove the selector to stop adopting it.
Setting selectors use `path = [object keys...]`; keymap selectors use exact
`context`/`chord`/`expected` action values. Use strict JSON, not these Nix-style
notations. Rerun report-only refresh after **every** policy edit and review the
new report. Never copy a digest without reviewing its bound report.

**Explicit apply** uses the exact final `report_sha256` printed by that refresh:

```sh
DIGEST='<reviewed report_sha256>'
nix run --no-write-lock-file --override-input secrets path:./checks/fixtures/secrets 'path:.#checks.aarch64-darwin.integration-zed-upstream.updater' -- refresh --root "$PWD/modules/home/programs/desktop/editors/zed" --rev "$REV" --apply --reviewed-report-sha256 "$DIGEST"
```

Apply refetches and verifies the digest against unchanged source/policy/pointer,
publishes an immutable generation, then replaces the pointer last. Stale digests
fail. Hashes establish integrity, **not authenticity**. Re-run verify and the
unit/home-zed/zed-upstream checks before any separately authorized activation.
Failed publication can leave inactive staging; this is not a power-loss guarantee.

Three version axes must be reviewed independently:

1. **Source revision:** the upstream setup commit and selected policy/profile.
2. **Zed:** audited target **1.21.0**, recorded in manifest/profile and checked by
   the consumer. This provenance gate does not pin or reject a replacement
   `package`; a different package needs its own compatibility/GUI validation.
3. **Extension payloads:** extension IDs are configured, but Zed downloads their
   payloads at runtime; this snapshot does not lock extension versions.

For source rollback, restore a previously reviewed pointer **with its matching
immutable generation available**, then verify it; restore owned changes
separately if needed. Never modify old generations. Source rollback does not
roll back runtime extension payloads, user accounts, language-server downloads,
or keys retained in mutable live files. No activation or cleanup is implicit.

## Keymap guide

Leader chords apply in Vim normal mode unless noted. Menus and pending Vim
motions are excluded. Existing direct pane navigation, LSP, Markdown preview,
buffer close/save and project-panel keys remain available.

| Keys | Action/context |
| --- | --- |
| `space f f`, `space space` | Native file finder; also in empty panes/shared screens |
| `space f g`, `space /` | Project search (`space f g` also in empty panes/shared screens) |
| `space s b`, `space s s`, `space s S` | Buffer search, file symbols, project symbols |
| `space c f` | Format with the language's configured formatter |
| `[ d` / `] d`, `[ e` / `] e`, `[ w` / `] w`, `[ i` / `] i` | Previous/next diagnostic, error, warning or hint; `h` remains Git hunks |
| `space g d`, `space g b`, `space g h e` | Project diff, inline blame toggle, expand all hunks; normal/visual |
| `[ b` / `] b`, `space b p` / `space b n` | Previous/next buffer; existing Shift-H/L retained |
| `alt-j` / `alt-k` | Move lines down/up; normal/visual |
| `space w v/s`, `space w h/j/k/l`, `space w >/</+/-` | Split, navigate, resize panes |
| `space f n`, `space q q` | New file / close window; also in empty panes/shared screens |
| `space a c`, `space a a`, `space a i` | Focus agent, add selection to thread, inline assist; normal/visual |
| `space a d` | Open agent diff, only in an editor with `editor_agent_diff` |
| `cmd-n`, `cmd-alt-c` | New thread / agent settings, only in AgentPanel |
| `cmd-alt-/` | Model selector, only in AcpThread or InlineAssistant |

**Symbol search moved from `s s/S` to `space s s/S`.** The old prefix conflicted
with `s`/`S` Sneak motions. Space's single-key Vim motion is disabled only in the
guarded normal/visual editor context, allowing which-key to show leader chords.
The duplicate change-operator contexts are merged (`cc`, `cr`, `ca`). Agent
prompts use modified native shortcuts, not leader sequences that consume text.
Use selection-to-thread or inline assist and enter your own explain/fix/test/
refactor/docs/summary request; no simulated typing or cross-panel action chains.

## Prerequisites and mutable-file migration

- Audited target: Zed **1.21.0**. Its built-in Python adapters include ty/Ruff; no new
  extension IDs are installed. Existing theme extensions remain enabled.
- Language servers may be downloaded by Zed at runtime. Python environments,
  Go tooling and Rust toolchains (including rustfmt) remain project/runtime
  prerequisites; this module does not install development environments.
- Home Manager keeps `mutableUserSettings` and `mutableUserKeymaps` at their
  default `true`. Its recursive settings merge overwrites declared keys but
  **retains removed and user-only keys**, including legacy `assistant`, models,
  permission rules and trust choices. This is not a cleanup migration.
- The audited source removes `vim.enable_vim_sneak`, `agent.agent_follow`,
  `notification_panel` and `chat_panel`, and replaces
  `project_panel.folder_icons = true` with `folder_indicator = "icon"`.
  Sneak actions and `assistant::InlineAssist` remain valid. These are **source
  removals**, not live-file cleanup; old keys may remain until manually removed.
- Keymaps merge by exact context. Removed chords and old contexts can survive,
  including unguarded Sneak/task bindings and the old `s s/S` symbol prefixes.
  Back up and manually inspect those entries in Zed before relying on the new
  precedence. Do not replace the entire file or discard unrelated customizations.
- Do not use Home Manager activation as a preview: the pinned Zed mutable merger
  writes real files even during its unsafe dry-run path. Activation is a separate
  user decision; no activation is part of these checks.

## Validation boundary and manual checks

Pure tests in `tests/apps/zed-settings.nix` cover integrity failures, composition,
settings and keymaps; existing `zed.nix` tests cover themes. The real pinned HM
check in `checks/home-zed` covers definition priorities, list/extension/keymap
customization, disabled outputs, package/theme overrides and actual generated
JSON. It uses a cheap synthetic package and an isolated immutable-file fixture;
real deployment remains mutable. `checks/zed-upstream` reproduces the archived
snapshot offline. None of these checks activates a home. Home Manager accepts
arbitrary JSON, so evaluation **does not validate Zed's runtime schema or action
dispatch**. Known-key negative tests guard the five audited compatibility gaps,
not the entire runtime schema.

Compatibility decisions use Zed's [v1.21.0 defaults](https://github.com/zed-industries/zed/blob/v1.21.0/assets/settings/default.json)
and [native keymaps](https://github.com/zed-industries/zed/tree/v1.21.0/assets/keymaps).
Additional action/parameter definitions were inspected in cached Zed 1.19.2
source (diagnostic severity, inline blame and native panel dispatch); that is
supporting evidence, not a substitute for a 1.21.0 GUI check.

After a separately authorized activation and mutable-file inspection:

- [ ] Check settings/keymap diagnostics in Zed; verify the running package version.
- [ ] Exercise which-key, menus, `s`/`S`, pending motions and `cc/cr/ca` without interception.
- [ ] Try file/project/buffer search, empty-pane keys, split/resize and diagnostic filters.
- [ ] Inspect Git decorations and right-side panels; confirm fonts/themes are unchanged.
- [ ] Check Python server selection/imports, Go/Rust formatting and Markdown save behavior.
- [ ] With an existing AI account, check selection/inline assist, panel shortcuts,
      model selection and agent diff; confirm tools prompt rather than auto-approve.
- [ ] Verify terminal `EDITOR` follows the selected package while the global editor remains Neovim.
