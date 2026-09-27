# Feature: engram-single-store

## Objective

Guarantee that Engram's data lives in exactly one place, on two fronts that
failed for the same underlying reason:

1. **Make the data directory intrinsic to the binary.** Today it is carried only
   by `home.sessionVariables`, which is the channel that has already failed once
   (observation #66) and that silently produces a second store when it is lost.
2. **Recover the 21 observations stranded in that second store**, so Pi can see
   them again.

## Problem

`modules/home/programs/terminal/tools/engram/default.nix` declares the data
directory exclusively through `home.sessionVariables.ENGRAM_DATA_DIR`. That
renders into `hm-session-vars.sh`, whose first statement is

```sh
if [ -n "${__HM_SESS_VARS_SOURCED-}" ]; then return; fi
```

When a shell is left with the guard exported but no payload, every descendant
shell skips the payload **and re-exports the guard**. The loss is
self-propagating and never self-heals. `engram` then runs with no
`ENGRAM_DATA_DIR` and falls back to its compiled default, `~/.engram`.

Two concrete consequences observed on this machine:

- `gentle-engram/index.ts` spawns `spawn(ENGRAM_BIN, ["serve"], { stdio:
  "ignore" })` with **no explicit env**. Inheriting a poisoned environment is
  exactly how an orphan `engram serve` appeared on 21/9 23:00 and squatted on
  port 7437 for two days, serving the default store while the Nix-configured
  store could never claim the port. Every `mem_*` tool failed with
  `Engram server ownership mismatch`, which was the *correct* refusal.
- `localInstanceID()` runs `ENGRAM_BIN instance-id`. With the variable absent it
  reports the default store's identity, so the ownership check can also fail in
  the opposite direction.

The same poisoning created the second store, and that store was never
consolidated:

| | stray `~/.engram` | canonical `~/.local/share/engram` |
| --- | --- | --- |
| observations | 25 | 72 |
| sessions | 25 | 13 |
| prompts | 49 | — |
| overlapping by `sync_id` | 4 | |
| **only in the stray** | **21 obs, 15 sessions, ~49 prompts** | |

Among those 21 are `odd/gentle-stack-upgrade/tasks` (the **previous feature's
ODD mirror**), `patterns/jq-anchors-and-treefmt-ci`, the whole
`pen-design-skills` research/decision/proposal chain, and
`incident/pen-research-sensitive-read`. Because `mem_*` reads the canonical
store, Pi has never seen any of it. This also explains a symptom that was
misread earlier as a mirroring failure: the previous feature's mirror did exist;
it was in the wrong store.

## Why

- Observation #66 already named this root cause and its own durable remedy
  ("anything a subprocess depends on should be set on the process itself or
  wrapped into the Nix binary") and then left it undone, applying only a runtime
  patch to `~/.pi/agent/mcp.json`. That patch can be silently lost, because the
  Gentle AI installer rewrites that file.
- The leak is **live**: the stray store held 4 observations at the 22/9 merge and
  holds 25 now, with WAL writes as recent as 23/9 06:51.
- Leaving the memories stranded means the memory system keeps reporting a
  partial history as if it were complete.

## Scope

- A wrapped `engram` package in the Home Manager module: the wrapper sets the
  data directory (and the no-update-check flag) and `exec`s the real binary, so
  every spawn carries it regardless of the shell environment.
- `ENGRAM_BIN` points at the wrapper, which is what every spawner uses.
- One consolidation of the stray store into the canonical one, in a single
  transaction, with deduplication by `sync_id`.

## Non-goals

- Not fixing the `__HM_SESS_VARS_SOURCED` poisoning itself. That is a shell
  environment problem; this feature removes its *data* consequence.
- Not migrating `engram` into the module's `package` option semantics beyond
  wrapping: Nix already owns the binary, and the upstream package stays a plain
  derivation.
- Not deleting `~/.engram`. It is kept as the rollback point and as evidence.
- Not touching the `cloud:system` sync target with its 180 unacknowledged
  mutations. `engram doctor` reports it as `foreign_sync_target` with
  `requires_confirmation: true`; that is a separate decision.
- Not changing the `~/.pi/agent/mcp.json` runtime patch. It becomes redundant
  but harmless, and it is owned by the native installer.

## Constraints

- **The merge touches live data.** Both stores must be backed up first — not just
  the target: the stray holds sessions and prompts the canonical lacks, and
  foreign keys run from observations to sessions.
- **The canonical store has a running server.** It must be quiesced for the
  merge, and restarted afterwards with the correct environment.
- **FTS is real, not external-content-only.** Triggers must be allowed to fire so
  inserts re-index themselves; verification then needs
  `insert into observations_fts(observations_fts) values('integrity-check')` in
  addition to `PRAGMA integrity_check`.
- **Wrapping changes what `ENGRAM_BIN` is** — a script rather than the Go binary.
  Anything that inspects the executable (including `gentle-ai doctor`'s
  `tool:engram` check) must still see a working `engram`; the wrapper must be
  argument-transparent.
- A repository commit here supersedes the parked native-review lineage
  `review-1ec149e659004550` (frozen target `sha256:042ce2a7…`). Accepted
  deliberately: that lineage cannot close until upstream fixes the relay, and it
  holds only one of four lens results.

## Decisions

- **Wrap in the module, not in `packages/engram`.** The data directory is
  `${config.xdg.dataHome}/engram`, a Home Manager value that the upstream
  derivation must not know about.
- **Keep `ENGRAM_DATA_DIR` in `home.sessionVariables` as well.** The wrapper is
  the guarantee; the session variable stays as the convenience path for shells
  and for inspection. Recorded explicitly so the redundancy is a decision and not
  an oversight.
- **Merge with the same recipe #66 validated**: backup, checkpoint both WALs,
  `ATTACH` + `INSERT … SELECT` in one `BEGIN IMMEDIATE` transaction in foreign-key
  order, deduplicate by `sync_id`, then verify three ways.
- **Merge before wrapping.** The merge depends on a known-good environment and a
  server under control; the wrapper is independent of it.

## Progress

### Evidence gathered before writing

- The orphan server held `~/.engram/engram.db` open (verified with `lsof -p`),
  and `~/.engram/.instance-id` (`04981239…`) matched its `/health` report
  exactly, while the configured store's is `27cae772…`. `gentle-engram`
  `index.ts:676` throws on `probeEngramHealth` returning `"foreign"`.
- `gentle-ai doctor` finds `engram` at
  `/etc/profiles/per-user/aytordev/bin/engram` and reports `engram:reachable`;
  there is exactly one `engram` binary on the machine.
- Stray-only topic keys: `odd/gentle-stack-upgrade/tasks`,
  `odd/pen-design-skills/delivery`, `patterns/jq-anchors-and-treefmt-ci`,
  `research/pen-design-skills/{nisus-design-system,registration-feasibility}`,
  `decision/pen-design-skills/{authoring-contract,integration-priority}`,
  `proposal/pen-design-skills/content-composition`,
  `incident/pen-research-sensitive-read`,
  `discovery/pen-design-skills-recovery-status`.
- Overlap measured by `sync_id` between the two stores: 4 of 25.
- Backups taken earlier this session already exist
  (`~/engram-backup-*` and `~/engram-default-backup-*`), but fresh ones are taken
  immediately before the merge because the canonical store has changed since.

### Work unit 1 (WU1) — commit `375ff2e fix(engram): carry the data directory in
  the binary, not the shell env`, one file:
`modules/home/programs/terminal/tools/engram/default.nix`.

**The first design was wrong and was replaced.** It derived the wrapper and
re-bound `home.packages` and `ENGRAM_BIN` to it. That deterministically failed
`packagesEnabled`, `engramEnvironment` and `engramOverrideShared`, because the
check compares packages by `outPath`:

```nix
installed = home: package: lib.any (p: p.outPath == package.outPath) home.home.packages;
```

and asserts that uniformly for `["pi" "gentle-ai" "engram"]`. That is not
plumbing: it encodes the module contract *a tool publishes its configured
package verbatim*. Weakening the check to accommodate the change was refused,
so the wrapper became the **default of the `package` option** instead. `cfg.package`
is then the wrapper itself, every binding in the config block stays byte-identical
to the original, and the check passes **as written**.

Consequence: `lib.mkPackageOption` cannot express a derivation-valued default
(its `default` is an attribute path into `pkgs`), so the option moved to
`lib.mkOption { type = lib.types.package; … }`. Option names are unchanged and
`checks/module-contract` constrains names only.

Executed evidence, from the independent verifier:

- The flake-evaluated default resolves to
  `/nix/store/61m04ni2479v2kznykc36q9l0jvvw6gr-engram-wrapped`, whose body is
  `export ENGRAM_DATA_DIR='/Users/aytordev/.local/share/engram'`,
  `export ENGRAM_NO_UPDATE_CHECK='1'`, `exec …/bin/engram "$@"`.
- `env -u ENGRAM_DATA_DIR <wrapped>/bin/engram instance-id` prints
  `27cae772…` (canonical). Forcing `ENGRAM_DATA_DIR=/tmp/engram-verify-decoy`
  prints the same canonical id, because `--set` overrides the inherited
  environment; the decoy directory was never created.
- `env -u ENGRAM_DATA_DIR <upstream>/bin/engram instance-id` prints
  `04981239…`, the stray store's identity. That is the bug, reproduced.
- `integration-gentle-ai-engine` (previously exit 1), `integration-home-module`,
  `integration-module-contract` and `integration-docs-generation` all exit 0.
  `git diff -- checks/` is empty. `alejandra --check` is clean with the file's
  sha256 unchanged across the run, so no in-place write happened; `statix` and
  `deadnix` are clean. `flake.lock` was not written.
- Naming follows `AGENTS.md`: the binding is `engramWrapped` (camelCase for
  variables); the `runCommand` name string stays `"engram-wrapped"`
  (kebab-case for a derivation name).

**Deliberate trade-off, documented in the module:** overriding `package` opts out
of the data-directory guarantee, and `home.sessionVariables.ENGRAM_DATA_DIR`
remains the fallback for that case.

### Work unit 2 (WU2) — the store consolidation, no repository change

Recipe: fresh backups of **both** stores (sha256 verified identical to the live
files), stop the canonical `engram serve`, `PRAGMA wal_checkpoint(TRUNCATE)` on
both, then one `sqlite3` session with
`PRAGMA foreign_keys=ON` + `ATTACH` + a single `BEGIN IMMEDIATE` containing
`sessions` → `observations` → `user_prompts` in foreign-key order, deduplicated
with `NOT EXISTS` against `sync_id` (not `NOT IN`, which is not NULL-safe) and
omitting the integer `id` column so SQLite assigns fresh ones. Column lists were
derived from `pragma table_info` at run time rather than hand-written, after
confirming all three schemas are identical between the stores. The server was
restarted afterwards and reports the canonical identity.

**Durable delta: +21 observations, +15 sessions, +28 prompts.** Report the delta,
not the totals: the verifier caught the live numbers drifting within minutes
(94 observations, but 30 sessions and 58 prompts rather than the merge-instant 28
and 55) because the canonical store keeps growing while it is served, including
from this session's own writes.

Verification, all read-only:

| check | result |
| --- | --- |
| `PRAGMA integrity_check` | `ok` |
| `PRAGMA foreign_key_check` | empty |
| FTS `integrity-check` (`observations_fts`, `prompts_fts`) | exit 0 |
| duplicate `sync_id` groups | none, both tables |
| dangling `session_id` | 0 in both tables |
| the ten stray-only `topic_key` values | present exactly once each |
| FTS population vs table counts | 94 = 94, 58 = 58 |
| falsification sweep | the 21 new observation `sync_id`s are 21/21 present in the stray backup; 15 sessions and 28 prompts come from the stray; **zero** pre-merge rows are missing from the live store |

### Recorded, not fixed

- **The stray store's data file was untouched; its directory was not.**
  `engram.db` is byte-identical to the pre-merge backup (`87ab08c4…`) and the
  counts match, but the pre-merge checkpoint zeroed its `-wal` and touched its
  `-shm`. **Rollback caveat:** restore `engram.db` alone from
  `~/engram-premerge-stray-<ts>` — that directory's `engram.db-wal` still holds
  1006 frames from 06:51 and copying db+wal+shm together could re-apply them. The
  live stray, whose WAL is 0 bytes, is the cleaner rollback artifact.
- **Nothing asserts the wrapper's embedded data directory.**
  `checks/gentle-ai-engine` asserts the *session variable*, not the wrapper's
  `--set`, so the guarantee this commit adds is covered only by manual evidence.
  A behavioural check would need a writable data directory and a live process,
  which is the same class of operation the upstream package already excludes:
  `packages/engram/package.nix` sets `doCheck = false` because "v2.0.0-rc adds
  autosync e2e tests that bind a loopback port via `httptest`, which the Nix
  sandbox forbids". A structural gap, not an oversight.
- **The override path was reasoned, not executed.** `engramOverrideShared` and
  `packageOverrides` are green and the module publishes `cfg.package` verbatim,
  so an overridden package ships unwrapped — but no dedicated override
  evaluation was run.
- **The parked review is now superseded.** `.git/gentle-ai/review-transactions/v2/LOCK`,
  `review-1ec149e659004550/` and a `candidate-views/` entry remain on disk. WU1
  moved `HEAD`, so the frozen candidate `sha256:042ce2a7…` can no longer close;
  that lineage holds one of four lens results. It was **not** hand-edited:
  review authority is never manipulated by hand.

## Next step

Both changes are applied and independently verified. Still open, deliberately:

- The wrapper is committed but **not active** — a `darwin-switch` is required for
  it to reach the live profile, and a Pi restart is required for a session whose
  provider already failed to initialise.
- The `cloud:system` sync target with its 180 unacknowledged mutations
  (`foreign_sync_target`, `requires_confirmation: true`).
- The runtime patch in `~/.pi/agent/mcp.json`: now redundant, owned by the native
  installer, left in place.
