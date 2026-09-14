## Write tasks.md with Phased Hierarchical Checklist

**Impact: CRITICAL**

Transform the analyzed design into a concrete task checklist organized by
implementation phase. Each work unit carries its own evidence; tests stay with
the unit they verify instead of being deferred to a late phase.

### Format

```markdown
# Tasks: {change-name}

## Phase 1: Foundation / Infrastructure
- [ ] 1.1 {Specific task with file path} — check: `{command}`; scenario: {REQ/S# | N/A — reason}; rollback: {boundary}
- [ ] 1.2 {task} — check: `{command}`; scenario: {REQ/S# | N/A — reason}; rollback: {boundary}

## Phase 2: Core Implementation
- [ ] 2.1 {task} — check: `{command}`; scenario: {REQ/S# | N/A — reason}; rollback: {boundary}

## Phase 3: Integration / Wiring
- [ ] 3.1 {task} — check: `{command}`; scenario: {REQ/S# | N/A — reason}; rollback: {boundary}

## Phase 4: Verification / Cleanup / Documentation
- [ ] 4.1 {docs/cleanup task} — check: `{command}`; scenario: N/A — {reason}; rollback: {boundary}

## Review Workload Forecast

- Estimated changed lines: {N}
- 400-line budget risk: {Low | Medium | High}
- Chained PRs recommended: {Yes | No}
- Decision needed before apply: {Yes | No}
- Suggested PR slices: {slice 1; slice 2 | —}
- Delivery strategy: {ask-on-risk | auto-chain | single-pr | exception-ok}
```

### Per-Unit Evidence

Every task line MUST carry all three evidence fields:

| Field | Requirement |
|-------|-------------|
| `check:` | The focused check / command that verifies this unit (the unit's own runner or Nix surface). |
| `scenario:` | The applicable runtime scenario it satisfies (`REQ/S#`), or `N/A — {reason}` when no runtime scenario applies (docs/config). Not optional. |
| `rollback:` | The boundary that removes just this unit without touching unrelated work. |

Tests belong to the unit they verify. Do NOT place a unit's only test in a later
phase; a phase may still gather cleanup/documentation work.

### Phase Organization

**Phase 1: Foundation / Infrastructure** — base types, interfaces, schemas,
migrations, config scaffolding, dependency-free helpers.

**Phase 2: Core Implementation** — main business logic, services, repositories,
core algorithms, internal components.

**Phase 3: Integration / Wiring** — middleware hookup, API route registration,
component wiring, external integrations.

**Phase 4: Verification / Cleanup / Documentation** — documentation updates,
migration guides, deprecated-code removal, README changes. This phase does NOT
own the coverage of earlier units; their focused checks and scenarios are already
attached to them.

### Task Numbering

Use hierarchical numbering: `{phase}.{task}` (e.g., `1.1`, `1.2`, `2.1`, `2.2`).

### Review Workload Forecast (required)

The orchestrator consumes this block from the task result to decide the delivery
strategy before apply. Emit it exactly, with the four decision fields
(`400-line budget risk`, `Chained PRs recommended`, `Decision needed before apply`,
`Estimated changed lines`) so the consumer never has to guess. Estimate changed
lines from the design's File Changes table, not from task count.

- `400-line budget risk` is `High` when estimated changed lines exceed 400.
- `Chained PRs recommended` is `Yes` when the change exceeds the review budget
  and can be sliced.
- `Decision needed before apply` is `Yes` when the delivery strategy requires a
  user decision (`ask-on-risk`) or a `size:exception`.

### Task Quality

See `references/task-quality-criteria.md` for what makes a good task.

### Writing to Filesystem

Use the backend the orchestrator resolved (no cross-store fallback):

- **openspec**: Write to `openspec/changes/{change-name}/tasks.md`.
- **engram**: Persist the tasks artifact to Engram; write no project files.
- **hybrid**: Both, with the partial-write/retry rules.
- **none**: Return tasks in the envelope only.
