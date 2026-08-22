# ADR 0001: Enforce Configuration Layers

Status: Accepted

## Decision

Configuration flows in one direction:

1. Reusable modules define capabilities under `aytordev.*`.
2. Suites compose capabilities into policy.
3. Homes and systems select suites and provide concrete values.
4. Builders assemble modules and configurations without choosing policy.

## Boundaries

- `modules/` must not import concrete files from `homes/` or `systems/`.
- `homes/` and `systems/` rely on module auto-discovery and must not import
  module implementations directly.
- `libraries/system/` may assemble modules, but must not configure
  `aytordev` capabilities, suites, archetypes, or services.
- Platform suites may compose their matching shared suite from
  `modules/common/suites/`.

`checks/architecture-layers` parses each Nix expression before scanning resolved
paths and assignments. Review remains responsible for semantic violations that
do not use an import or an `aytordev.*` assignment.

## Consequences

- Capabilities remain reusable outside the current hosts.
- Host-specific choices stay visible at the integration edge.
- Builders can support synthetic configurations without acquiring test or
  workstation policy.
