# Sora TUI parity (zellij components + tmux status)

## Intent and constraints

Make the two terminal multiplexers actually follow the active Sora theme,
using only official upstream guidance:

- `soratheme.com` (Aejkatappaja/sora) prescribes exactly one tmux integration:
  `source-file ~/.config/tmux/sora.tmux.conf`. This repository already vendors
  that conf byte-for-byte, but `tmux/config.nix` appends `staticConfig` after it
  and forces `set -g status-position top`, overriding Sora's own
  `status-position bottom`. The status line must be governed by the official
  resource again.
- `soratheme.com` lists **no** zellij entry, and upstream `extras/` ships no
  zellij artifact, so an "official" zellij resource cannot exist. Zellij must
  keep resolving to the palette-generated fallback, which is the honest
  `generated` provenance.

User decisions in this session: drop the `codingjerk/dotfiles` adaptation
entirely (no LICENSE upstream); follow the official Sora approach for tmux;
align zellij to Sora; implement option A plus the tmux status fix.

Not authorized: push, PR, merge, activation, live-file edits, a new
third-party dependency, or a locally-authored "official" Sora zellij resource.
Work-unit commits on the feature branch are part of the authorized ODD
implementation.

### Why the current zellij theme is not Sora

Verified against zellij 0.45.1 (`zellij-utils/src/kdl/mod.rs`,
`zellij-utils/src/data.rs`): a theme whose children are all within
`{fg,bg,red,green,yellow,blue,magenta,orange,cyan,black,white}` is parsed with
the **legacy palette** path and converted to the component schema by a fixed,
lossy mapping (`From<Palette> for Styling`, with `ThemeHue::Dark` default):

| Legacy key we emit | Our value | Actual zellij role |
| --- | --- | --- |
| `black` | `bg_dim` `#0a0c12` | `text_unselected.background` |
| `white` | `fg_reverse` `#dce4f0` | `text_unselected.base` |
| `fg` | `#c8d0e0` | `ribbon_unselected.background` |
| `green` | `raw.ok` `#68a888` | `frame_selected.base` |
| `blue` (accent) | `#80c8e0` | ribbon emphasis only |
| `bg` | `#0e1018` | unused for text |

So `bg`/`fg` never reach the main text and the focused pane frame is green
instead of the Sora cyan accent. The fix is to emit the **component schema**
directly.

## Design

`modules/home/programs/terminal/tools/zellij/config.nix` keeps a single source
of truth: `aytordev.theme.palette`. `render` emits
`themes { aytordev { <components> } }` in the component schema, each component
with `base`, `background`, `emphasis_0..3` as `"#RRGGBB"` strings (zellij
accepts a `#RRGGBB` string child for component colors; RGB triplets and
eight-bit indices are alternatives).

Component -> palette role mapping (all values from the active `palette`):

| Component | base | background | emphasis_0..3 |
| --- | --- | --- | --- |
| `text_unselected` | `fg` | `bg` | `orange`, `cyan`, `green`, `violet` |
| `text_selected` | `fg` | `selection` | `orange`, `cyan`, `green`, `violet` |
| `ribbon_unselected` | `fg_dim` | `bg_dim` | `red`, `fg`, `accent`, `violet` |
| `ribbon_selected` | `bg` | `accent` | `red`, `orange`, `violet`, `accent` |
| `table_title` | `accent` | `bg_dim` | `orange`, `cyan`, `green`, `violet` |
| `table_cell_unselected` | `fg_dim` | `bg` | `orange`, `cyan`, `green`, `violet` |
| `table_cell_selected` | `fg` | `selection` | `orange`, `cyan`, `green`, `violet` |
| `list_unselected` | `fg_dim` | `bg_dim` | `orange`, `cyan`, `green`, `violet` |
| `list_selected` | `fg` | `selection` | `orange`, `cyan`, `green`, `violet` |
| `frame_unselected` | `border` | `bg` | `orange`, `cyan`, `green`, `violet` |
| `frame_selected` | `accent` | `bg` | `orange`, `cyan`, `green`, `violet` |
| `frame_highlight` | `yellow` | `bg` | `orange`, `cyan`, `green`, `violet` |
| `exit_code_success` | `green` | `bg` | `cyan`, `green`, `accent`, `violet` |
| `exit_code_error` | `red` | `bg` | `yellow`, `red`, `orange`, `violet` |
| `multiplayer_user_colors` | `player_1..10` = `accent`, `blue`, `violet`, `yellow`, `cyan`, `orange`, `red`, `fg_dim`, `pink`, `green` |

Constraints:

- Keep the generated id `aytordev` and the `generatedThemeContracts` shape
  (`resolution.kind == "generated"` writes the file). Resolution, provenance,
  the provider registry, and the support matrix stay unchanged (`zellij` stays
  `G` for every family).
- The emitted theme must **not** use the legacy top-level keys, so the
  component path is always taken. Add a regression assertion for this.
- `frame_unselected` is optional in zellij; emit it with the palette `border`
  so unfocused panes keep a visible frame.

## Tasks and routing

- [x] **T1 — Zellij component theme + tests.** `render` now emits the
  component schema from `aytordev.theme.palette`; `tests/apps/zellij.nix`
  asserts component colors plus the absence of legacy keys. Commit `50ab47c1`.
- [x] **T2 — tmux status alignment + tests.** The `status-position top`
  override is gone and the two assertions were inverted; the stale status
  comments in `config.nix`/`default.nix` were refreshed. Commit `94602af8`.
- [x] **T3 — Independent verification.** `gentle-ai-verify` returned PASS for
  all six claims; no code correction required. See Evidence.
- [ ] **T4 — Delivery.** Commit done on the feature branch; push, PR and merge
  remain separate decisions.

### Scope note

Five files changed, not four: the parent refreshed the stale status comment in
`modules/home/programs/terminal/tools/tmux/default.nix` (comments only) after the
bounded writer finished.

## Verification contract

Runner (both platforms are evaluated; build the darwin check locally):

```sh
nix build --no-link --no-write-lock-file \
  --override-input secrets path:./checks/fixtures/secrets \
  'path:.#checks.aarch64-darwin.unit-nix-unit'
```

Focused checks for this change: `unit-nix-unit` (pure tests),
`integration-home-portability`, `integration-module-contract`,
`integration-theme-migration`, `integration-docs-generation`, then
`nix flake check path:. --all-systems --no-build --override-input secrets
path:./checks/fixtures/secrets --no-write-lock-file`.

Required evidence:

- Intended RED before implementation, GREEN after, with the observed counts.
- A rendered `aytordev.kdl` sample containing the component schema and the
  mapped colors for Sora dark; assertion that no legacy top-level key remains.
- `tmux` composed `extraConfig` no longer contains `status-position`, while the
  sourced official conf path and the rest of the layout are unchanged.
- `flake.lock` byte-identical before and after
  (`82d2c0e2e24b79e876339b685d17ab55fbdcadc5` at branch start). Only the four
  scoped files may change.

## Acceptance criteria

1. The generated zellij theme uses the component schema and derives every color
   from the active palette.
2. Sora dark produces `frame_selected.base` = accent, `ribbon_selected.background`
   = accent, `text_unselected.base`/`.background` = `fg`/`bg`.
3. Kanagawa and the synthetic Sora light variant keep working (generated, from
   their own palettes) with no resolver change.
4. tmux `staticConfig` no longer sets `status-position`, so the official Sora
   conf governs it; no other static setting is dropped.
5. Focused checks pass; no lockfile or out-of-scope file changes.

## Evidence

Branch: `feat/sora-tui-parity` (from `62ead227`).

- Candidate commits: `50ab47c1` (zellij) and `94602af8` (tmux); five files,
  +93/-45.
- Strict test-first by the bounded writer: T1 RED 400/402 (the two updated
  zellij tests), GREEN 402/402; T2 RED 400/402 (the two updated tmux tests),
  GREEN 402/402.
- `unit-nix-unit`, `integration-home-portability`, `integration-module-contract`,
  `integration-theme-migration`, `integration-docs-generation`: exit 0.
- Independent verification (`gentle-ai-verify`, read-only) re-derived the
  rendered themes without importing the app tests: 14 style components x six
  colors plus `player_1..10`; `sora/dark` `frame_selected.base` `#80c8e0`,
  `ribbon_selected.background` `#80c8e0`, `text_unselected` `#c8d0e0` on
  `#0e1018`; `kanagawa/dragon` renders from its own palette; `none` emits
  nothing; resolution stays `generated`/`aytordev` for all five variants.
- tmux: composed `extraConfig` still begins with the store-backed official
  `sora.tmux.conf`, contains no `status-position`, and keeps every prior static
  setting.
- `flake.lock` byte-identical before and after
  (`82d2c0e2e24b79e876339b685d17ab55fbdcadc5`); `.pi/` and the two pre-existing
  untracked zed task docs untouched.

### Limits (do not overstate)

- No live zellij parser/session or tmux activation was executed; schema
  acceptance is verified structurally against zellij 0.45.1's documented
  component contract, not by running zellij.
- The unit check output does not expose the test count in this environment.
- The regression tests exclude legacy `bg`/`fg`; the stronger "exactly 15
  component children" claim was checked by the verifier's independent render,
  not by a committed assertion.
- Historical RED was observed by the writer, not replayed by the verifier.
