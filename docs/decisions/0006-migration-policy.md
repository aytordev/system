# ADR 0006: Make State Migrations Explicit

Status: Accepted

## Decision

`system.stateVersion` and `home.stateVersion` belong to concrete systems, homes,
and synthetic test configurations. They are set at creation time and are not
automatically advanced during dependency updates.

When an upstream default changes, preserve current behavior explicitly unless a
migration is planned. A migration must document the old state, new state,
required file operations, rollback, and verification.

Destructive migrations must not run unconditionally during activation. They
require an explicit opt-in or a separately invoked command.

## Consequences

- Dependency updates do not silently move persistent data.
- Migration behavior is reviewable and reversible.
- Compatibility settings, such as Firefox's profile path, remain intentional.
