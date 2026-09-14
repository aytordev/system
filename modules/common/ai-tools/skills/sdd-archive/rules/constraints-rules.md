## Archive Rules and Prohibitions

**Impact: HIGH**

Constraints that apply during the SDD archive phase. Policy source:
`_shared/closure-policy.md` (C11).

### MUST

- ALWAYS run the closure gate (`aytordev-sdd closure <change> --revision <rev>`)
  before any canonical write or archive move, and proceed only on
  `disposition: verified`
- ALWAYS compose deltas deterministically through `aytordev-sdd compose`; never
  hand-merge or model-regenerate canonical specs
- ALWAYS preserve requirements not mentioned in the delta
- ALWAYS validate requirement headings/names and rename semantics; refuse
  unknown or ambiguous operations before writing
- ALWAYS use ISO date format (YYYY-MM-DD) for archive directory names
- ALWAYS snapshot before the move and read back with `diff -r`
- ALWAYS return a structured `sdd-result/v1` envelope with `schema`, `kind`,
  `status`, `executive_summary`, `artifacts`, `evidence`, `next_recommended`,
  `risks`, `skill_resolution`

### MUST NOT

- NEVER archive a change whose closure gate did not return `verified`
- NEVER promote canonical specs for `unverified`, `paused`, or `abandoned`
- NEVER emit `status: success` for a non-success disposition (no fabricated PASS)
- NEVER overwrite an existing archive directory (a same-day collision refuses)
- NEVER delete or modify archived changes (the archive is an audit trail)
- NEVER strip delta markers silently when a canonical spec is missing
- NEVER lose existing requirements during compose (only what the delta names)

### SHOULD

- Warn and ask for confirmation if a compose operation would be destructive
- Apply `rules.archive` settings from `config.yaml` when available
- Preserve the prior verify report and change artifacts when validation fails
- Name the recovery path when an archive move is interrupted
