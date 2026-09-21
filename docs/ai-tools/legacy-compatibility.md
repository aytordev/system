# Legacy Artifact Compatibility and Migration (T25)

> **Historical / superseded:** this records the retired local dual-client workflow.
> Current ownership and onboarding: [native adoption guide](../../modules/common/ai-tools/README.md).
> Past verification and procedures below do not validate or operate the current native Shell.

## Scope

This record proves that the workflow can meet work already in progress without
discarding it. It inventories the legacy surfaces named in T25, classifies each
one, implements only the conversions that are genuinely required, and states the
rollback boundary. It closes the compatibility conditions of
[ADR 0017](../../docs/decisions/0017-migrate-ai-skills-as-pinned-compatible-bundles.md)
(`Existing state and rollback`) and the evidence obligations of
[ADR 0015](../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md)
F13/F14/F15. The task status lives in the [implementation plan](implementation-plan.md).

The historical deterministic proof was `checks/ai-tools-legacy-compat/` (removed),
which runs the real `aytordev-sdd` adapter over redacted copies of the surfaces
below and writes `legacy-compat-fixture.json` into its output.

Frozen inputs: engine `gentle-ai` v2.9.0
(`be49554794917ae92a6dc9dbfa2eb3db5cf70084`), Engram 1.7.0, local baseline
`3752d5c43840671467487e9805ef867c2816f5b8`. Every claim below is **proved**
(observed by the check) or **unverified**.

## Compatibility table

| # | Surface | Representative fixture (isolated/redacted) | Class | Action and target |
| - | - | - | - | - |
| 1 | Registry cache: legacy `.atl/skill-registry.md` with a summary/compact section | `checks/ai-tools-legacy-compat/fixtures/legacy-registry.md`; real bytes at `.atl/skill-registry.md` (sha256 `1b1c78d0…`, 144 lines, committed at `55f0d10`) | **requires conversion** | Detect + preserve via `aytordev-sdd migrate registry`; regenerate index-first through the `skill-registry` skill. Never use the summaries. |
| 2 | Phase envelope: `{status: ok\|warning\|failed, artifacts: [...]}` | `fixtures/legacy-envelope.json`, `fixtures/failed-envelope.json` | **requires conversion** | `aytordev-sdd migrate envelope` → non-advancing `sdd-result/v1`. |
| 3 | Spec scenario grammar: bold `**Scenario:**` vs canonical `#### Scenario:` | `fixtures/legacy-spec.md`, `fixtures/canonical-spec.md` | **directly readable** for verify; **requires conversion** before canonical promotion | Counted by `sdd-verify`; normalize files with `aytordev-sdd migrate scenarios` (`openspec`/`hybrid`). |
| 4 | Backend identity/locators: project-name drift, topic keys, `ENGRAM_PROJECT` | engine fixture in `checks/gentle-ai-engine/` (T28) | **requires a retained legacy reader / manual decision** | Never bridge silently. Unresolved locator → `blocked`; align with `ENGRAM_PROJECT` or a deliberate migration. |
| 5 | Verification reports: legacy markdown vs engine `gentle-ai.verify-result/v1` first-line fence | `fixtures/legacy-verify-report.md`, `fixtures/canonical-verify-report.md` | **requires a retained legacy reader / manual decision** | Detect with `aytordev-sdd migrate verify-report`; refuse as `unverified`; re-run `sdd-verify`. Never fabricate a PASS. |

### Why each classification

1. The migrated loading contract reads exact `SKILL.md` paths from an
   **index-first** registry (`## Index`). A summary cache cannot satisfy it, and
   transcribing summaries would create an authoritative digest. So the cache is
   preserved and **regenerated**, not translated.
2. The orchestrator rejects any result without `schema: sdd-result/v1`. A legacy
   `ok`/`warning`/`failed` envelope is not current evidence, so it is converted to
   a **non-advancing** envelope (see below), never to `success`.
3. `sdd-verify` counts both grammars, so a legacy spec stays verifiable in place.
   Canonical `#### Scenario:` is the target; the engine composer preserves either
   bytes (observed), so normalization is needed only to reach the canonical form,
   not to make composition work.
4. A recorded project name/topic key is an identity, not a format. An older name
   is aligned explicitly, not guessed.
5. An old report predates the engine contract; treating it as current evidence is
   exactly the false-success failure mode C11 forbids.

## Conversions implemented (adapter `migrate`)

All conversions are exposed through `aytordev-sdd` (no skill or client handles a
raw format) and live in
`modules/home/programs/terminal/tools/gentle-ai/migrate.sh` (removed).
Every one: prints a preview, **never mutates the input**, writes through a temp
file and publishes atomically (interruption/retry safe), reads its own result
back, and emits `aytordev-sdd.migrate/v1`.

| Command | Conversion | Readback | On unknown / failure |
| - | - | - | - |
| `migrate registry --input <f>` | Classify; preserve legacy bytes as `<f>.legacy` | backup contains the original bytes; original unchanged | `unknown` (exit 4) or `requires-regeneration` (exit 3); original untouched |
| `migrate envelope --input <f> [--output <f>]` | `ok`/`warning` → `partial`, `failed` → `failed`, `blocked` → `blocked`; `artifacts` normalized to locators; `evidence: []`; original status kept in `legacy_status`; a migration risk note added | re-parses output and asserts schema/kind/non-success/empty evidence | invalid JSON or unknown shape → exit 4; readback/publish failure → exit 5; original untouched |
| `migrate scenarios --input <f> --backend <b>` | Bold `**Scenario:**` → `#### Scenario:`, drops the lone `#### Scenarios` group heading | canonical count equals prior total; no bold marker remains | no scenario headings → exit 4; `engram`/`none` → `requires-manual-decision` (exit 3); missing output dir → exit 5; original untouched |
| `migrate verify-report --input <f>` | **no conversion**: admissibility check only | reports `admissible` or `requires-reverification` | legacy/foreign fence → exit 3; original untouched |

`--dry-run` previews and writes nothing. The envelope mapping means a **migrated
old PASS is never evidence for new code**: `ok` becomes `partial` with empty
evidence, so it cannot advance, and the C11 closure gate refuses a legacy report
end-to-end (proved, see below).

### Backend awareness

The file conversions are backend-aware like the rest of the adapter:

- `openspec` (default) / `hybrid`: file conversion allowed.
- `engram`: the artifact is an observation, not a file → `requires-manual-decision`
  (read/re-author through the phase skill).
- `none`: nothing persisted → `requires-manual-decision`.

The project-name/locator surface stays a manual decision: `ENGRAM_PROJECT` is the
documented override (see [engram-integration-results.md](engram-integration-results.md)),
and an unresolved locator is `blocked` — no silent re-keying or cross-store copy.

## Code rollback vs data rollback

These are **different operations** and restoring one does not restore the other.

- **Code rollback** — restore a previous Home Manager generation (or Git
  revision) so the older workflow code runs again. This restores the *engine,
  adapter, skills, and commands*. It does **not** reverse any artifact that was
  written in the newer format. Since all migrations preserve originals, an older
  generation that reads the original bytes continues to work for the surfaces it
  understood (legacy registry, bold spec, legacy envelope/report).
- **Data rollback** — return an artifact/database to a prior state. Migrations
  write **new** files and leave the original byte-identical, so data rollback is
  simply *not adopting* the converted output (delete the derived file, or keep
  using the original). No migration deletes an observation, overwrites a spec, or
  re-initializes a change, so there is nothing destructive to reverse.
  - A converted envelope is additive (`<input>.migrated`); the legacy envelope is
    untouched.
  - `migrate scenarios` publishes a new file; the original spec is untouched and
    the canonical spec is promoted only by the T21 composer after a verified
    closure.
  - `migrate registry` copies the original to `<input>.legacy`; the original is
    untouched.

### What an older generation sees after a migration

| Migrated artifact | Older generation reads | Result |
| - | - | - |
| Converted envelope (`<input>.migrated`) | The original file is still present | Unchanged behavior; the derived file is ignored unless explicitly named |
| Normalized spec (new file) | Original bold spec still present; composer accepts both grammars | Unchanged behavior |
| Preserved registry (`.legacy` copy) | Original path unchanged until regenerated | Unchanged behavior until the new index is written |

The only irreversible-looking step is the index-first registry **regeneration**,
which changes the path the loader prefers. That is why the legacy bytes are
copied first: reverting the code generation (back to a compact-rule consumer, if
one existed) still finds the preserved cache.

### Resuming an active change in either client

Both OpenCode and Pi resolve the backend and readiness through the same
`aytordev-sdd` adapter, so resumption is identical:

1. `aytordev-sdd status <change>` reports the engine's readiness and declared
   backend (T9/T28). `engram`/`openspec`/`hybrid` are read; `none` is
   session-local and never sent to the engine.
2. Per the historical `_shared/persistence-contract.md` (removed), an
   existing change keeps its recorded backend; there is no silent cross-store
   fallback. If the recorded locator does not resolve, the change is `blocked`.
3. Legacy specs are read in place (both grammars). Legacy envelopes are converted
   before consumption. A legacy verification report keeps closure `blocked` until
   `sdd-verify` produces a current, fenced report for the candidate revision.
4. The closure gate (`aytordev-sdd closure <change> --revision <rev>`) is the
   single successful-close authority in both clients; it never accepts an old
   PASS.

## Negative proofs (in `checks/ai-tools-legacy-compat`)

- A legacy registry is **detected**, its bytes are preserved at `<input>.legacy`,
  the original is byte-identical, and the run stops (exit 3) with a reason.
- An **unknown** envelope format stops (exit 4), produces no output, and leaves
  the original byte-identical.
- A converted legacy `ok` envelope is `status: partial` with empty evidence — a
  **migrated old PASS is not evidence** and cannot advance.
- A **partially failed** conversion (output directory missing) fails without
  mutating the recoverable original.
- The **C11 gate** exercised on an openspec change with complete tasks and a
  legacy `Verdict: PASS` report returns `disposition: unverified`, `ready: false`.
- A canonical, fenced report is reported `admissible`; the dry run writes nothing.

## Verification

```sh
nix build .#checks.aarch64-darwin.integration-ai-tools-legacy-compat \
  --override-input secrets path:./checks/fixtures/secrets
```

Observed output (`legacy-compat-fixture.json`):

```json
{
  "schema": "ai-tools-legacy-compat/v1",
  "registry": {"legacyDetected": true, "originalPreserved": true, "alreadyCurrent": true},
  "envelope": {"converted": true, "nonAdvancing": true, "alreadyCurrent": true, "unknownStopped": true},
  "scenarios": {"converted": true, "readback": true, "alreadyCurrent": true, "backendAware": true},
  "verifyReport": {"legacyInadmissible": true, "canonicalAdmissible": true},
  "negative": {"unknownLeavesOriginal": true, "partialFailureRecoverable": true, "dryRunNoWrite": true, "oldPassNotEvidence": true}
}
```

## Deferred / unverified

- The `sdd-propose` return-summary example still shows the legacy envelope shape
  (T20 deferred it; bundle assembly is T26). T25 ships the reader/converter so
  such an envelope is never silently accepted; T26 should align the producer.
- Live-model resumption of a real legacy change was not exercised; the proof is
  deterministic through the adapter and engine on isolated fixtures.
- The real `.atl/skill-registry.md` is intentionally left untouched (preserved
  bytes); regeneration is the `skill-registry` skill's job, not a T25 side
  effect.
- Engram topic-key drift beyond the project-name case has no observed fixture;
  the rule is "never bridge silently; align explicitly".
