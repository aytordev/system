# ADR 0003: Use the Private Flake as the Profile Source

Status: Accepted

## Decision

The private `secrets` flake is the single source of truth for identity metadata
and encrypted SOPS documents. `username`, `useremail`, and `userfullname` remain
plain outputs in that private repository.

The root flake validates those outputs at the composition boundary. Reusable
modules receive normalized `identity` values, never the raw private input.
Concrete systems additionally receive `secretsRoot` when they need SOPS files.

CI uses `checks/fixtures/secrets` as a non-sensitive test double. The fixture
implements the contract but is not a second source of personal data.

## Consequences

- Personal metadata has one canonical source.
- Reusable modules remain independent of the private repository schema.
- CI still requires an input override while `secrets` remains a root input.
