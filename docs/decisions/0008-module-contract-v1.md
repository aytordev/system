# ADR 0008: Adopt Module Contract V1

Status: Accepted

## Decision

Every reusable module has one primary class and follows that class's contract.

| Class | Owns | Required behavior |
| --- | --- | --- |
| Foundational | Identity and shared metadata | Publishes only foundational values; policy belongs in suites. |
| Capability | One program or service | Uses `aytordev.*.enable`, guards outputs with `mkIf`, and exposes `package` when it owns a primary package. |
| Platform adapter | OS-specific integration | Bridges a capability to one platform and guards platform-only outputs. |
| Suite | Workflow policy | Composes capabilities with `mkDefault`; every suite flag must change an output. |
| Archetype | Host role | Composes suites with `mkDefault` so concrete hosts can override every choice. |
| Pure data | Shared computed values | Has no activation or service side effects and needs no synthetic `enable` option. |

Contained sibling files may separate data, shell integration, or adapters from a
large `default.nix`. The parent remains the single discovered module and owns the
public option namespace.

## Runtime Rules

- Preserve command argument boundaries. Do not reconstruct commands with
  `bash -lc` or interpolate unescaped values into generated shell or Lua.
- Load credentials from runtime files. Secret values must not enter the Nix
  store, session variables, launchd plists, or systemd unit definitions.
- Home Manager owns user services and user-home activation. Darwin and NixOS
  modules own only operations that require system privileges.
- Signing is opt-in and requires an explicit key. A missing key is an evaluation
  error, not an implicit path or nullable signed state.
- Platform-only outputs use explicit `isDarwin` or `isLinux` guards.

## Composition Rules

- Suites and archetypes provide defaults; they do not use `mkForce`.
- Concrete homes and systems select policy and may override any composed value.
- Foundational modules do not install convenience packages, define workflow
  aliases, or select suites.
- Pure data remains available to consumers without pretending to be disabled.

## Verification

- `checks/module-contract` verifies package options for the current package-owning
  Home capabilities.
- `checks/architecture-layers` rejects forced composition and Darwin-owned user
  LaunchAgents in addition to the layer boundaries from ADR 0001.
- Synthetic Home, Darwin, and NixOS checks exercise platform composition.
- Runtime-specific regressions remain covered by focused unit and integration
  checks.

## Consequences

- Capability implementations are replaceable without editing module internals.
- Suites remain policy bundles rather than hidden hard requirements.
- User services and credentials have one owner and a reviewable runtime path.
- New package-owning capabilities must be added to the module contract check.
