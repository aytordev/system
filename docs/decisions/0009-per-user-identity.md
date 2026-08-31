# ADR 0009: Per-User Identity for Multi-Host Configuration

Status: Accepted

## Decision

The private `secrets` flake remains the single source of truth for identity,
but now exports a `users.<username>` map in addition to the flat owner fields.
Each entry carries the same three non-empty fields (`username`, `useremail`,
`userfullname`) and describes one canonical user.

`libraries/identity` gains `fromSecretsFor username secrets`, which resolves the
normalized identity for a named user from that map. It falls back to the flat
owner identity when the requested user IS the owner, so owner-only setups do not
need to duplicate `aytordev` in the map.

Hosts and homes no longer assume a single owner. Each host resolves its user
from its matching home directory (`avicente@civislend` maps host `civislend` to
user `avicente`); hosts without a home fall back to the owner. `assertUsername`
still guards the home-manager boundary so a home never claims a username the
secrets flake does not vouch for.

`identity.fromSecrets` (owner) is unchanged and is still what checks and the CI
fixture receive.

## Consequences

- A machine can run under a different identity than the owner, e.g. the work
  host `civislend` runs as `avicente`.
- The private `secrets` flake must add a `users.<name>` entry for every
  non-owner host; missing entries produce a clear error pointing at the fix.
- Host + home names carry the username (`<user>@<host>`), so a host is tied to
  exactly one user for now; multi-user hosts throw at evaluation.
- The CI fixture gains `users.avicente` so production-shaped checks still run
  without the private repository.