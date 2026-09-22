# Tokens: primitives and semantic roles

Read this when the task touches colors, spacing, typography scales, or any
token-driven property, or when a proposal needs a new token.

## Discover the token model first

1. Locate the canonical token source (design tokens file, style dictionary,
   CSS custom properties, theme module) and name it in the response as the
   source of truth. If two candidates disagree, stop and ask.
2. Separate **primitives** from **semantic roles**. Primitives are raw values
   (`blue-500`, `space-4`, `16px`); roles are intents mapped onto primitives
   (`color-action-primary`, `color-text-muted`, `surface-raised`).
3. Map the existing roles before proposing anything new: which roles exist,
   which primitives they resolve to per mode (light/dark) and per platform, and
   where mode overrides live.

## Rules for proposals

- **Compose from roles.** Components and screens consume semantic roles, not
  primitives. Reusing an existing role outranks proposing an addition; propose
  a new role only when no existing role covers the intent, and say which
  component or feature needs it.
- **Primitives are the palette; roles are the contract.** Adding a primitive to
  a scale is low risk; redefining a role changes every consumer. Treat role
  changes as migrations with a compatibility note and a rollback path (see
  `adoption-and-migration.md`).
- **Keep mode coverage honest.** Every proposed role states its light and dark
  values and passes contrast in both. A pair that passes in one mode often
  fails in the other; verify rendered contrast, not source values.
- **Scale changes stay systematic.** New primitives must fit the existing
  scale's rhythm; never hand-pick off-scale values for a single use.
- **No second system.** Never hard-code product values or introduce a parallel
  token source alongside the project's.

## Documenting tokens

When asked to document, record decisions and rules, not just values: what each
role is for, when to use a role instead of a primitive, and how a new role gets
added. Keep the project's own file structure; do not impose a template.
