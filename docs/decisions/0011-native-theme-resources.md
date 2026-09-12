# ADR 0011: Native Theme Resources and Per-App Overrides

Status: Accepted

## Decision

A theme family only supplies a native theme name for apps it ships a resource
for. Providers declare those apps in an optional `nativeApps` list; the theme
module exposes it as `aytordev.theme.nativeApps`. Native-theme apps (Ghostty,
Zed, VS Code, tmux) select a name from `appTheme` / `appThemeDark` /
`appThemeLight` **only** when the active family lists them in `nativeApps`.
Otherwise they leave the application's own default and expose a nullable `theme`
option for an explicit override.

This prevents an unsupported combination from silently emitting a theme name
the app cannot resolve, without failing the whole build. It narrows the "fail
loudly" wording of [ADR-0010](0010-multi-family-theme-providers.md) to "do not
emit".

A family may also be dark-only if it provides a synthetic light companion. Sora
registers its official `dark` variant plus a locally derived, unofficial `light`
variant so light/dark-following apps still have a counterpart.

## Consequences

- Adding a family is provider data plus, optionally, `nativeApps` and shipped
  resources.
- Generated-resource apps (Yazi, Pi, Zellij, Starship, Sketchybar,
  JankyBorders) support every family and ignore `nativeApps`.
- Unsupported native combinations require an explicit per-app `theme` override;
  by default nothing is written and the app keeps its own theme.
- Synthetic variants (for example Sora light) are explicitly unofficial and may
  not match upstream.
- Apps must keep `nativeApps` in sync with the resources they actually ship.
