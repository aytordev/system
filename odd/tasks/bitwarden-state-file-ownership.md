# Feature: bitwarden-state-file-ownership

## Objective

Stop Home Manager from claiming ownership of Bitwarden Desktop's mutable state
file, so the application can start, migrate its own state and show a window —
while keeping the declarative desktop settings as a first-run seed.

## Problem

`modules/home/programs/desktop/security/bitwarden/default.nix` declares the
desktop settings through

```nix
home.file."Library/Application Support/Bitwarden/data.json" = settingsFile;   # Darwin
xdg.configFile."Bitwarden/data.json" = settingsFile;                          # Linux
```

Home Manager publishes a file by **symlinking a store path** into place, and
store paths are read-only. But `data.json` is Bitwarden's `electron-store` file:
the same path holds mutable application state next to the desktop settings —

```json
{
  "stateVersion": 85,
  "global_desktopSettings_window": { "width": 948, "height": 1064, ... },
  "global_applicationId_appId": "554f2bb0-...",
  "global_config_byServer": { "https://api.bitwarden.com": { "featureStates": {...} } }
}
```

Bitwarden rewrites it on every launch (startup migrations, window geometry) and
on every settings change. Against a read-only store symlink that write fails:

```
[info]  No state version found, assuming empty state.
[error] Error while running migrations: Error: EACCES: permission denied, open
        '/nix/store/9dww60ac…-hm_LibraryApplicationSupportBitwardendata.json.tmp-…'
```

The migration never completes, so the main process stays alive **without ever
creating a window**. That windowless process then holds Electron's
single-instance handoff: every later `open -a Bitwarden` returns `exit=0`, hands
control to the zombie, and the user sees nothing — the reported "no se me abre".
The process is healthy, not hung: `sample` shows the main thread idle in
`-[NSApplication run]` → `mach_msg2_trap`.

## Why

The user reported that Bitwarden does not open, right after the same class of
symptom for Pen. The cause here is not the app, the signature, or Gatekeeper: it
is this repository's own module, introduced by `6c635d1 fix(bitwarden): render
desktop settings`. On this machine the zombie has been alive since 2026-09-21
23:29 and every launch since has failed the same way.

## Evidence

Non-destructive A/B, same binary (2026.9.0), copies of the **real** profile in
`/tmp`, one variable changed — whether `data.json` is a read-only store symlink:

| probe | `data.json` | result |
| --- | --- | --- |
| A | store symlink (as shipped) | **no window**; new `EACCES` at 19:26:02 |
| B | same JSON as a `-rw-------` regular file | **window opens**; reaches `State version: 85` |

Machine state before the fix:

```
$ ps -Ao pid,lstart,command | grep MacOS/Bitwarden
41567  Mon Sep 21 23:29:14 2026  /Applications/Bitwarden.app/Contents/MacOS/Bitwarden

$ readlink ~/Library/Application\ Support/Bitwarden/data.json
/nix/store/rz5ffyvps5nppdlm41ss5ayz1gsg5iw2-home-manager-files/Library/Application Support/Bitwarden/data.json

$ open -a Bitwarden; echo $?
0                       # and still no window, no new process
```

## Scope

- `modules/home/programs/desktop/security/bitwarden/default.nix` — replace
  store-owned `data.json` with a read-only seed plus a copy-once activation.
- `checks/home-bitwarden/default.nix` — assert the new mechanism and add the
  regression guard that would have caught this.
- `checks/home-integration/default.nix` — read the settings seed instead of the
  removed store-owned path.
- `checks/activation-dry-run/default.nix` — cover the new activation entry with
  the repository's `$DRY_RUN_CMD` invariant, which today only scans the
  terminal/shell modules.
- `modules/home/programs/desktop/security/bitwarden/README.md` — document the
  seed semantics and its trade-off.
- Operationally: repair the live machine so Bitwarden opens now.

## Non-goals

- Changing which settings are declared, or their values.
- Moving Bitwarden off the Homebrew cask on Darwin (`installPackage` stays as
  is).
- Updating `checks/docs-generation/golden/*.txt` — the golden files record
  option **names**, and this change adds and removes none.

## Decisions

1. **Seed once, never own.** Activation copies the rendered JSON into place only
   when the app does not own the file yet (`[ -L "$t" ] || [ ! -e "$t" ]`), which
   also repairs machines already broken by the symlink. Afterwards Bitwarden owns
   the path and the Nix-declared values become **defaults, not enforced state**.
   That is the only correct semantics for a file that mixes settings with mutable
   state, and it is documented in the module README.
2. **The seed lives outside the application directory**, at
   `.local/share/aytordev/bitwarden-desktop/data.json`, on both platforms. It is
   a single Home Manager-owned artifact (still read-only, still declarative), and
   the app's directory keeps only files Bitwarden owns. `.local/...` is already
   an established convention on Darwin in this repository
   (`home.file.".local/bin/bitwarden-login-sops"`).
3. **Rejected: writing `data.json` from activation on every switch.** Diffs
   against the rendered seed would clobber `stateVersion` and window state the
   app had already written, re-breaking startup in a subtler way.
4. **Rejected: dropping the desktop `settings` option entirely.** Simpler, but it
   discards `biometricUnlock`, `enableBrowserIntegration` and `vault.timeout`,
   which the user configured on purpose.
5. **Keep `.text` in the check.** The regression assertion reads the rendered
   string without forcing a build during evaluation; the seed is set with `text`
   so `.text` stays available.
6. **Extend the dry-run invariant to `install`.** `checks/activation-dry-run`
   greps for mutation commands missing `$DRY_RUN_CMD`, but its pattern did not
   include `install`, which is the command this entry uses to place the seed.
   The new entry is brought inside the net and the pattern is completed rather
   than left with a hole the new code would normalize. No existing scanned entry
   uses `install`, so the extension cannot produce a false failure.

## Progress

### Evidence gathered before writing

See `## Evidence` above. Additional facts used to design the fix:

- `~/Library/Application Support/Bitwarden/` contains no `SingletonLock`,
  `SingletonCookie` or `SingletonSocket` — on macOS the instance handoff is not
  diagnosable through a lock file, unlike Linux.
- `data.json` reaches Bitwarden at 207 bytes carrying only the six declared
  settings and **no** `stateVersion`; a clean profile writes `stateVersion: 85`
  plus window geometry and server feature flags on first run.
- Only three files reference the store-owned path (module and the two checks).
- `checks/activation-dry-run` enforces a repository invariant: activation
  entries must wrap mutating commands in `$DRY_RUN_CMD` so `home-manager check`
  never writes to the live `$HOME`. Its `relevantNames` list covers only the
  terminal/shell modules, so a desktop entry would be silently uncovered — the
  new entry has to be brought inside that net, not exempted from it.
- Check attributes are category-prefixed: `integration-home-bitwarden`,
  `production-home-integration`, `integration-activation-dry-run`,
  `production-home-aytordev-wang-lin`.

### Work unit 1 (WU1) — the repository fix

- [x] Module: publish the settings as a read-only seed and copy it once by
      activation; remove the `home.file` / `xdg.configFile` claims on
      `data.json`, on both platforms.
- [x] `checks/home-bitwarden`: assert the settings seed still renders the
      expected JSON and that no store path is claimed at the app's state path.
- [x] `checks/home-integration`: read the seed.
- [x] `checks/activation-dry-run`: enable the module in the synthetic home and
      scan `bitwardenStateFile`; complete the mutation pattern with `install`.
- [x] README + option descriptions: record the defaults-not-state semantics.

Work unit 1 result: commit `18f6fd3 fix(bitwarden): stop owning the desktop
state file` on branch `fix/bitwarden-state-file-ownership` (5 files, 79
insertions, 19 deletions). The first commit attempt was blocked by the `statix`
pre-commit hook (W20, repeated keys in an attribute set, because the three
`home.*` assignments were plain rather than `mkIf`-wrapped); the fix was a pure
re-nesting into one `home = { ... };`, and the evaluated activation string was
read before and after to prove it byte-identical.

### Work unit 2 (WU2) — the live machine, no repository change

- [x] Replace the store symlink with a writable file preserving the six
      settings, and prove a window appears.

Machine evidence: at repair time the windowless process was **already gone** —
`kill -TERM 41567` answered `No such process`, so no process was killed by this
work and the record says so rather than claiming a kill. `data.json` was
replaced by a `-rw-------` copy of the six settings; `open -a Bitwarden` then
returned 0 and created a window (`31150 | Bitwarden | Bitwarden` in
`aerospace list-windows`), and `app.log` reached `State version: 85` with no
`EACCES`. The app now owns a 7855-byte state file. The writer fired no live
activation, so the repository fix is still only effective at build/eval level
until the next switch.

### Verification

- [x] Targeted checks: `home-bitwarden`, `home-integration`,
      `activation-dry-run`, `docs-generation`, `module-contract`,
      `production-home-aytordev-wang-lin`, plus the formatter.
- [x] Independent verification by `gentle-ai-verify`.

All seven authorized commands exited 0 (`integration-home-bitwarden`,
`production-home-integration`, `integration-activation-dry-run`,
`integration-docs-generation`, `integration-module-contract`,
`production-home-aytordev-wang-lin`, formatter with 4 files and 0 changed).
The verifier independently confirmed all seven falsifiable claims, including by
reading the evaluated activation text and the rendered seed JSON from the real
host config rather than from the writers' summaries. It also confirmed that
every regression assertion in `checks/home-bitwarden` is either `false` or a
missing-attribute error against the pre-change module, so the check cannot pass
unchanged against the old design.

What the verification explicitly does NOT prove, recorded rather than implied:

- **Linux is evaluated, not built.** `nix eval
  .#checks.x86_64-linux.integration-home-bitwarden.drvPath` exited 0 and so
  forced the Linux branch's assertions, but no Linux derivation was realised.
- **The regression assertions were reasoned against `HEAD`, not executed against
  it**, because that would have required mutating the working tree.
- **The docs golden is shallow.** It records option headers only, so it proves
  that no option was added or removed; it neither validates nor protects the
  changed `settings` description.
- **The guard assertions are substring checks.** `hasInfix` on the two guard
  clauses would not notice a wrong boolean connector; the exact guard is
  established by the direct read of the evaluated text, and the `$DRY_RUN_CMD`
  wrapping only by `checks/activation-dry-run`.

## Next step

WU1 and WU2 are done and verified. Push, pull request and merge remain user
decisions. One decision is the user's alone: running `just darwin-switch
wang-lin`, which makes the fix authoritative for every future activation.
Until that switch happens the repository is fixed but the machine's state file
is owned by Bitwarden by hand rather than by the module.

Superseded planning note, kept so the record shows what was planned before
verification: `darwin-switch` — which makes the fix
authoritative for every future activation — stays a user decision.
