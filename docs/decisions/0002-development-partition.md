# ADR 0002: Keep Development Inputs Partitioned

Status: Accepted

## Decision

Development tools live in `flake/dev` with an independent `flake.lock`.
`flake-parts` transposes checks, shells, formatters, and templates into the root
outputs.

Production builders and modules must not depend on development-only inputs.
Updating development tooling must not change the production lock unless a
shared root input intentionally changes.

## Consequences

- Developer tooling can update independently.
- The production lock remains smaller and more stable.
- Both lockfiles must be updated when their shared input contract changes.
