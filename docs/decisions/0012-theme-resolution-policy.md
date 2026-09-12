# ADR 0012: Theme Resolution Policy

Status: Accepted

## Decision

Every themed application resolves the active theme through one hybrid policy,
evaluated per `(app, family, variant)`:

```
explicit override > official exact (app + family + variant) > generated fallback > none
```

The provider's `integrations` registry is the source of official resources;
`aytordev.theme` exposes the registry and `lib.aytordev.resolveApp` implements the
policy. If no case wins, the app keeps its own default.

This supersedes the "do not emit" wording of
[ADR-0011](0011-native-theme-resources.md), which had an incomplete integration
fall through to nothing. A family/variant that the app can generate from the
shared palette now emits that generated resource; only a combination with
neither an official nor a generated path emits nothing. The provider contract and
provenance model of ADR-0011, and the multi-family structure of
[ADR-0010](0010-multi-family-theme-providers.md), are unchanged.

## Consequences

- `official`, `generated`, and `none` are the three observable outcomes; the
  derived catalog in `docs/theme-support-matrix.md` records them per
  family/variant and app, with provenance for official resources.
- A declared integration that omits the active variant is treated as absent so
  the generated fallback wins. A malformed integration still throws, keeping
  broken declarations loud.
- Adding a generated fallback is what turns an unsupported variant from `none`
  into a working theme for that app.
- A per-app override (`string`, `{ mode = "manual"; id; }`, or
  `{ mode = "none"; }`) is the documented escape hatch and always wins.
