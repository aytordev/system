## Verify Archive Completeness and Return Summary

**Impact: CRITICAL**

Step 3: confirm the closure is complete and truthfully reported, then compile
the `sdd-result/v1` envelope. Read `_shared/closure-policy.md`.

### Verification Checklist

Confirm:

1. **Closure gate passed** with `disposition: verified` for the candidate
   revision (Step 0).
2. **Canonical specs promoted**: every staged domain was published; unrelated
   requirements survived (Step 1).
3. **Change archived**: source no longer exists; destination exists and passed
   the `diff -r` readback (Step 2).
4. **No fabricated PASS**: `status: success` is returned only when all of the
   above hold. A non-success disposition never emits `status: success`.

### Disposition → Envelope

| Outcome | `kind` / `status` | Advances |
|---------|-------------------|----------|
| Verified closure | `final` / `success` | yes |
| `unverified` (missing/stale/failed/CRITICAL verification) | `final` / `blocked` | no |
| `paused` | `final` / `partial` | no |
| `abandoned` | `cancelled` or `final` / `failed` | no |

Canonical specs are **not** promoted for any non-success row. Report the reason
and the recommended next phase (`sdd-apply` or `sdd-verify`).

### Summary Template

```markdown
# Archive Complete: {change-name}

## Change Information
- **Change Name**: {change-name}
- **Candidate Revision**: {revision}
- **Archive Location**: `openspec/changes/archive/YYYY-MM-DD-{change-name}/`
- **Archived On**: {timestamp}

## Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| auth | ADDED | 3 new requirements |
| api | MODIFIED | 2 requirements updated |
| ui | created | New full spec |

## Closure Gate
disposition: verified; tasks {completed}/{total}; verification {evidence_revision}

## Archive Contents
- [x] proposal.md
- [x] specs/{domain}/spec.md
- [x] design.md
- [x] tasks.md
- [x] verify-report.md

## Source of Truth Updated
Main specs in `openspec/specs/` now reflect this change.

## SDD Cycle Complete
{change-name} is archived. The change is complete and the specs are up to date.
```

### Result Envelope

Return an `sdd-result/v1` envelope (`_shared/return-envelope.md`):

```json
{
  "schema": "sdd-result/v1",
  "kind": "final",
  "status": "success | partial | blocked | failed",
  "executive_summary": "{change-name} archived; specs synced and verified.",
  "artifacts": ["openspec/changes/archive/YYYY-MM-DD-{change-name}/"],
  "evidence": [
    {
      "check": "aytordev-sdd closure {change-name} --revision {rev}",
      "exit": 0,
      "result": "pass",
      "revision": "{rev}",
      "relevant": "closure gate: tasks complete + current verification"
    }
  ],
  "next_recommended": null,
  "risks": [],
  "skill_resolution": "paths-injected"
}
```

A `final` envelope MUST carry at least one current evidence entry; the closure
gate result above is the required row. A non-success disposition returns the
matching non-success `status` with the reason, and never `success`.

### Persistence

Persist to the backend the orchestrator resolved (no cross-store fallback):

- **openspec**: the summary lives in the archive folder (the archived change).
- **engram**: save the closure summary to Engram with topic_key
  `sdd/{change-name}/archive-report`, referencing the change observations and the
  final evidence; do not create filesystem copies.
- **hybrid**: the archive folder summary AND the Engram observation.
- **none**: return inline only.
