# Documentation

Project documentation is split by purpose:

- `README.md` — human-facing overview of the whole repository.
- `docs/decisions/` — Architecture Decision Records (ADRs).
- `docs/ai-tools/` — historical plan, proposal, and evidence for the retired
  local AI workflow. Current ownership and onboarding live in
  `modules/common/ai-tools/README.md`; do not present past verification as
  validation of the native Shell installation.
- `AGENTS.md` files — agent-facing protocols, placed near the code they govern.
- `README.md` files inside components — human/state documentation for a
  subtree (e.g. `checks/`). Keep these only where a component is large enough
  to warrant narrative.

## Architecture Decision Records

ADRs record decisions, not trivia. Something belongs in `docs/decisions/`
when a future reader (human or agent) needs to know *why* a structure or
convention exists.

### A new ADR requires

- A thin definition file in `docs/decisions/`.
- A meaningful decision that a reader could accidentally reverse.

### ADR Format

```markdown
# ADR 0009: Short Imperative Title

Status: Accepted   # or Proposed / Amended

## Decision

The what and the why, in one or two short paragraphs.

## Consequences

- Bullet the practical effects that future work must respect.
```

Number sequentially, starting from the existing highest index. Prefer
`0009-…` over `009-…`.

## Guidance

- One decision per ADR. Do not edit an ADR wholesale; supersede it with a new
  one and reference the old.
- Reference an ADR from the relevant `AGENTS.md`/`README.md` so the protocol is
  discoverable next to the code it governs.
- Keep each ADR short and readable; a paragraph is preferred over a paragraph
  plus reproduction of the code.

## Where Things Don't Go

- Routine usage (commands, module patterns) belongs in `AGENTS.md`, not ADRs.
- Component-specific how-to belongs in the component's own `AGENTS.md`.
- Proposed changes belong in a normal proposal/PR workflow, not in `docs/`.
