# ADR 0010: Multi-Family Theme Providers

Status: Accepted — native-theme name accessors (`appTheme*`) superseded by
[ADR-0013](0013-theme-integrations-are-the-only-native-registry.md).

> **Note (2026-09-13):** The Catppuccin family referenced below was later
> removed from the provider registry; see
> [ADR-0014](0014-remove-the-catppuccin-theme-family.md). This ADR is kept as a
> historical record of the multi-family provider design.

## Decision

`aytordev.theme` supports more than one theme family. Each family is a
pure-data provider (not a module) validated against a fixed contract: `name`,
`displayName`, `defaultVariant`, `darkVariant`, `lightVariant`, `variants`, and
`appTheme`. Each family keeps one file per variant under `variants/<name>.nix`
exporting `{ isLight, rawColors, palette }`; `provider.nix` is the explicit
registry that imports them and defines naming/polarity. When variants share a
role mapping verbatim (Catppuccin), a `palette.nix` helper is reused rather than
copying the mapping into every variant file.

`validateProvider` rejects a provider that is missing fields, references an
unknown variant, or declares inconsistent light/dark polarity. The active family
is selected with `aytordev.theme.name`; the read-only `providers` option exposes
every family's variant palettes.

Consumers fall into two classes:

- Palette-derived apps generate their configuration from `palette` and support
  every family automatically (for example Zellij, Starship, Yazi, Pi).
- Native-theme apps resolve a name through `appTheme` / `appThemeDark` /
  `appThemeLight` and must ship the matching resource for each supported family
  (for example VS Code, Zed, tmux, Ghostty).

Runtime switching is scoped to Sketchybar, the only consumer that hot-reloads
through `providers`. Other applications re-read their theme on restart.

## Consequences

- Adding a family is provider data plus per-app resources, not a new module.
- `theme.name` selects the family and `theme.variant` the variant; there is no
  `theme.enable` switch and the module remains pure data.
- Native-theme integrations are responsible for keeping names and shipped
  resources in sync; an unsupported family fails loudly instead of silently
  producing a missing theme.
- A global runtime switch is not promised: only Sketchybar reloads live.
- New palette-derived adapters should be used for any app that should follow
  every family instead of enumerating variants.
