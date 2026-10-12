# Activation Tool-Path Integrity

## Goal

Make it impossible for a privileged activation fragment in this repository to
call a tool that does not exist on Darwin, and repair the one that already did.

Driving incident: the `civislend` switch built
`/nix/store/6yihnypi…-darwin-system-26.11.4cff07d` and then aborted inside the
activation script:

```
/nix/store/6yihnypi…-darwin-system-26.11.4cff07d/activate: line 3219: /usr/bin/ln: No such file or directory
```

The generated `activate` runs with `set -e` (line 4), so this aborted the whole
activation at the `postActivation` step, after the Home Manager and SOPS
fragments and before nix-darwin publishes the new generation.

## Darwin facts (evidence, macOS 27.0.0 on `civislend`)

Darwin's shell-tool layout is **split**, not Linux-like. Verified by direct
filesystem probe on the affected host:

| Path | State | Path | State |
| --- | --- | --- | --- |
| `/bin/ln` | exists | `/usr/bin/ln` | **missing** |
| `/bin/echo` | exists | `/usr/bin/echo` | **missing** |
| `/bin/rm` | exists | `/usr/bin/rm` | **missing** |
| `/bin/mkdir` | exists | `/usr/bin/mkdir` | **missing** |
| `/bin/bash` | exists | `/usr/bin/bash` | **missing** |
| `/bin/sh` | exists | `/bin/readlink` | **missing** |
| `/usr/bin/readlink` | exists | | |
| `/usr/bin/arch` | exists | | |
| `/usr/bin/true` | exists | | |
| `/usr/bin/env` | exists | | |
| `/usr/bin/find` | exists | | |
| `/usr/sbin/softwareupdate` | exists | | |

`ln` in `/bin` but `readlink` in `/usr/bin` is the trap: the layout cannot be
inferred from Linux habit, so it must be a vetted list, never a guess.

nix-darwin's own `activate` body mostly calls bare `ln` / `readlink` through
`PATH`; the fragment here hardcoded an absolute path instead, which is the
defensible choice for a privileged script whose ambient `PATH` we do not
control — but only if the path is real.

## Repository-wide audit (T1)

Every absolute tool path the repository invokes, wherever it executes:

| Call site | Path | Darwin |
| --- | --- | --- |
| `modules/darwin/services/docker-socket/default.nix:75` | `/usr/bin/ln` | **MISSING — the defect** |
| `modules/darwin/services/docker-socket/default.nix:66,73` | `/usr/bin/readlink`, `/bin/echo` | exists |
| `modules/darwin/system/rosetta/default.nix:18,20` | `/usr/bin/arch`, `/usr/bin/true`, `/usr/sbin/softwareupdate` | exists |
| `modules/darwin/nix/default.nix:73` | `/usr/bin/env` | exists (sandbox path exemption, not a call) |
| `modules/home/programs/desktop/window-manager-system/aerospace/default.nix:68` | `/bin/bash` | exists (launchd program) |
| `modules/home/services/protonmail-bridge/default.nix:92` | `/bin/sh` | exists (launchd program) |
| `modules/home/suites/desktop/default.nix:62` | `/usr/bin/find` | exists |
| `checks/theme-catalog/regenerate.sh:1` | `/usr/bin/env bash` | exists |

`/usr/bin/ln` is the only non-existent path in the tree. The launchd and check
paths above are runtime call sites, verified by functional use; the durable
guard below covers activation fragments, which is where a wrong path silently
breaks a host switch.

## Why the checks missed it (T3 rationale)

`checks/container-runtime/default.nix` rewrote `/usr/bin/readlink`, `/bin/echo`
and `/usr/bin/ln` to bare `PATH` lookups before executing the fragment in the
sandbox, explicitly so "the identical logic executes on every platform". That
rewrite erased the exact platform fact that was wrong: the check exercised the
symlink state machine with sandbox `coreutils` and was structurally incapable
of failing on a non-existent Darwin tool path.

A verification step that translates the system under test's platform-specific
facts into portable ones cannot verify those facts.

## Tasks

- [x] T1 — **Audit every absolute tool path in activation fragments and repo
      scripts against Darwin reality.** Result: exactly one non-existent path
      (`/usr/bin/ln`), recorded in the table above. The Darwin layout is split
      (`/bin` for `ln`/`echo`/`rm`/`mkdir`, `/usr/bin` for
      `readlink`/`arch`/`true`/`env`), and `/bin/readlink` is also missing, so
      the correct list cannot be derived by symmetry.
- [ ] T2 — **Repair the fragment**: `/usr/bin/ln` → `/bin/ln` in
      `modules/darwin/services/docker-socket/default.nix`. Absolute path kept
      deliberately: a privileged activation step must not depend on the ambient
      `PATH` of `darwin-rebuild switch`.
- [ ] T3 — **Close the blind spot in `checks/container-runtime`**: replace the
      hardcoded rewrite list with extraction from the fragment itself, so every
      absolute tool path the fragment adds is translated automatically and no
      unvetted path can be silently erased.
- [ ] T4 — **Repo-wide guard in `checks/activation-dry-run`**: a vetted Darwin
      tool allow-list plus a scan of every repo-authored activation fragment
      (darwin `system.activationScripts.*.text`, Home Manager
      `home.activation.*`), with a self-test proving the predicate rejects
      `/usr/bin/ln` — non-vacuity is the point, since the defect was a check
      that could not fail.
- [ ] T5 — **Document the platform fact**: `modules/darwin/AGENTS.md` (the split
      layout and the rule for privileged fragments) and `checks/AGENTS.md`
      (the second contract now owned by `activation-dry-run`).
- [ ] T6 — **Verify**: targeted checks, full `nix flake check`, and the
      generated `activate` for `civislend` containing no non-existent tool path.
- [ ] T7 — **Re-switch `civislend` and verify the host**: `/run/current-system`
      points at the new generation and `/var/run/docker.sock` exists. Requires
      the user's `sudo`; the agent shell has no password prompt.

## Blast radius of the incident

Before the repair is activated, `civislend` is half-applied:
`/run/current-system` still resolves to
`/nix/store/527xzmjd…-darwin-system-26.11.4cff07d` (previous generation) while
Home Manager files and SOPS secrets from the newer build are already on disk.
The system-level changes of generation `6yihnypi…` are not live, and
`/var/run/docker.sock` is absent even though the adapter is enabled.

## Non-goals

- **Reachability of custom `activationScripts` entries** (T13 in
  `odd/tasks/docker-runtime.md`, the dead `rosetta` fragment). Same defect class,
  different property: T13 is about whether an entry runs at all; this work unit
  is about what it calls. The new guard is its natural future home.
- **Runtime launchd program paths** (`/bin/bash`, `/bin/sh` above) are audited
  here but not guarded: a wrong path there surfaces in the agent's own logs
  instead of aborting a switch.

## Verification summary

_(filled in as tasks close)_
