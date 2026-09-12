# ADR 0011: Native Theme Resources and Per-App Overrides

Status: Accepted

## Decision

A theme family only supplies a native theme name for apps it ships a resource
for. Providers declare one entry per supported app in `integrations`; the theme
module derives `aytordev.theme.nativeApps` (and `providers.<family>.nativeApps`)
as `builtins.attrNames integrations`. `nativeApps` is therefore read-only and
must never be hand-authored. Native-theme apps (Ghostty, Zed, VS Code, tmux)
resolve their theme through `lib.aytordev.resolveApp` against the active
family's integration, which carries the exact per-variant resource id.

This prevents an unsupported combination from silently emitting a theme name
the app cannot resolve, without failing the whole build. It narrows the "fail
loudly" wording of [ADR-0010](0010-multi-family-theme-providers.md) to "do not
emit".

A family may also be dark-only if it provides a synthetic light companion. Sora
registers its official `dark` variant plus a locally derived, unofficial `light`
variant so light/dark-following apps still have a counterpart.

## Consequences

- Adding a family is provider data plus, optionally, `integrations` and shipped
  resources. `nativeApps` follows automatically from the integration keys; a
  hand-written list that disagrees with them is a validation error.
- Generated-resource apps (Yazi, Pi, Zellij, Starship, Sketchybar,
  JankyBorders) support every family and ignore `integrations`.
- Unsupported native combinations require an explicit per-app `theme` override;
  by default nothing is written and the app keeps its own theme.
- Synthetic variants (for example Sora light) are explicitly unofficial and may
  not match upstream.
- Each integration pins its origin (`source.ref.rev`); vendored artifacts
  additionally pin every variant with an SRI `hash`.
