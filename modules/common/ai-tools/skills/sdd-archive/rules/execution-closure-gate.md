## Closure Gate (C11) — Before Any Write

**Impact: CRITICAL**

Step 0: decide whether the change may close at all. This runs **before** any
canonical spec write or archive move. Read `_shared/closure-policy.md`.

### Gate the Engine

Run the C11 gate through the adapter (never the raw CLI):

```sh
aytordev-sdd closure <change> --revision <candidate-revision>
```

The adapter owns the readiness calculation and exits `0` **only** for
`disposition: verified`. The output is `aytordev-sdd.closure/v1`:

```json
{
  "schema": "aytordev-sdd.closure/v1",
  "change": "add-dark-mode",
  "ready": true,
  "disposition": "verified",
  "tasks": {"total": 8, "completed": 8, "allComplete": true},
  "verification": {"artifact": "done", "envelopeRevision": "sha256:..."},
  "archive": "ready",
  "reason": ""
}
```

### Dispositions and Outcomes

| `disposition` | Meaning | Action | Envelope |
|---------------|---------|--------|----------|
| `verified` | Tasks complete + current, validated, passing verification bound to the candidate revision. | Proceed to compose + archive. | `status: success` (only after the archive completes) |
| `incomplete-tasks` | Persisted tasks are not all checked. | Stop. Report the pending count; recommend `sdd-apply`. | `status: blocked` |
| `unverified` | Verification missing, failed, or CRITICAL. | Stop. Never promote specs. | `status: blocked` |
| `stale-verification` | A report exists but its `evidence_revision` is not the candidate revision. | Stop. Recommend `sdd-verify` to re-run. | `status: blocked` |
| `paused` / `abandoned` | Operator-directed administrative stop. | Stop and report; preserve the recorded backend and artifacts. | `partial` / `cancelled` |

`paused` and `abandoned` are never gate output: they are operator decisions the
phase records explicitly. A non-success disposition must **not** emit
`status: success` and must leave `openspec/specs/` byte-identical.

### Revision Binding

Pass `--revision` with the same candidate revision the verify report recorded
(`## Candidate Revision` / `evidence_revision`). The engine cannot detect a
well-formed but stale hash on its own; `--revision` is what turns that into a
typed `stale-verification` refusal.

### When the Gate Cannot Run

If the adapter is unavailable or the recorded backend is unreadable, report
`status: blocked` with the reason. Do not fall back to another store and do not
assume success.
