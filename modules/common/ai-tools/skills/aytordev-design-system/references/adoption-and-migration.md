# Decisions, adoption, and migration

Read this when the task produces a design-system decision record, an adoption
plan, documentation, or a migration.

## Decisions

Record each system decision with its rationale and trade-offs: what changed,
why, which alternatives were rejected, and which consumers are affected. A
decision that cannot name its affected consumers is not ready. Keep decisions
in the project's existing convention (ADR files, changelog, doc headers); do
not introduce a second record system.

## Adoption

An adoption plan states, in order: who consumes the change, what they must do
differently, which old usages keep working and for how long (deprecation
window), and how success is observed. Favor additive adoption — new roles,
components, or docs alongside the old — over in-place replacement.

## Migration and compatibility

1. **Inventory consumers first.** Enumerate what uses the token, component, or
   role being changed; unowned consumers are a stop-and-ask, not an assumption.
2. **Keep a compatibility path.** Provide aliases, re-exports, or a dual-run
   period so old usages keep working during the window; breaking changes state
   their break explicitly.
3. **Plan the rollback.** Name the state to return to, what becomes unrecoverable
   or divergent after the migration, and the trigger that calls for rollback.
4. **Sequence to stay shippable.** Order steps so the system is consistent at
   each boundary; a migration that leaves two live sources of truth needs a
   documented cut-over, not a hope.

## Never overwrite a code-bearing design-system directory

When asked to create or regenerate a design system where the target path
already holds tokens, components, build outputs, or docs:

- Inventory the existing contents and report what is there.
- Propose additive or versioned changes (new files, a migration branch, a
  version bump) instead of replacement.
- Say explicitly what any proposed change would remove or make stale.
- Stop and ask when the request can only proceed by overwriting.

## Optional project documentation

Documentation is a deliverable when the project asks for it, shaped by the
project's structure and naming — not a fixed template. Keep it decision-shaped
and short: rules the next contributor can follow ("compose from semantic
roles", "check both modes before shipping a color pair"), pointers to the
source of truth, and per-concern entry points. A wrong value documents worse
than a missing one; leave a gap explicit rather than guessing.
