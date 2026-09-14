# Return Envelope (`sdd-result/v1`) — shared across all SDD skills

Every SDD phase MUST return a structured result envelope. The envelope is
**versioned**; the orchestrator validates it before acting and NEVER advances on
an empty, malformed, nonterminal, cancelled, or non-`success` result. Engine
calls stay behind the `aytordev-sdd` adapter — phases never validate engine
state themselves and never call the raw `gentle-ai` CLI.

## Schema Version

`schema: sdd-result/v1`

A result without `schema` (or with any other value) is malformed and is
rejected; absence of output is not success.

## Result Kinds

| `kind` | Terminal? | May advance? | Meaning |
|--------|-----------|--------------|---------|
| `launch-ack` | no | no | Background worker started; no phase result yet. |
| `progress` | no | no | In-flight progress within a phase. |
| `cancelled` | yes | no | Worker/phase cancelled before a final result. |
| `final` | yes | only if `status: success` | Completed phase result. |

Only a **terminal `final` envelope with `status: success`** may advance the
workflow. `launch-ack` and `progress` are **nonterminal** acknowledgements: the
orchestrator records them and keeps waiting. `cancelled`, and `final` with
`partial`, `blocked`, or `failed`, stop the flow. Rejecting a terminal result or
receiving a nonterminal acknowledgement never advances a phase.

## Required Fields

Always required: `schema`, `kind`.

| `kind` | Required fields |
|--------|-----------------|
| `launch-ack` | `schema`, `kind`, `run_id`; optional `summary` |
| `progress` | `schema`, `kind`, `summary`; optional `completed`, `total` |
| `cancelled` | `schema`, `kind`, `summary`; optional `reason` |
| `final` | `schema`, `kind`, `status`, `executive_summary`, `artifacts`, `evidence`, `next_recommended`, `risks`, `skill_resolution` |

`final.status` is one of:

| `status` | Meaning | Advances? |
|----------|---------|-----------|
| `success` | Phase completed; required checks are current and relevant | yes |
| `partial` | Completed with warnings or non-critical gaps | no — resolve first |
| `blocked` | Cannot proceed (missing input, unresolved backend, blocked Strict TDD, missing dependency) | no |
| `failed` | Attempted and failed (tests failed, invalid spec, rejected evidence) | no |

This is the one set of terminal statuses for every phase. Phase reports may keep
their own human-readable verdicts (`PASS`/`FAIL`, `ok`/`warning`), but the
envelope always uses `success | partial | blocked | failed`.

## Evidence Entries

A `final` envelope MUST carry at least one evidence entry, and each entry MUST
record:

| Field | Meaning |
|-------|---------|
| `check` | The exact focused check / command that was run |
| `exit` | Its exit code (`0` = pass) |
| `result` | `pass \| fail` |
| `revision` | The candidate revision the check ran against (commit hash, or artifact revision/hash for a non-git change) |
| `relevant` | The requirement/scenario or work unit the evidence addresses |

**Freshness.** Evidence is valid only while `revision` equals the current
candidate revision. Any source change since evidence was collected makes it
**stale**; a stale `pass` is not a success, cannot satisfy `status: success`, and
cannot advance. A hash alone does not prove relevance — `relevant` must name the
requirement/scenario or unit the check exercised.

## Terminal Validation

The orchestrator (and, for engine-backed transitions, the `aytordev-sdd`
adapter on behalf of the pinned engine) validates every result:

- Empty output, non-object output, a missing/unknown `schema`, an unknown `kind`,
  or a `final` envelope missing a required field → **rejected**.
- `final.status != success`, `cancelled`, `launch-ack`, or `progress` → does not
  advance.
- `final.status: success` with empty evidence, non-zero `exit`, or stale
  `revision` → rejected as a false success.

When a phase's engine transition is rejected, keep the recorded backend, mark
readiness `blocked`, and report it — never re-derive engine state locally.

## Example

```markdown
schema: sdd-result/v1
kind: final
status: success
executive_summary: Proposal created for `add-dark-mode`.
artifacts:
  - engram `sdd/add-dark-mode/proposal`
evidence:
  - check: `nix flake check --no-build`; exit: 0; result: pass; revision: 3752d5c; relevant: REQ-01/S1
next_recommended: sdd-spec or sdd-design
risks: None
skill_resolution: paths-injected — 3 skills (nix, dotfiles-coder, skill-creator)
```

## `skill_resolution` Values

| Value | Meaning |
|-------|---------|
| `paths-injected` | Received a `## Skills to load before work` block and read the exact `SKILL.md` paths it listed |
| `fallback-registry` | No paths received; self-loaded exact paths from the registry index (Engram or `.atl/skill-registry.md`) |
| `fallback-path` | Loaded via explicit `SKILL: Load` path instructions |
| `none` | No skills loaded — only phase skill used |

## Orchestrator Self-Correction

If a sub-agent reports anything other than `paths-injected`, the orchestrator MUST:
1. Re-read the skill registry index immediately (may have been lost to context compaction)
2. Ensure ALL subsequent delegations include `## Skills to load before work` with exact `SKILL.md` paths
3. Log a warning: "Skill path cache miss detected — reloaded index for future delegations."
