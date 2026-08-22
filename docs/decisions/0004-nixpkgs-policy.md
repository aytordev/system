# ADR 0004: Use One Nixpkgs Lineage

Status: Accepted

## Decision

The root flake exposes one `nixpkgs` input. Direct consumers follow that input,
including nix-darwin, Home Manager, sops-nix, overlays, and package flakes.

Additional stable or unstable roots are allowed only when a concrete package
requires a different revision. Such an exception must include a comment, a
consumer, and a removal condition.

`checks/input-policy` validates the root lock and the direct followers.

## Consequences

- Package and module libraries agree on platform and option definitions.
- Lock updates cannot silently introduce an unused nixpkgs lineage.
- Exceptions are visible architectural decisions rather than convenience
  inputs.
