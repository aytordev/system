## Move Change to Archive (mechanical, lossless)

**Impact: CRITICAL**

Step 2: relocate the completed change folder to
`openspec/changes/archive/YYYY-MM-DD-{change-name}/`. Use the adapter so the
move is deterministic and auditable.

`openspec` and `hybrid` only. `engram` keeps references, no filesystem copy.

### Pre-flight (before any move)

1. The closure gate (`rules/execution-closure-gate.md`) passed with
   `disposition: verified`.
2. All domain deltas were composed and staged (`rules/execution-sync-specs.md`).
3. The destination does not exist. A same-day re-archive of the same change is a
   **collision**, not an overwrite.

### Move

```sh
aytordev-sdd archive <change-name> [--root openspec] [--date YYYY-MM-DD]
```

The adapter performs the move mechanically:

- **Pre-move snapshot** — the source is copied to a temporary snapshot before the
  move, so the source bytes exist independently of the destination.
- **Move** — `openspec/changes/{change}/` → `openspec/changes/archive/YYYY-MM-DD-{change}/`.
- **Readback** — `diff -r` the snapshot against the destination. A mismatch rolls
  the destination back and restores the source from the snapshot.
- **Collision refusal** — if the destination already exists, exit non-zero with
  `refusing to overwrite` and change nothing.
- On success it prints `aytordev-sdd.archive/v1` with the source, destination,
  date, and file count, and removes the transient snapshot.

Default date is today in ISO `YYYY-MM-DD`. The archive is an audit trail: never
delete or modify an archived change.

### Interrupted-operation recovery

The snapshot is the recovery artifact. If the operation is interrupted:

- **Destination exists and source is gone** (interrupted after the move): the
  change is in the archive. Verify with `diff -r` against the printed snapshot if
  it still exists; otherwise the archive itself is authoritative.
- **Source exists and destination is partial** (interrupted during a copy-style
  move): remove the partial destination and re-run `aytordev-sdd archive`. The
  pre-flight collision check accepts the destination only when it is absent.
- **Snapshot path is printed on failure.** If the automatic rollback could not
  complete, restore manually with
  `cp -R <snapshot>/. openspec/changes/{change}/` and remove any partial
  destination before retrying.
- A killed process never leaves a half-promoted canonical spec: promotion of
  Step 1 happens only after compose validation and before this move; recovery
  re-runs only the move, never the compose.

### Output

```
Archived: openspec/changes/{change}/ → openspec/changes/archive/YYYY-MM-DD-{change}/
Files moved: {count}
```
