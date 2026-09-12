# Theme System

The theme system is one pure-data module (`modules/home/theme`) that publishes a
semantic palette and a set of per-app theme resolutions. Applications never
hardcode colors or branch on a variant; they read the palette or resolve a named
resource through the shared hybrid policy.

**Resolution policy (highest to lowest):**

```
explicit override  >  official exact (app + family + variant)  >  generated fallback  >  none
```

If nothing wins, the app keeps its own default. The derived per-family/app
matrix lives in [theme-support-matrix.md](theme-support-matrix.md); the policy is
recorded in [ADR-0012](decisions/0012-theme-resolution-policy.md).

## Select a family and variant

```nix
aytordev.theme = {
  name = "catppuccin"; # kanagawa | catppuccin | sora
  variant = "mocha";   # family-specific
};
```

| Family | Default variant | Variants | Polarity |
| --- | --- | --- | --- |
| `kanagawa` | `dragon` | `wave`, `dragon`, `lotus` | dark; `lotus` light |
| `catppuccin` | `mocha` | `latte`, `frappe`, `macchiato`, `mocha` | dark; `latte` light |
| `sora` | `dark` | `dark`, `light` | `dark` official; `light` synthetic |

`variant` is validated against the selected family. There is no `theme.enable`
switch — the module is pure data.

### Read-only accessors

| Accessor | Use |
| --- | --- |
| `palette.<role>.{hex,rgb,sketchybar,raw}` | 26 semantic colors (works in every family/variant) |
| `ansi.{normal,bright,dim}.<slot>` | upstream ANSI table; use for terminal fallbacks |
| `isLight` | active variant polarity |
| `providers`, `integrations` | registry introspection (see below) |

## Per-app overrides

Native-theme apps expose a nullable `theme` option. Four forms:

| Value | Meaning |
| --- | --- |
| `null` / `{ mode = "auto"; }` | follow the hybrid policy (default) |
| `"some-id"` | explicit id; wins over official and generated |
| `{ mode = "manual"; id = "some-id"; }` | same as the bare string |
| `{ mode = "none"; }` | opt out; app keeps its own default |

Example:

```nix
aytordev.programs.desktop.editors.zed.theme = "Catppuccin Mocha";
aytordev.programs.terminal.tools.yazi.theme = { mode = "none"; };
```

The override is per app and is not validated against the active family — a typo
selects nothing the app can resolve, so prefer the discovered `id` values in the
[matrix](theme-support-matrix.md).

## How resolution works

- `official exact` means the provider declares an `integrations.<app>` entry that
  covers the active variant. Adapters treat a declared integration whose variants
  omit the active one as absent, so the generated fallback takes over instead of
  emitting a name the app cannot resolve.
- A malformed integration (missing `source`, bad `variants`) still reaches
  `lib.aytordev.resolveApp` and **throws**, so a broken declaration fails the
  build rather than silently degrading.
- `generated fallback` is the app's own palette-derived resource, marked `G` in
  the matrix. Apps with no upstream resource (Pi, Sketchybar, JankyBorders) are
  always generated.
- `none` means neither an official resource nor a generated path exists; nothing
  is written.

## Add a family

1. Create `modules/home/theme/<family>/provider.nix` and one
   `variants/<variant>.nix` per variant, each exporting
   `{ isLight, rawColors, palette }`.
2. Provider fields: `name`, `displayName`, `defaultVariant`, `darkVariant`,
   `lightVariant`, `variants`, optional `integrations`.
3. Register it in the `themeProviders` attrset in
   `modules/home/theme/default.nix`.
4. `validateProvider` rejects missing fields, unknown variant references, and
   inconsistent light/dark polarity.
5. Add `integrations` only for apps that ship a real upstream resource. All
   palette-derived apps follow the new family for free.

## Add an app integration

1. Add an entry to each supporting family's `integrations`:
   `integrations.<app> = { source; complete; variants.<variant>.id; };`.
2. `source.provenance` — `official-upstream` (the theme project itself) or
   `community-port` (a genuine third-party port).
3. `source.ref.{url,rev}` — a concrete pinned revision, never a moving `HEAD`.
4. `source.vendored = true` when the artifact is copied into this repo; then
   `source.ref.hash` (SRI `sha256`) is **required**. Reference-pinned ports
   resolve their own artifact and omit the hash.
5. `complete = true` only when every provider variant is covered; otherwise list
   the covered `variants` and set `complete = false`.
6. The adapter resolves through `lib.aytordev.resolveApp`; `integrations` is the
   single source of native-resource truth and must never be hand-authored
   elsewhere.

## Provenance and pinning

| Marker | Meaning |
| --- | --- |
| `official-upstream` | shipped by the theme project (`catppuccin/*`, `rebelot/kanagawa.nvim`, `Aejkatappaja/sora`) |
| `community-port` | a real third-party port, e.g. the Kanagawa VS Code/Zed extensions |
| `vendored = true` | artifact copied into this repo and pinned with an SRI hash |
| reference-pinned | adapter resolves `source.ref.{url,rev}` itself; no copied artifact |

Per-variant `hash` is optional even for vendored resources; it adds precision
only when the artifact is split per variant. The full list is in the
[matrix](theme-support-matrix.md).

## Runtime switching

Only **Sketchybar** hot-reloads: its Lua runtime picker switches any registered
family/variant without a Nix rebuild, because `providers` carries every variant.
Every other app re-reads its theme on restart. A global runtime switch is not
promised.

## Documented exceptions

| App / case | Behavior |
| --- | --- |
| Firefox | `userChrome` is generated from the palette for **every** family. The declared id is a Firefox Color theme title, not a UI selection. |
| Pi | No upstream resource; the generated theme and vendored gentle-pi banner deploy with `shell.enable`. With the shell off, the generated file is not deployed and resolution is `none`. |
| Sora `light` | Synthetic, unofficial companion. Sora resources are `dark`-only (`complete = false`), so `light` resolves to generated where the app has a fallback, otherwise `none`. |
| Neovim | Built from the `aytordev-nvim` distribution with the family/variant from `aytordev.theme` (through its `lib.mkAytordevNeovim` builder). Sora is dark-only, so the synthetic `light` companion uses the editor default (`none`). |
| `@catppuccin_flavor` | `catppuccin/tmux` reads this American-spelled option; the adapter sets it to the lower-case flavour id from the integration. |
| JankyBorders, Sketchybar | No upstream resource in any family; both consume raw `sketchybar`-format palette roles. |

## Support matrix

`docs/theme-support-matrix.md` is generated from the provider registry
(`theme.integrations`) and the consuming-adapter inventory. Regenerate it after
any theme change:

```bash
bash checks/theme-catalog/regenerate.sh
```

The `integration-theme-catalog` check fails when the committed file drifts.
