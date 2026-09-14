# Local SDD Engine Slice Results (T19 input)

## Scope

This is a bounded measurement spike for task T19 of the
[implementation plan](./implementation-plan.md), building on
[engine-feasibility.md](./engine-feasibility.md) and
[engine-prototype-results.md](./engine-prototype-results.md). It builds a
disposable local-engine slice, runs it and the pinned `gentle-ai` v2.9.0 binary
over the same fixtures, and reports the measured differences.

It does **not** select an engine, does not compare workflow quality, and does
**not** claim parity or superiority beyond the specific observations below. It
does not build a client adapter, exercise concurrency, or run a full lifecycle.
The owner still chooses the engine in T19.

Every claim is labelled **(proved)** (directly observed in this spike) or
**(unverified)** (inferred, estimated, or not exercised here).

## Environment

- Host: aarch64-darwin (`arm64`), macOS 26.6.2 (build 25G83). **(proved)**
- Nix: `nix (Nix) 2.35.2`; evaluation nixpkgs
  `/nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source`. **(proved)**
- Slice runtime: pinned-nixpkgs `python3` 3.14.7 at
  `/nix/store/4l8r0s2r5fna7src82b5fc2hixdvfyw0-python3-3.14.7` (already realized
  in the store). Chosen because it is the cheapest available runtime: no extra
  package is fetched, it is already present, and its standard library covers
  JSON, regex, file I/O, and subprocess with zero third-party dependencies.
  **(proved)**
- `gentle-ai` v2.9.0 built in the prior spike from the signed release archive
  (SHA-256 `0a58d81c...559bb`); store path
  `/nix/store/mvcd8gn9n4p13wzc05q4fwrw7wlzxpm6-gentle-ai-2.9.0`, invoked via
  `/var/.../t19-prototype/result/bin/gentle-ai`. **(proved)**
- `engram` 1.7.0 from the ambient profile (`/etc/profiles/.../engram`). **(proved)**
- Repo baseline `HEAD` = `3752d5c43840671467487e9805ef867c2816f5b8`. This spike
  adds one repo file (this document); all prototype code and fixtures live under
  `/var/.../t19-local-prototype/`. **(proved)**

## Prototype design

One stdlib-only file, `sdd_local.py` (305 lines, 269 non-blank), plus a
throwaway fixture generator `setup_cmp.py` that is harness, not engine. The
slice resolves one change over an OpenSpec layout or an Engram data directory and
exposes three subcommands: `status`, `complete`, and `archive-ready`.

Store resolution is a regex over `openspec/config.yaml` (`artifact_store:`),
defaulting to `openspec`, mirroring the CLI's declared-store rule at a minimal
level. Artifact states are intentionally coarse:

```python
def state_of(text, kind):
    """empty -> partial; present but shapeless -> partial; else done."""
    if text is None:
        return "missing"
    if not text.strip():
        return "partial"
    if kind == "specs" and not SCENARIO.search(text):
        return "partial"
    if kind == "tasks" and not CKLIST.search(text):
        return "partial"
    return "done"
```

Task progress counts Markdown checkboxes; the routing token is a linear policy:

```python
def next_token(artifacts, progress, verify_ok):
    if artifacts["proposal"] != "done": return "propose"
    if artifacts["specs"] != "done":    return "spec"
    if artifacts["design"] != "done":   return "design"
    if artifacts["tasks"] != "done":    return "tasks"
    if not progress["allComplete"]:     return "apply"
    if artifacts["verifyReport"] != "done" or not verify_ok:
        return "verify"
    return "archive"
```

For Engram the slice shells out to `engram export <file>` with the inherited
`ENGRAM_DATA_DIR`, then filters observations by
`title.startswith("sdd/{change}/")`, case-insensitive `project`, and
`scope != "personal"` — the same matching rule the CLI applies. `complete` marks
every `[ ]` to `[x]` in OpenSpec `tasks.md`, re-reads the file, and returns a
`readbackConfirmed` boolean. `archive-ready` implements a deliberately partial
C11: it refuses unless tasks are complete and a report is present, current
(mtime/revision newer than the planning artifacts) and passing; because it
cannot prove *relevance*, it always reports `relevant: "unverified"` and refuses
with `relevant_verification_unverifiable` even when everything else passes.

## Measurement (LOC/deps)

| Item | Value | Label |
| --- | --- | --- |
| Engine files | 1 (`sdd_local.py`) | proved |
| Engine LOC | 305 total / 269 non-blank | proved |
| Harness files | 1 (`setup_cmp.py`, 85 total lines) | proved |
| Third-party dependencies | 0 | proved |
| Stdlib imports | `argparse, hashlib, json, os, re, subprocess, sys` | proved |
| External runtime dependency | `engram` CLI (Engram adapter only) | proved |
| Build/package step | none (python3 already realized) | proved |
| Slice LOC vs upstream `internal/sddstatus` non-test (10,884) | 2.80% | proved (ratio) |
| Slice LOC vs upstream `internal` non-test (11,540, sparse clone) | 2.64% | proved (ratio) |

Upstream anchor measured in the read-only clone
`/var/.../gentle-ai-sdd-audit` at `be49554794917ae92a6dc9dbfa2eb3db5cf70084`:
`internal/sddstatus` non-test 10,884 LOC, test 19,857 LOC across 92 files and
390 `Test` functions; `internal` non-test 11,540 LOC, test 27,341 LOC. The clone
is sparse (no `cmd/`), so the real upstream total is larger. **(proved)**

## Side-by-side comparison with the CLI on the same fixtures

Fixtures reuse the prior spike's shapes. The prior OpenSpec fixture held only
`proposal.md`; the same fixture was extended with `specs/core/spec.md`,
`design.md`, `tasks.md`, and a valid `verify-report.md` so task readback and
C11 could actually be exercised. Engram reuses the prior isolated-data-dir
setup with one observation per artifact. Both engines read identical bytes.
**(proved)**

### OpenSpec lifecycle (CLI `sdd-status --json` vs slice `status`)

| Change state | CLI artifacts (P/S/D/T/V) | CLI next | Slice next | Match |
| --- | --- | --- | --- | --- |
| `prop` (proposal only) | done/missing/missing/missing/missing | `spec` | `spec` | yes (proved) |
| `full` (planning, tasks 0/3) | done/done/done/done/missing | `apply` | `apply` | yes (proved) |
| `done` (tasks 3/3, no report) | done/done/done/done/missing | `verify` | `verify` | yes (proved) |
| `verified` (valid report) | done/done/done/done/done | `archive` | `archive` | yes (proved) |
| `part` (empty proposal) | partial/…/missing | `propose` | `propose` | yes (proved) |

`taskProgress` matched exactly in every state, including `total=3, completed=0/3`
and `allComplete` transitions. **(proved)**

### Engram store

| Case | CLI | Slice | Match |
| --- | --- | --- | --- |
| Planning complete, tasks 0/2 | `artifactStore: engram`, next `apply` | same, next `apply` | yes (proved) |
| Wrong/unmatched project | all missing, next `sdd-new`, blocked "No SDD changes found…" | all missing, next `propose`, blocked "change not found…" | **no (proved)** |

The positive Engram path is byte-compatible on the fields the slice implements
(artifact states, task progress, routing). The unresolved-change token differs:
the CLI routes to `sdd-new`, the slice to `propose`. **(proved)**

### Task-completion readback and archive readiness

- Slice `complete` on `full` rewrote `tasks.md`, re-read it, and returned
  `before {0/3}`, `after {3/3}`, `readbackConfirmed: true`. A subsequent CLI
  `sdd-status full` then reported `allComplete: true`, `applyState: all_done`,
  `nextRecommended: verify`. The two stores agreed on the persisted result.
  **(proved for OpenSpec)**
- Closure policy C11:

| State | CLI `archive` / next | Slice `ready` | Slice reason |
| --- | --- | --- | --- |
| `prop` | blocked / `spec` | false | `tasks_incomplete` |
| `full` | blocked / `verify` | false | `verification_missing` |
| `done` | blocked / `verify` | false | `verification_missing` |
| `verified` | **ready** / `archive` | **false** (`readyIfRelevanceAssumed: true`) | `relevant_verification_unverifiable` |

The only divergence that matters for close is the last row: the CLI admits
archive on a validated `gentle-ai.verify-result/v1` envelope, while the slice
cannot establish relevance and refuses. **(proved)**

### Validator and refusal differences observed

- A report without the strict envelope: CLI keeps `nextRecommended: verify` and
  emits a detailed `blockedReasons[0]` ("missing valid
  gentle-ai.verify-result/v1 envelope…"); the slice also routes to `verify` but
  emits **no** `blockedReasons`. The slice hides the cause. **(proved)**
- `gentle-ai sdd-verify-validate` rejected count mismatches
  (`verify result total 1 does not match actual scenario count 2`) and non-envelope
  bytes, exit 1. The slice has no validator and would silently accept both.
  **(proved)**
- `sdd-archive` is **not** a CLI command (`Error: unknown command "sdd-archive"`,
  exit 1): archive execution is skill/prose, and the CLI only surfaces
  `dependencies.archive: ready`. A local engine must own the archive move itself.
  **(proved)**

## What the slice does not guarantee

- **Validators and evidence.** Only a `verdict:` token and artifact mtime are
  read; there is no verify-result envelope parser, requirement/scenario count
  check, command/exit-code/output-hash verification, or revision binding. The
  CLI's `verification.go` (785 non-test LOC) is the visible tip of this. **(proved
  for slice absence; unverified for full upstream surface)**
- **Relevance (C11).** The slice cannot map changed files to verified evidence, so
  it always refuses archive. The CLI's `verified` fixture reaches
  `archive: ready`. **(proved)**
- **Git-common-dir attempt ledger.** No `sdd-attempt acquire|settle`, budget,
  ordinal, token, consent, or immutable chain. Upstream `runtime_ledger.go` alone
  is 4,336 non-test LOC. **(proved for absence; the ledger's exact guarantees are
  outside this spike)**
- **Concurrency, idempotency, interruption/recovery.** Nothing; not measured.
  **(proved for absence)**
- **Migration/state upgrades/rollback.** Nothing; the slice assumes today's
  fixture shapes. **(proved for absence)**
- **Review machinery.** No `reviewOffer`, lineage, gate, or correction lane.
  **(proved for absence)**
- **Engram write path.** `engram` 1.7.0 has no update command; re-importing a
  mutated export **duplicates** the observation (verified in a scratch data dir).
  The slice therefore refuses Engram completion (`readbackConfirmed: false`,
  exit 2) rather than fabricate a confirmed update. A production local engine
  must use an MCP `mem_update`-equivalent or add a write adapter. **(proved)**
- **`hybrid` and `none`.**
  `resolve_store` recognizes them but the read path treats non-`engram` as
  OpenSpec; neither mode was exercised. The prior spike showed `artifact_store:
  none` is surfaced as `openspec`. **(unverified)**
- **Platform coverage.** Only aarch64-darwin was exercised. **(unverified)**
- **Artifact-state fidelity.** The `partial` rule was proved equal only for an
  empty file. Shape-based partiality (e.g. specs without scenarios) is the
  slice's own heuristic and was not cross-checked against the CLI's heuristics.
  **(unverified)**

## Production effort estimate

Anchored on the slice, not a guess: the slice is 305 LOC and reproduces only the
status read path for one change over two stores, one OpenSpec write readback, and
one refusal. That is ~2.8% of upstream's `internal/sddstatus` non-test LOC. The
estimates below are **unverified** planning ranges derived by mapping each T19
subsystem to whether the slice touched it and by scaling the upstream packages
that implement the missing behavior.

| Subsystem (plan table) | Slice coverage | Anchored production estimate (non-test LOC) |
| --- | --- | --- |
| Change identity and context | root+change+store resolution (~40 LOC) | 300–600 |
| Persistence adapters | OpenSpec R/W; Engram read only (~120 LOC) | 800–1,500, plus resolving Engram/MCP writes |
| Workflow state | coarse states + linear token (~80 LOC) | 1,000–2,000 |
| Dispatch boundary | none | 400–800, plus both client adapters (T05/T07) |
| Evidence and validators | token + mtime only | 1,500–3,000 |
| Completion and archive | checkbox rewrite + refuse | 1,000–2,000 (delta composition, lossless move, collisions) |
| Concurrency and migration | none | 2,000–4,000 (upstream `runtime_ledger.go` = 4,336) |
| Distribution and tests | none | packaging + fixtures; expect a test-to-code ratio near the slice's own harness plus upstream's ~1.8:1 |

Total: roughly **7,000–15,000 production LOC plus a comparable test suite**,
consistent with upstream shipping 10,884 non-test and 19,857 test LOC for the
status package alone (sparse clone, `cmd/` excluded). The slice demonstrates
that the read path is cheap and the guarantees are expensive. **(unverified)**

## Blockers and unknowns

1. **Engram write/update contract.** The CLI-only path duplicates observations;
   the intended `mem_update` route is MCP, whose behavior in the eventual client
   is untested. This blocks any local Engram task-completion readback. **(proved
   duplication; unverified for MCP)**
2. **Relevance validation is the crux of C11.** The slice cannot decide it. How
   much of upstream's strict verify-result parser and scenario/requirement
   counting is reusable, and under what attribution, is unmeasured. **(unverified)**
3. **Archive execution ownership.** Since `sdd-archive` is not a CLI command, a
   local engine must implement deterministic delta composition and lossless move
   itself; the CLI's `openspec_archive_compose.go` is 357 non-test LOC but its
   behavior was not exercised. **(proved command absence; composition unverified)**
4. **`hybrid` and `none` semantics.** Not mapped or exercised; the slice
   conflates them with OpenSpec. **(unverified)**
5. **No concurrency/idempotency evidence.** Neither engine was run with two
   changes or partial writes. **(unverified)**
6. **Single platform, single runtime.** Only aarch64-darwin and python3 3.14.7
   were used; cross-platform packaging is unmeasured. **(unverified)**
7. **Client handoff.** No OpenCode/Pi adapter consumed either engine's output;
   the comparison is CLI-vs-slice only. **(unverified)**

## Verification log

All commands ran from
`/Users/avicente/Developer/aytordev/system` unless a working directory is shown.
`B` = `/var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-local-prototype`;
`PROTO` = `/var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-prototype`;
`PY` = `/nix/store/4l8r0s2r5fna7src82b5fc2hixdvfyw0-python3-3.14.7/bin/python3`;
`GA` = `$PROTO/result/bin/gentle-ai`.

Environment and runtime choice:

- `nix eval --raw --impure --expr 'let pkgs = import /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source { system = "aarch64-darwin"; }; in pkgs.python3.version'`
  -> `3.14.7`.
- `$PY -c 'import json,sys,os,re,subprocess; print("stdlib ok")'` -> ok.
- `$PROTO/result/bin/gentle-ai version` -> `gentle-ai 2.9.0`; `engram version` ->
  `engram 1.7.0`.

Fixtures (same shapes as `engine-prototype-results.md`, extended for readback):

- `cp -R $PROTO/ws $B/ws`; fresh `$B/ws-engram` with
  `openspec/config.yaml` = `artifact_store: engram`; isolated `$B/engram-data`.
- `$PY $B/setup_cmp.py` created four OpenSpec lifecycle changes
  (`prop`, `full`, `done`, `verified`) and the Engram repo `$B/cmp-engram`.

CLI and slice comparison (workdir `$B/cmp`):

- `$GA sdd-status <change> --json` for `prop`, `full`, `done`, `verified`, `part`,
  `plain`, plus no-argument auto-selection.
- `$PY $B/sdd_local.py status --change <change> --root $B/cmp`.
- `$PY $B/sdd_local.py complete --change full --root $B/cmp` ->
  `readbackConfirmed: true`; then `$GA sdd-status full --json` ->
  `applyState: all_done`, `nextRecommended: verify`.
- `$PY $B/sdd_local.py archive-ready --change <change> --root $B/cmp` for all
  four states; `$GA sdd-status` `dependencies.archive` compared alongside.
- Edge cases: empty `proposal.md` -> both `partial`/`propose`; non-envelope
  `verify-report.md` -> both `verify`, CLI emits `blockedReasons`, slice does not.

Engram comparison (workdir `$B/cmp-engram`, `ENGRAM_DATA_DIR=$B/cmp-engram-data`):

- `engram save "sdd/dummy/{proposal,spec,design,tasks}" … --project cmp-engram
  --scope project`.
- `ENGRAM_PROJECT=cmp-engram $GA sdd-status dummy --json` and
  `$PY $B/sdd_local.py status --change dummy --root $B/cmp-engram --data-dir $B/cmp-engram-data --project cmp-engram`
  -> identical states, progress, and `apply` route.
- `ENGRAM_PROJECT=wrong-project` on both -> CLI `sdd-new` / slice `propose`.
- Scratch (not fixtures): `engram import` of a mutated export produced two rows
  with the same title (`revision_count=1, duplicate_count=1`), proving the
  duplicate-instead-of-update behavior.

Validators and commands:

- `$GA sdd-verify-validate --input <report> --requirements 1 --scenarios 1` ->
  `{"valid": true, "verdict": "pass", …}`, exit 0.
- `$GA sdd-verify-validate … --scenarios 2` -> `verify result total 1 does not
  match actual scenario count 2`, exit 1; plain report -> missing-envelope error,
  exit 1.
- `$GA sdd-archive dummy --cwd <repo>` -> `Error: unknown command "sdd-archive"`,
  exit 1.

Measurement:

- `$PY -m py_compile $B/sdd_local.py` -> ok.
- `$PY` LOC counter -> `sdd_local.py: total=305 nonblank=269`;
  `setup_cmp.py: total=85 nonblank=67`.
- AST stdlib check -> `['argparse','hashlib','json','os','re','subprocess','sys']`,
  `all stdlib: True`.
- `find internal -name '*.go' ! -name '*_test.go' | xargs wc -l` -> `11540`;
  same for `internal/sddstatus` -> `10884`; test totals `27341` / `19857`;
  `runtime_ledger.go` -> `4336`.

Repo hygiene:

- `git rev-parse HEAD` -> `3752d5c43840671467487e9805ef867c2816f5b8`.
- `git status --short` before this file listed only the pre-existing AI-tools
  change; after writing, only this document is added. No prototype code, binary,
  or fixture entered the repo; no commit was made and no whole-flake check was
  run.
