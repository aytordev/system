# macOS login latency (post-switch session bootstrap)

## Specs

- **S1.** The user reports: "Lo que pasa es que tardo un poco mas es iniciar
  justo despues de introducir la contraseña desde el ultimo switch de Nix."
  The delay is between entering the login password and a usable desktop.
- **S2.** "Ha pasado de 3 veces." The delay is recurrent, not a one-off: the
  three reboots of 2026-10-18 (22:02, 22:04, 22:06) all count.
- **S3.** The user confirmed the moment is "Al prender o reiniciar la máquina"
  (not screen unlock) and the three episodes are "Los 3 reinicios de anoche
  (22:02, 22:04, 22:06)".
- **S4.** RAM must not be blamed. Measured baseline that any change keeps:
  21 GB used / 75 GB free of 96 GB, `vm.swapusage` total 0.00M,
  `Pages stored in compressor: 0`, `kern.memorystatus_vm_pressure_level` = 1,
  zero jetsam kills in 24 h.
- **S5.** sketchybar must stop aborting. Nine reports in
  `~/Library/Logs/DiagnosticReports/sketchybar-*.ips` share one signature:
  `___BUG_IN_CLIENT_OF_LIBMALLOC_POINTER_BEING_FREED_WAS_NOT_ALLOCATED` →
  `malloc_report` → `abort` → SIGABRT, on the main dispatch queue.
- **S6.** Login agents must not compile anything at session start. No `make`
  (and no CommandLineTools dependency) on the login path.
- **S7.** Spotlight must not index generated trees: `~/Developer`, `~/.cache`,
  `~/backups`.

## Tasks

| ID | Specs | Route | Commit |
| --- | --- | --- | --- |
| T1 | S5 | implement: pin SketchyBar's Lua bridge and interpreter to 5.4 | this branch |
| T2 | S6 | implement: build the sketchybar C helpers in Nix instead of `make` at login | pending decision |
| T3 | S7 | decide: Spotlight exclusions are not reliably flake-shaped | pending decision |

Measurement baseline for S1, per boot (auth → agent live), from
`log show --predicate 'process == "loginwindow" AND category == "KeyMilestone"'`
plus `launchd ... "Successfully spawned"`:

| Boot | auth → Dock | auth → sketchybar | auth → protonmail |
| --- | --- | --- | --- |
| 22:02 | 0.5 s | 1.9 s | 8.0 s |
| 22:04 | 0.6 s | 2.1 s | 6.3 s |
| 22:06 | 8.8 s | 8.9 s (stable at 37 s) | 10.2 s |

The 8.8 s comes from an 8.015 s stall between `DeletedUserFolders` and
`TALLaunchStart` (the other boots: 9 ms and 13 ms), during which
`backgroundtaskmanagementd` revalidates every Nix login item, and
`lastLoginPanic` in `/Library/Preferences/com.apple.loginwindow` records the
loginwindow watchdog firing.

## Log

- **L1.** "siento que el ordenador me va lento en ram."
- **L2.** "Lo que pasa es que tardo un poco mas es iniciar justo despues de
  introducir la contraseña desde el ultimo switch de Nix."
- **L3.** "Ha pasado de 3 veces."
- **L4.** Answers: the delay happens "Al prender o reiniciar la máquina"; the
  three episodes are "Los 3 reinicios de anoche (22:02, 22:04, 22:06)"; scope
  chosen was the three fixes, "Las tres, en ese orden".
- **L5.** Discovery that reorders the plan: the `make` in `sketchybar`'s
  `lua-gen.nix` costs 62 ms measured (`real 0m0.062s`), so building the helpers
  in Nix is reproducibility hygiene, not latency work. The crash task moves
  first.
- **L6.** Crash signature is identical in all nine `.ips` files. Upstream
  evidence: `FelixKratz/SketchyBar#691` ("Sketchybar crashes every time laptop
  wakes", open, SbarLua) and `FelixKratz/SbarLua#59` ("Latest Lua (5.5) crashes
  on Sketchybar startup"). The live closure carries `lua-5.5.1`,
  `lua5.5-sbarLua-0-unstable-2026-03-06` and `lua5.5-luaposix-36.2.1`, and this
  repository patches luaposix's rockspec to lift the `lua < 5.5` bound.
- **L7.** The last switch (2026-10-18 20:16) is one commit behind `main`: the
  live `~/.config/aerospace/aerospace.toml` symlink resolves to that switch's
  store path, so `ef46f3f3` (bar clearance per display) is not applied. That fix
  is geometry, not timing.
- **L8.** T1 edit landed and evaluates correctly:
  `programs.sketchybar.luaPackage.version` = `5.4.7` (was 5.5.1), and
  `alejandra --check` passes. Build verification is **blocked, not failed**: the
  nar `0fch5lvmm2wls5pi6q5n8ixminm3w73pwrzr65jcxqk7sn06s1md.nar.zst`
  (`gcc-16.2.0`, 115160735 bytes, needed because `pkgs.sbarlua` declares
  `nativeBuildInputs = [gcc]` and the Lua 5.4 build is not in any cache) is cut
  by `cache.nixos.org` after ~1 MB on every attempt. Evidence: `curl` partial at
  1091310/887168/981623 bytes over HTTP/2, HTTP/1.1 and forced IPv4;
  three resume attempts advanced ~1.08 MB each; a 20 MB Cloudflare download
  completed in 0.87 s from the same host, so the network is not the limit.
  `--fallback` was tried and rejected: it rebuilds the bootstrap chain from
  source (readline, sed, sbuf, gcc) and ran 60 min without finishing.
- **L9.** Consequence for T2: nothing in this cycle needs `gcc` except the Lua
  5.4 pin above. The pin is the only reason the login path stops depending on
  CommandLineTools, and it is also the only reason this repository now needs a
  local GCC for its bar.
- **L8.** T1/S5 implemented on `fix/macos-login-latency`: `programs.sketchybar`
  now sets `sbarLuaPackage = pkgs.sbarlua.override {lua55Packages =
  pkgs.lua54Packages;}` and `luaPackage = pkgs.lua5_4` in
  `modules/home/programs/desktop/bars/sketchybar/default.nix`, and the
  luaposix 36.2.1 rockspec is passed unpatched (the `sed` lift of `lua < 5.5`
  is unnecessary under 5.4). Evaluation confirms the pin:
  `luaPackage.version` = `"5.4.7"` and `sbarLuaPackage.name` =
  `lua5.4-sbarLua-0-unstable-2026-03-06` (`passthru.luaModule` = `lua-5.4.7`).
  The full build `nix build --no-link --print-out-paths
  .#darwinConfigurations.wang-lin.system` did not complete here: it fails at
  fetching `gcc-16.2.0` from cache.nixos.org (curl "Failure when receiving
  data from the peer", retries exhausted, twice), which cascades into
  `lua5.4-sbarLua`, `sketchybar`, and downstream drvs. Environmental network
  failure, not a derivation error; not yet proven to build.
- **L10.** T2/S6 implemented on `fix/macos-login-latency`: new
  `modules/home/programs/desktop/bars/sketchybar/helpers.nix` builds the three
  C helpers (`menus`, `cpu_load`, `network_load`) with `mkDerivation` and the
  same flags the makefiles use (`-std=c99 -O3`, plus
  `-F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight`
  for `menus`); `lua-gen.nix` drops the `os.execute(... make ...)` call from
  `mainConfig`, excludes the C sources/makefiles from the `cleanSourceWith`
  filter (keeping the `helpers.*` Lua modules, which items still require), and
  deploys the prebuilt binaries at the exact `$CONFIG_DIR` paths the Lua
  already uses. Evidence: the derivation builds and `file` reports
  `Mach-O 64-bit executable arm64` for all three binaries;
  `xdg.configFile` contains the three `sketchybar/helpers/**/bin/*` keys and
  the deployed `sketchybar` tree has zero `.c`/makefile files; the only
  remaining `make` match in `lua-gen.nix` is a comment. `alejandra --check`
  passes on all three files.
