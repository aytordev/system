# SDD Phase Common — Resolved Artifact Locators

This file documents **Section B** of the executor protocol: how each SDD phase
receives and uses prior artifacts after the orchestrator has resolved the backend.

For skill loading, see `skill-loading.md` (Section A).
For persistence and backend rules, see `persistence-contract.md` (Section C).
For the pause/inline policy, see `execution-modes.md`.
For return envelope format, see `return-envelope.md` (Section D).

---

## Section B — Artifact Locators

The orchestrator resolves the backend and the artifact locators **before**
launching a phase (see `persistence-contract.md`) and passes them in the launch
prompt as:

```
## Artifact Locators

- backend: {engram | openspec | hybrid | none}
- backend_source: {explicit | available-selected | recorded}
- readiness: {ready | partial | blocked}
- change_root: {locator or —}
- artifacts:
  - proposal: {locator or —}
  - spec: {locator or —}
  - ...
```

A phase reads the exact locators it is given. It must NOT re-decide the backend,
probe another store, or synthesize a path on its own. If a required locator is
missing, return `status: blocked`; do not fabricate content.

### Locator Forms

| Backend | Locator form | Retrieval |
|---------|--------------|-----------|
| `engram` | `sdd/{change-name}/{artifact-type}` | `mem_search` → `mem_get_observation(id)` |
| `openspec` | `openspec/changes/{change-name}/...` | Read the file per `openspec-convention.md` |
| `hybrid` | both forms, Engram primary | Engram first; filesystem only if Engram has no complete artifact |
| `none` | `inline` | Use only what the orchestrator passed in the prompt |

### No Silent Cross-Store Fallback

- `engram`: if the locator is not found in Engram, report the artifact missing.
  Do NOT read `openspec/` or any other store.
- `openspec`: do not read Engram.
- `hybrid`: reading the second store is the defined behavior, not a fallback —
  Engram is primary and the filesystem is the fallback, reconciled per
  `persistence-contract.md`.
- `none`: do not read files or Engram.

### Engine Readiness Through the Adapter

Engine-dependent operations (`status`, `continue`, `attempt`, `verify`) go through
the `aytordev-sdd` adapter — never the raw `gentle-ai` CLI:

- The orchestrator runs `aytordev-sdd status <change>` to obtain the engine's
  readiness (resolved / blocked) and the declared backend, and uses that to seed
  the locators above.
- `aytordev-sdd continue|attempt|verify` back the phase transitions and validators
  where the engine owns them.
- `none` is session-local and is never sent to the engine.
- If the adapter is unavailable or returns `blocked`, keep the recorded/explicit
  backend, set `readiness: blocked`, and report it — do not silently fall back to
  another store.

### Result Validation Through the Adapter

Every phase returns an `sdd-result/v1` envelope (see `return-envelope.md`). The
orchestrator validates each result before acting and never advances on an empty,
malformed, nonterminal, cancelled, or non-`success` result:

- `launch-ack` and `progress` are **nonterminal** acknowledgements — record and
  keep waiting; they are not a phase result.
- `cancelled` and `final` with `partial | blocked | failed` stop the flow.
- Only `final` with `status: success`, current evidence, and completed units may
  advance.
- Engine-backed transitions (`attempt`, `verify`, `continue`) are validated by
  the pinned engine **through `aytordev-sdd`**. A rejected terminal result is
  reported as `blocked`; the orchestrator never re-derives engine state or calls
  the raw `gentle-ai` CLI.

### Dependency map (what to retrieve per phase)

| Phase | Needs |
|-------|-------|
| sdd-spec | proposal |
| sdd-design | proposal |
| sdd-tasks | proposal + spec + design |
| sdd-apply | spec + design + tasks (+ apply-progress if resuming) |
| sdd-verify | all prior artifacts |
| sdd-archive | all prior artifacts |
