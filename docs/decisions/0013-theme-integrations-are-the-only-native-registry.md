# ADR 0013: Integrations Are the Only Native-Resource Registry

Status: Accepted

## Decision

The theme module exposes no derived native-resource accessors. `appTheme`,
`appThemeDark`, `appThemeLight` and the `nativeApps` projection (including
`providers.<family>.nativeApps` and the automatic `builtins.attrNames`
derivation) were removed because nothing consumed them: `lib.aytordev.resolveApp`
already reads the provider's `integrations` registry directly, and palette-derived
apps read `palette`/`ansi`. Keeping the accessors meant two representations of
the same data that had to stay in sync for no benefit.

The public theme surface is now `name`, `variant`, `displayName`, `isLight`,
`palette`, `ansi`, `providers` and `integrations`. Named native themes resolve
only through `resolveApp` (`explicit override > official exact (app + family +
variant) > generated fallback > none`, per
[ADR-0012](0012-theme-resolution-policy.md)).

This narrows the native-theme naming rules of
[ADR-0010](0010-multi-family-theme-providers.md) and the read-only projection of
[ADR-0011](0011-native-theme-resources.md).

## Consequences

- `integrations` is the single, hand-authored source of native-resource truth;
  there is no second derived list to validate or keep in sync.
- `validateProvider` no longer checks `appTheme` or projects `nativeApps`; the
  contract is `name`, `displayName`, `defaultVariant`, `darkVariant`,
  `lightVariant`, `variants` and optional `integrations`.
- Provider variant files still carry `rawColors` as their import-time source, but
  `raw` colors are not part of the `providers` introspection surface.
