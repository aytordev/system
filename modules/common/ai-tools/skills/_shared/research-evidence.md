# Optional Research Evidence Handoff (shared across SDD phases)

**Impact: HIGH**

This is the single source of truth for the optional, source-backed evidence
handoff used when **external facts materially affect** `sdd-explore`,
`sdd-propose`, or `sdd-design`. It records what was researched, which sources
back each claim, and what stays uncertain, so the justification survives the
conversation instead of living only in a chat turn.

It is **optional**: use it for material unknowns, not as a research ceremony
after every exploration. Skip it when this repository already answers the
question or the choice is a trivially reversible preference.

## When It Applies

"External" means outside this repository and its code: third-party API behavior
or versions, library/upstream contracts, standards and specs, platform or tool
behavior, release notes, limits/pricing, and security advisories. Use the
handoff when such a fact is **material** to a phase decision — the answer changes
the approach, scope, compatibility, or risk.

## Ownership Boundary

- Evidence collection is a **method**, not a lifecycle owner. It never
  implements, refactors, commits, approves, schedules, or archives.
- The **orchestrator** keeps decision ownership: it resolves the backend, owns
  phase transitions, and decides whether a claim is material.
- The **user** owns product choices. A source is evidence, never approval. This
  handoff MUST NOT infer consent, and it MUST NOT turn a cited fact into a
  confirmed product choice.
- Confirmed product choices are recorded **only** when the user (or the
  orchestrator acting on the user's stated decision) says so, in a section kept
  separate from researched claims.

## Optional and Backend-Aware

When used, the handoff follows the resolved backend exactly like any other
artifact (`persistence-contract.md`, `sdd-phase-common.md`) and creates nothing
the backend forbids:

| Backend | Where the handoff lives | Writes |
| --- | --- | --- |
| `engram` | Engram observation, topic key `sdd/{change-name}/research-evidence` (`engram-convention.md`) | Engram only |
| `openspec` | `openspec/changes/{change-name}/research-evidence.md` | Filesystem only |
| `hybrid` | Both, filesystem first then Engram, reconciled per `persistence-contract.md` | Both |
| `none` | Inline in the phase's returned envelope only | Nothing |

- `none` MUST NOT create a file or an observation; the evidence is `inline` and
  is not promised to survive the session. Never create
  `openspec/changes/{change-name}/research-evidence.md` in `engram` or `none`.
- `engram` MUST NOT create the OpenSpec file, and `openspec` MUST NOT create an
  observation. No silent cross-store fallback.
- The handoff never blocks a phase by itself. Material unresolved gaps surface in
  the envelope's `risks`; the orchestrator decides whether to proceed, ask, or
  mark readiness `blocked`.

## Evidence Format

One block per phase. Stable field names:

```yaml
questions:                       # material external questions for this phase
  - id: Q1
    question: <what the repo could not answer>
    material_to: <the decision/requirement it affects>

sources:                         # every source any claim cites
  - id: S1
    class: <official-docs | source-code | spec | release-notes | issue-tracker | vendor-claim | other>
    title: <human-readable title>
    url: <https URL>
    # exactly one provenance anchor is required:
    accessed: <YYYY-MM-DD>       # living docs / websites
    revision: <pinned tag | commit | released version>   # source code / artifacts

claims:                          # statements, each mapped to source IDs
  - id: C1
    claim: <the external fact>
    sources: [S1, S2]
    status: <supported | contested | unsupported>
    changing: <true | false>     # true when the external surface is known to move
    affects: <the decision/requirement it affects>

contradictions:                  # sources that disagree, and the reading
  - between: [S1, S2]
    topic: <what they disagree about>
    resolution: <which wins and why, or "unresolved">

unresolved gaps:                 # material questions still unanswered
  - <gap>, and the smallest next step that would close it

freshness:
  collected_at: <YYYY-MM-DD>
  revalidate:                    # when to re-check, and why
    - sources: [S1]              # or claim: C1
      when: <trigger, e.g. "vendor ships API v3">

confirmed product choices:       # SEPARATE; user/orchestrator decisions only
  - choice: <the decision>
    decided_by: <user | orchestrator>
    evidence: [C1]               # optional supporting claims; never the consent
```

### Format Rules

1. Every `sources` entry carries `class`, `title`, `url`, and **either**
   `accessed` **or** `revision`. A source without a provenance anchor is invalid.
2. Every `claims` entry lists at least one existing source ID. A claim with no
   source MUST be `status: unsupported`; it may still be recorded, but only as an
   explicit gap.
3. A `changing: true` claim MUST retain a source anchor (`revision` or
   `accessed`) so it can be re-checked, and MUST be paired with an
   `unresolved gap` or a `freshness.revalidate` entry. A changing claim with no
   retained anchor or no gap is not a supported claim.
4. `contradictions` reference existing source IDs; an unresolved contradiction
   stays in `contradictions` and is echoed in `unresolved gaps`.
5. A `confirmed product choices` entry requires `decided_by` (`user` or
   `orchestrator`). Its `evidence` may list only `status: supported` claims. A
   `contested` or `unsupported` claim MUST NOT be cited as the basis of a
   confirmed product choice — that is how an unsupported claim masquerades as a
   product decision.
6. A source never implies consent and never appears *as* a product choice. Only a
   `decided_by` entry is a product choice.

## Integrate With the Methods (T14), Do Not Duplicate Research

Use the existing method skills rather than inventing a research lifecycle:

- **`impact-analysis`** — when the change crosses a component, option, wire, or
  data contract. Its evidence ladder (`file:line` → walked failure path → ran
  real code) supplies the support level for a claim; a fact it cannot take to
  step 4 is recorded here as `unsupported`/`unresolved`, not rounded up.
- **`bug-diagnosis`** — when the external behavior is an observed failure and a
  supported cause must be distinguished from alternatives.
- Both return to the caller. The SDD phase stays the owner, records this handoff,
  and never hands the lifecycle to the method.

## Return

When a phase used this handoff, its `sdd-result/v1` envelope
(`return-envelope.md`):

- lists the evidence artifact in `artifacts` with a real locator for
  `engram`/`openspec`/`hybrid`, or `inline` for `none`;
- carries material unresolved gaps and contradictions in `risks`;
- keeps `executive_summary` explicit about which claims are supported versus
  unsupported, and never reports a product choice the user did not make.
