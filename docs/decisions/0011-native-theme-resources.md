# ADR 0011: Native Theme Resources and Per-App Overrides

Status: Accepted

## Decision

A theme family only supplies a native theme name for apps it ships a resource
for. Providers declare one entry per supported app in `integrations`, which is
the single source of native-resource truth: the theme module derives
`aytordev.theme.nativeApps` (and `providers.<family>.nativeApps`) as
`builtins.attrNames integrations`. `nativeApps` is therefore read-only and must
never be hand-authored. Each entry carries:

- `source.provenance` — `official-upstream` (the theme project itself) or
  `community-port` (a genuine third-party port). Do not label a community port
  official.
- `source.ref.{url,rev}` — a concrete pinned revision, never a moving `HEAD`.
- `source.ref.hash` / `variants.<v>.hash` — an SRI `sha256`, required when the
  resource is `vendored` (shipped in this repo); optional for a non-vendored
  official resource referenced by URL/release.
- `variants.<provider-variant>.id` — the exact theme/flavor/variant name or
  artifact stem the app expects, and `complete` — `true` only when every
  provider variant is covered, `false` otherwise (with the uncovered variants
  omitted).

Native-theme apps resolve through `lib.aytordev.resolveApp` with the policy
**explicit override > official exact (app + family + variant) > generated
fallback > none**. A family may also be dark-only if it provides a synthetic
light companion. Sora registers its official `dark` variant plus a locally
derived, unofficial `light` variant, so its official resources are declared
`complete = false` and cover only `dark`.

This prevents an unsupported combination from silently emitting a theme name
the app cannot resolve, without failing the whole build. It narrows the "fail
loudly" wording of [ADR-0010](0010-multi-family-theme-providers.md) to "do not
emit".

## Consequences

- Adding a family is provider data plus, optionally, `integrations` and shipped
  resources. `nativeApps` follows automatically from the integration keys; a
  hand-written list that disagrees with them is a validation error.
- Registered integrations cover the upstream resources for the active family,
  including generated-config apps whose upstream ships a native resource (for
  example Starship, Yazi, bat, btop, fzf, eza, lazygit, OpenCode, Zellij,
  Warp and Firefox). Apps without any upstream resource (Pi, Sketchybar,
  JankyBorders) rely entirely on the generated palette.
- Unsupported native combinations require an explicit per-app `theme` override;
  by default nothing is written and the app keeps its own theme.
- Synthetic variants (for example Sora light) are explicitly unofficial and may
  not match upstream.
- Each integration pins its origin (`source.ref.rev`); vendored artifacts
  additionally pin every variant with an SRI `hash`.
