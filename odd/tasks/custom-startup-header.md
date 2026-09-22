# Feature: custom-startup-header

## Objective

Replace gentle-pi's startup header with our own Pi extension that renders a
personal image (a pink monster) plus an animated status panel, published
declaratively by Home Manager so `darwin-switch` is the only action required.

## Problem

The built-in startup banner is hardcoded art. Its rose and text logo live in
`ROSE_LARGE_RAW` / `TEXT_LOGO` inside
`~/.pi/agent/npm/node_modules/gentle-pi/extensions/startup-banner.ts`, so the
only way to change the art without patching a package is to own the header.

## Why

- Patching the npm package is destroyed by the next update (upstream ships
  roughly one release per day).
- Forking the banner (`startup-banner.ts`, 1063 lines) creates forced
  divergence: upstream touched that single file 5 times in the last 11 days, so
  every upstream change becomes a manual merge.
- Owning our own header creates *chosen* divergence instead: upstream can move
  freely and we adopt changes only when we want them.

## Scope

- A local Pi extension that renders an image plus an animated status panel.
- Home Manager publication of the extension, its art, and its runtime config.
- A surgical, idempotent merge that disables gentle-pi's own banner extension.

## Non-goals

- Not a fork, copy, or port of gentle-pi's `startup-banner.ts`.
- Not reproducing upstream's pen-stroke logo animation.
- Not contributing upstream (deferred option; see `roseArt` in Decisions).
- Not touching `~/.pi/agent/models.json`, which Nix already owns.

## Constraints

- **Kitty protocol is required for the image.** `prepareKittyScreen()` — the
  function that replaces a full transmission with a cheap `a=p` placement —
  exists only in `pi-tui/dist/tui-alt-screen.js`. In regular TUI mode
  (`tui.js`) it does not exist. Therefore the image works only with
  `tuiMode: fullscreen` (already set) in a kitty-capable terminal (Ghostty,
  verified) outside tmux/screen (`TMUX` empty, verified).
- `renderImage()` calls `registerKittyImageMetadata()` on every invocation that
  passes `imageId`, and that increments `kittyTransmissionGeneration`. Calling
  it per frame invalidates the renderer cache and re-transmits the full base64
  payload every tick. It MUST be called once per (imageId, width) and cached.
- Every rendered line must not exceed `width`, and styles do not survive across
  lines (the TUI appends an SGR reset per line).
- `~/.pi/agent/settings.json` is written at runtime by Pi and by the gentle-ai
  installer, so it must never be declared via `home.file`. The package filter is
  applied by an idempotent `home.activation` merge instead.
- `importModulesRecursive` imports only directories containing `default.nix`, so
  the new module must be added to the `imports` list in
  `modules/home/programs/terminal/tools/pi/default.nix`.
- Adding options changes the generated option index, so
  `checks/docs-generation/golden/home.txt` must be regenerated with
  `just docs-golden` (the check's error text says `golden-update`, which is
  stale and does not exist).

## Tasks

- [x] **CSH-14** (defect reported by the user: the gentle banner reappears
  seconds after a start or `/reload`) Re-apply the banner filter from the
  extension itself. `~/.pi/agent/settings.json` is a runtime file: after the
  22:57:33 activation merged `!startup-banner.ts`, a later writer rewrote the
  `packages` array and dropped it (verified: the file held a plain
  `"npm:gentle-pi"` string, and `npm:gentle-engram` plus
  `npm:gentle-engram@0.1.14` as a duplicate pair, which is the exact shape
  `pi-engram init` produces). With the filter gone gentle-pi's banner loads on
  every later start, so the extension now heals the single entry at setup time,
  atomically and only when it changed.
  Acceptance: a settings file whose `npm:gentle-pi` entry lacks the filter gains
  exactly that filter, and every other key and entry is byte-identical.
- [x] **CSH-15** (same defect) Make the header claim survive a competitor.
  The old claim was one `setTimeout` at 120 ms: `session_shutdown` cancelled it,
  and a ctx whose runner was invalidated inside that window threw (swallowed by
  the empty catch), so a banner that asserted at ~50 ms kept the slot. The claim
  is now three pieces: the delayed assert, an immediate assert from
  `session_shutdown` while our assert is still pending, and a bounded watchdog
  that re-claims when the component stops being painted.
  Acceptance: with a hostile second extension that steals the header at +2 s,
  our panel is back within a few seconds; `/reload` and `/new` keep it; and no
  re-claim storm (bounded per session).
- [x] **CSH-16** (defect found while fixing CSH-14) The activation entry aborted the
  whole activation. `mergeGentlePiBannerFilter` used `exit 0` on its guard paths,
  and Home Manager inlines every activation entry into one script that runs with
  `set -eu` (verified in the deployed `17c2a0vmxhcjwai2wpsnyxaw8gzwl1a6-home-manager-generation`:
  the body is inline after `_iNote ... "piStartupHeaderBannerFilter"`, not a
  subshell), so a missing `settings.json`, a missing `jq` or a failing `mktemp`
  skipped every activation entry that followed instead of skipping one merge. The
  body is now a function that returns instead of exiting, called with `|| true`,
  and it restores the file's permission bits like the `agent-profiles.nix` entry.
  Acceptance: with `settings.json` absent, unparsable or present, the script
  continues past the entry, and in the present case the filter is merged.
- [x] **CSH-1** Downscale the source art so the one-time kitty transmission stays
  small, and place it in the tree.
  Acceptance: a PNG of roughly 768 px width in
  `modules/home/programs/terminal/tools/pi/startup-header/`, alpha preserved,
  and well under 200 KB.
- [x] **CSH-2** Write the extension entry point: image rendering with a single
  cached `renderImage()` call and a stable allocated `imageId`, plus a graceful
  fallback when `getCapabilities().images !== "kitty"`.
  Acceptance: the image occupies one line of `render()`, the cached sequence is
  byte-identical across frames, and `renderImage()` is not called from
  `render()`.
- [x] **CSH-3** Render the animated status panel: git branch, model and thinking
  level, context usage, loaded skills and custom tools, and the active
  agent-model profile.
  Acceptance: every line respects `width`, and the panel renders without the
  image when the image protocol is unavailable.
- [x] **CSH-4** Implement the animation loop with `setInterval` +
  `tui.requestRender()`, honoring the configured cadence, and clean everything
  up in `dispose()` including `deleteKittyImage()`.
  Acceptance: no timer survives `dispose()`, and no kitty image is left behind
  after the session ends.
- [x] **CSH-5** Write the Home Manager module: options for enable, art, width,
  height, cadence, and banner suppression; publish the extension directory with
  its runtime `config.json`; merge the gentle-pi package filter into
  `settings.json` idempotently.
  Acceptance: a second `darwin-switch` with no changes produces no file churn,
  and the merge is a no-op when the filter is already present.
- [x] **CSH-6** Wire the module into the `pi` module's `imports`.
  Acceptance: `nix build .#darwinConfigurations.wang-lin.system` evaluates the
  new options.
- [x] **CSH-7** Regenerate `checks/docs-generation/golden/home.txt` with
  `just docs-golden` and review the diff for unrelated in-progress changes.
  Acceptance: the golden diff contains only the new option paths.
- [x] **CSH-8** Verify: build the system, run the relevant checks, and confirm
  the header renders in a live session.
  Acceptance: `nix build` succeeds, checks pass, and the image plus panel appear
  on the next Pi start or `/reload`.
- [x] **CSH-9** (scope change found during CSH-8) Activate the option. The module
  defaulted to `enable = false` and nothing enabled it, so `darwin-switch` would
  not have published the header at all. Wired
  `pi."startup-header".enable = mkDefault cfg.aiEnable` into the development
  suite beside the other AI tools.
  Acceptance: the evaluated option reports `enable = true` for `wang-lin`.
- [x] **CSH-10** (scope change found during review) Fix art resolution. The
  published entry point is a symlink to a standalone store file, so
  `import.meta.url` realpaths to `/nix/store/<hash>-index.ts`, making the
  entry-point-relative directory `/nix/store`, where the PNG does not exist. The
  art lookup now iterates the same ordered, deduplicated candidate directories
  as the config lookup.
  Acceptance: the art resolves through the installed fallback directory.
- [x] **CSH-11** (user-requested refinement) Center the header and drop the
  `pink-monster` title. The art and the panel are now centered inside the live
  terminal width, and the panel's first line carries the spinner plus the rule
  instead of a separate title row, so the rule aligns with the rows beneath it.
  Because the exported `Image` component does not expose the cell footprint that
  centering needs, the payload is built from `renderImage()` directly and cached
  per width.
  Acceptance: the art and the panel are horizontally centered, no title row
  remains, and the cached payload is still byte-identical across frames.
- [x] **CSH-12** (defect found while verifying CSH-11) Restore the width
  invariant. CSH-11 replaced the per-line truncation in `render()` with padding
  only, so a `branch`, `model`, or `profile` value wider than the terminal
  produced over-wide lines that wrap. `model` already overflows at the default
  `maxWidthCells = 44` with a long model id: 11 cells of row prefix plus a
  35-character `provider/id` plus the thinking suffix. `centerLines` now truncates
  over-wide lines before centering.
  Acceptance: no rendered panel line exceeds `width`, and centering is preserved
  for lines that fit.
- [x] **CSH-13** (defect found by CI on PR #196) Update the option-ownership
  guard. `checks/gentle-ai-engine/default.nix` asserts the exact option set of
  `tools.pi`, and the startup-header module added `pi."startup-header"`, so
  `noLegacyOptions` threw and took down both `Check aarch64-darwin` and
  `Check x86_64-linux`. The pre-PR verification had run only three named checks
  and never included `integration-gentle-ai-engine`, so the breakage reached the
  PR.
  Acceptance: `nix flake check` passes on aarch64-darwin, and the same assertion
  evaluates for x86_64-linux.

## Verification evidence

Parent-owned final verification (authoritative):

- `nix build .#darwinConfigurations.wang-lin.system` succeeded after every
  change. Final system path: `kmfbb40jgk6mgci1h5adm6gyy7mbq89h`.
- Generated extension directory
  `h72damh2ifzygac16y1w3w9qj9x85grp-pi-startup-header` holds `index.ts`,
  `pink-monster.png` and `config.json` as symlinked siblings, and Home Manager
  publishes it as the single directory symlink
  `~/.pi/agent/extensions/startup-header`.
- `config.json` resolves to
  `{"art":"pink-monster.png","cadence":"quality","maxHeightCells":20,"maxWidthCells":44}`.
- `just docs-golden` produced a 6-insertion diff limited to the new option
  paths; `checks/docs-generation/golden/darwin.txt` was unchanged.
- Passing checks (the `integration-` prefix is required; the bare names do not
  exist): `integration-docs-generation`, `integration-module-contract`,
  `integration-home-module`.
- Evaluated options for `wang-lin` report `enable = true`.
- The settings.json merge was simulated twice against a temporary copy: the first
  run adds the filter, the second is byte-identical.
- API surfaces used by the extension were each verified against the shipped type
  declarations: `ContextUsage` (`tokens`/`contextWindow`/`percent`), `Model`
  (`provider`/`id`), `ctx.thinkingLevel`, `pi.getAllTools()`, `pi.getCommands()`,
  `TUI.terminal.write()`.
- NOT verified: live rendering in an interactive Pi session. That requires a
  human to run `/reload` or start a new session.
- Environmental note: the new files needed `git add -N` before any flake-based
  evaluation could see them, because Nix ignores files untracked by Git. Nothing
  was staged or committed.

Original evidence prompts:

- `nix build .#darwinConfigurations.wang-lin.system` (deferred to parent)
- `nix flake check --override-input secrets path:./checks/fixtures/secrets`
- Live check in Pi: `/reload` then confirm the image and panel.

### CSH-1..CSH-6 verification record (worker)

- **CSH-1 art.** `sips -Z 768` produced 768x613 RGBA at 424 KB (over budget), then a
  single-invocation `ffmpeg` palette quantization (`palettegen=reserve_transparent=1`
  + `paletteuse=alpha_threshold=128`) brought it to **127002 bytes**. Verified with
  `sips -g pixelWidth -g pixelHeight -g hasAlpha pink-monster.png` ->
  `pixelWidth: 768`, `pixelHeight: 613`, `hasAlpha: yes`. Comfortably under 200 KB.
- **CSH-2..CSH-4 extension.** Originally `index.ts` used the exported `Image`
  component (built once, cached per width, stable kitty `imageId`); CSH-11 replaced
  it with a direct `renderImage()` call plus an explicit per-width cache, because
  centering needs the cell footprint that `Image` does not expose. `renderImage()`
  is still never called from `render()`. `setHeader` fires at 120 ms via
  `setTimeout`; cadence is 80/250/none; `dispose()` clears timers and writes
  `deleteKittyImage(this.imageId)`. Falls back to panel-only when
  `getCapabilities().images !== "kitty"`.
- **CSH-5/CSH-6 eval (option defaults).** Exact command:
  `nix eval --json 'path:.#darwinConfigurations.wang-lin.config.home-manager.users.aytordev.aytordev.programs.terminal.tools.pi.startup-header' --override-input secrets path:./checks/fixtures/secrets`
  -> `{"art":".../startup-header/pink-monster.png","cadence":"quality","disableGentlePiBanner":true,"enable":false,"maxHeightCells":20,"maxWidthCells":44}`.
  Path note: the option lives under **home-manager**, not the system config; the home
  user is `aytordev` (so `users.aytordev.aytordev.*`). The `path:` flake reference is
  required because the new files are untracked and staging is out of scope.
- **Store assembly.** With the option enabled in memory via
  `darwinConfigurations.wang-lin.extendModules { home-manager.sharedModules = [...]; }`,
  `nix build --impure --no-link --print-out-paths --expr` yielded
  `/nix/store/acnn9k8z5a5m741q0scffcsib752cw0n-pi-startup-header` containing three
  siblings: `config.json`, `index.ts`, `pink-monster.png`.
  `config.json` = `{"art":"pink-monster.png","cadence":"quality","maxHeightCells":20,"maxWidthCells":44}`.
- **settings.json merge (temp copy, real file untouched).** Run 1 converted
  `"npm:gentle-pi"` -> `{"source":"npm:gentle-pi","extensions":["!startup-banner.ts"]}`;
  run 2 was byte-identical (semantic `jq -S` guard). A non-canonical file that already
  carries the filter, and a `packages` value that is not an array, are both left
  byte-identical. Object-form entries keep extra keys and gain the filter. The real
  `~/.pi/agent/settings.json` sha256 was unchanged (`91dda864...`).
- **Formatter.** `nix run .#formatter.aarch64-darwin -- <touched .nix files>` ->
  `formatted 2 files (0 changed)`. `index.ts` has no configured formatter (prettier
  disabled in `flake/dev/treefmt/default.nix`); PNG files are excluded there.
- **Deferred.** CSH-7 (`just docs-golden`) is parent-owned. CSH-8's full
  `nix build .#darwinConfigurations.wang-lin.system` and the live `/reload` check are
  left to the parent.

## Decisions

- **Real kitty image over block art** (user's choice, verified viable):
  Pi's alt-screen renderer already solves re-transmission via
  `prepareKittyScreen()`, so a static image in an animated header costs nothing
  per frame once cached.
- **Direct `renderImage()` over the exported `Image` component** (forced by
  centering, CSH-11): `Image` owns its caching but does not expose the cell
  footprint, and neither `calculateImageCellSize` nor `isImageLine` is exported,
  so centering has no way to learn the columns it must pad. `renderImage()`
  returns `{sequence, columns, rows}` and supplies exactly that. The per-width
  caching `Image` used to provide is now explicit in `imageLines()`, so the
  re-transmission hazard recorded under Constraints is still avoided.
- **Own extension over upstream fork**: the extension is not a reproduction, so
  upstream's daily changes never reach us as conflicts.
- **Upstream `roseArt` option deferred**: contributing a configurable art option
  to gentle-shell would have zero divergence and maximum configurability, but it
  has lead time. Recorded as the migration path if the custom extension ever
  becomes a burden.

## Progress

### Work unit 5 (CSH-14, CSH-15) — the reported defect

Evidence gathered before writing code:

- `~/.pi/agent/settings.json` (mtime 22:59:54, i.e. 2m21s after the activation
  that merged the filter) carries `packages[0] = "npm:gentle-pi"`: no filter.
  The deployed activation entry is present and correct (line 507 of
  `596n7rsxmx3bakc1l0xhday5h49b96g2-home-manager-generation/activate`), and the
  published extension matches the repo byte for byte (sha256 `6074a7b1…`), so
  the filter was applied and then dropped by a later writer.
- Loading is effective: with the filter present, `pi list` reports
  `npm:gentle-pi (filtered)`, and Pi's `matchesAnyPattern` matches the basename,
  so `!startup-banner.ts` does exclude `extensions/startup-banner.ts`.
- Four held-out runs of a real Pi in a pty (50x150, `--no-session`, including
  `/reload` and `/new`) showed our header winning every emission: `GIT:` and the
  rose braille never appear, and the loaded-resources box lists both
  `gentle-pi:startup-banner.ts` and `startup-header`.
- Reproduced the duplicate-entry shape without touching the real profile:
  `PI_CODING_AGENT_DIR=/tmp/pi-merge-test node …/gentle-engram/cli.js init`
  added `npm:gentle-engram@0.1.14` beside `npm:gentle-engram` and preserved the
  `npm:gentle-pi` object entry, so `pi-engram init` explains the duplicate but
  not the dropped filter.
- Conclusion: the observable defect is the dropped filter, and the failure mode
  of the old claim is a lost single `setTimeout` (cancelled by
  `session_shutdown`, or thrown away on a stale ctx). Both are fixed here; the
  exact identity of the writer that dropped the filter stays unproven, which is
  why the fix heals the file instead of depending on that writer.

Verification of the fix (all commands run locally, in this order):

- `node --experimental-strip-types --check index.ts` -> syntax OK.
- Hostile-competitor harness in an isolated agent dir (`/tmp/hdr-agent`: our
  extension plus an `evil` extension that overwrites the header at +2 s): the
  evil line is painted once and our panel is painted again after it (`branch` and
  `profile` rows plus spinner frames continue to the end of the raw stream), so
  the watchdog reclaims the slot.
- Self-heal in the same harness: `packages[0]` went from `"npm:gentle-pi"` to
  `{"source":"npm:gentle-pi","extensions":["!startup-banner.ts"]}` while
  `npm:pi-btw`, `theme`, `tuiMode`, `lastChangelogVersion` and an unrelated
  `unknownKeyThisMustSurvive` object stayed byte-identical.
- Real profile, started with `-e <repo>/startup-header/index.ts`: the real
  `~/.pi/agent/settings.json` was healed into the same object form (backup at
  `/tmp/settings.real.before.json`), and a second identical run left its sha256
  unchanged (`be935d88…`), so healing is idempotent.
- Next start with the healed profile (real agent dir, 40x140 pty): `GIT:` and the
  rose braille appear zero times, `gentle-pi:startup-banner.ts` is absent from the
  loaded-resources `[Extensions]` list while `startup-header` is present, and our
  panel and kitty payload render. The pre-heal run of the same command did list
  `gentle-pi:startup-banner.ts`.
- Nix: `nix eval` reports `disableGentlePiBanner = true` and `enable = true`; the
  extension derivation `la17c56y…-pi-startup-header` holds `index.ts` (sha256
  `a0d95845…`, identical to the repo) and a `config.json` carrying
  `"disableGentlePiBanner":true`; a fresh `docs-options` build matches
  `checks/docs-generation/golden/{home,darwin}.txt` byte for byte (no golden
  update needed); `alejandra --check` and `typos` are clean on the changed files.
- Passing checks: `integration-docs-generation`, `integration-module-contract`,
  `integration-home-module`, `integration-gentle-ai-engine`. The repository
  pre-commit suite passed on the staged files too (conflict markers, deadnix,
  statix, treefmt, typos).
- Deployment still pending: `darwin-switch wang-lin` publishes the new extension.
  The healed `settings.json` already stops the rose banner from loading on the
  next start, and `/reload` is enough for a session that is already running.

All earlier tasks complete, across seven work units.

Work unit 5 — commit `16a9dc9 fix(pi): keep the startup header when gentle-pi's
banner re-asserts`, 3 files, 314 insertions, 57 deletions:
`modules/home/programs/terminal/tools/pi/startup-header/index.ts`,
`modules/home/programs/terminal/tools/pi/startup-header.nix` and this document
(CSH-14, CSH-15 and their evidence). CSH-14 and CSH-15 share one commit because
both live in the same claim surface of one file; the self-heal is inert without
the nix-side `disableGentlePiBanner` that the claim reads from `config.json`.

Work unit 6 — commit `e8b97bc fix(pi): never abort the activation from the
banner-filter merge`, 1 file, 48 insertions, 32 deletions:
`modules/home/programs/terminal/tools/pi/startup-header.nix`. The entry body
became a shell function that returns instead of exiting, called with `|| true`,
and it preserves the permission bits of `settings.json`.

Work unit 7 — `docs(odd): record CSH-16 and the work-unit commit for the
activation guard`, which records the evidence below.

### CSH-16 evidence

- Deployed generation: in
  `17c2a0vmxhcjwai2wpsnyxaw8gzwl1a6-home-manager-generation/activate` the entry
  body is inline after `_iNote ... "piStartupHeaderBannerFilter"` (line 605), not
  a subshell, which is what made `exit 0` fatal for the whole activation.
- Extracted-entry harness (`bash -eu -o pipefail`, stub `_iNote`, home path
  rewritten to a scratch directory, `echo CONTINUED-AFTER-ENTRY` appended after
  the entry): five cases, every one printed the continuation marker — settings
  absent (and no file created), valid without the filter (filter added,
  `npm:pi-btw`/`theme`/an unrelated key preserved, mode stays 644), unparsable
  JSON (byte-identical), already filtered (byte- and mtime-identical on a second
  run), `packages` that is not an array (file untouched).
- jq program: byte-identical to the previous version after whitespace
  normalization (16 lines), so the merge semantics did not change.
- Checks: `integration-activation-dry-run`, `integration-gentle-ai-engine` and
  `integration-home-module` pass, and `nix flake check --no-build` reports no
  evaluation error.

Work unit 1 — commit `6e44f11 feat(pi): replace the startup banner with a custom
header`, 6 files, 514 insertions, 1 deletion:

| Path | Change |
| --- | --- |
| `modules/home/suites/development/default.nix` | +3 (activate the header) |
| `modules/home/programs/terminal/tools/pi/default.nix` | +4 -1 (imports) |
| `modules/home/programs/terminal/tools/pi/startup-header.nix` | new, 131 lines |
| `modules/home/programs/terminal/tools/pi/startup-header/index.ts` | new, 352 lines |
| `modules/home/programs/terminal/tools/pi/startup-header/pink-monster.png` | new, 768x613 RGBA, 127 KB |
| `checks/docs-generation/golden/home.txt` | +6 (new option paths) |

The pre-commit suite (conflict markers, deadnix, statix, treefmt, typos) passed;
`typos` first rejected a spelling variant in `index.ts` and required `unparsable`.

Work unit 2 — commit `479d9f8 feat(pi): center the startup header art and panel`,
2 files, 187 insertions, 62 deletions: `startup-header/index.ts` (now 454 lines;
128 insertions, 44 deletions against `6e44f11`) and this document (CSH-11, CSH-12
and the revised `renderImage()` decision).

Work unit 3 — commit `0171dda docs(odd): track ODD feature documents in version
control`, which brings this document under version control.

Work unit 4 — commit `7abc945 fix(checks): allow the pi startup-header option in
the ownership guard`, 2 files, 13 insertions, 1 deletion:
`checks/gentle-ai-engine/default.nix` (the option allowlist) and this document.

## Next step

Human action: `darwin-switch wang-lin` publishes the new extension, then `/reload`
(or a new Pi start) picks it up. In the session that is already running, `/reload`
alone is enough to drop gentle-pi's banner, because the healed `settings.json` no
longer loads it. Confirm that the monster renders centered above the chat with
the centered animated panel and that it stays there. If the image is missing, check that `TERM_PROGRAM=ghostty`, that `TMUX` is
unset, and that `tuiMode` is `fullscreen` — the image path depends on all three.

Two behaviours remain unverified because they need a live terminal:

- That the centered padding lands the kitty placement at the intended column. The
  pad is written as spaces *before* the placement command, so the outcome depends
  on how kitty resolves the cursor for `a=p`. The footprint is correct by
  construction; the horizontal offset is not proven.
- That a long `model` value now truncates instead of wrapping (CSH-12).

Pull request: #198 (`fix/pi-startup-header-slot`), opened against `main` with the
`bug` label, after the CSH-14/CSH-15 and CSH-16 commits. The branch was rebased
locally onto `main` and the force-push was declined by policy, so the PR head
tracks the original base; GitHub reports it `MERGEABLE` and CI validates the merge
ref.
