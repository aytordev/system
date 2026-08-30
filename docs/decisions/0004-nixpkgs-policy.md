# ADR 0004: Use One Nixpkgs Lineage

Status: Accepted

## Decision

The root flake exposes one `nixpkgs` input. Direct consumers follow that input,
including nix-darwin, Home Manager, sops-nix, overlays, and package flakes.

Additional stable or unstable roots are allowed only when a concrete package
requires a different revision. Such an exception must include a comment, a
consumer, and a removal condition.

The private `secrets` flake is an explicit exception: it is independently
locked, and this repository consumes its outputs rather than its package set.

`checks/input-policy` discovers direct nixpkgs consumers from the root lock and
validates both canonical followers and declared exceptions.

## Consequences

- Package and module libraries agree on platform and option definitions.
- Lock updates cannot silently introduce an unused nixpkgs lineage.
- Exceptions are visible architectural decisions rather than convenience
  inputs.
