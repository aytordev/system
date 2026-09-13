# 0014 — Remove the Catppuccin theme family

- **Status:** Accepted (implementation in progress)
- **Date:** 2026-09-13
- **Supersedes subject of:** modifies `0010-multi-family-theme-providers.md`
  (Catppuccin is retired from the provider registry)
- **Related:** `0010`, `0011`, `0012`,
  `0013-theme-integrations-are-the-only-native-registry.md`

## Context

The theme system supports multiple provider families. Catppuccin is one of
them: it ships four flavors (`latte`, `frappe`, `macchiato`, `mocha`), the
largest set of vendored native resources (25 files), and it is the only family
that is fully covered in both dark and light polarity and the only
plugin-backed `tmux` family.

It is being retired: the owner prefers the Kanagawa and Sora families, and
Catppuccin's maintenance surface (4 flavors × resources × tests) is no longer
justified.

## Decisions

1. **Replacement policy.** Where Catppuccin was used as a generic/second
   family, replace it per case:
   - Dark / official-generated coverage → **Sora** (`dark`).
   - Light / official coverage (resources that Sora lacks, e.g. VS Code) →
     **Kanagawa `lotus`**.
   - Where a case is Catppuccin-specific (per-flavor maps, official ids,
     plugin flavor), delete it instead of repointing.
2. **Simplify dead branches.** The `tmux` plugin-backed branch, the VS Code
   Catppuccin-only `iconTheme`, and the Catppuccin extensions are removed, not
   kept as generic placeholders.
3. **Zed icon theme.** Drop `icon_theme = "Catppuccin Mocha"` for now; Zed
   keeps its own default.
4. **ADR-0010.** Keep it as a historical record and update it to note the
   Catppuccin removal and point to this ADR.

## False positives (do NOT touch)

- `flake/docs/generate.nix:31` — `flattener`
- `checks/shell-init-uniqueness/default.nix:86` — `latter`
- `modules/home/programs/desktop/window-manager-system/aerospace/default.nix:47,186` — `flatten`
- `modules/common/ai-tools/skills/sdd-init/rules/execution-detect-testing.md:18` — `mocha` (JS test runner)

## Scope inventory

Counts (case-insensitive `catppuccin`): 62 files, 543 matches.
Files/dirs named `catppuccin`: 22. Provider files: 6. Vendored resources: 25.

### Data to delete

Provider (`modules/home/theme/catppuccin/`):
`provider.nix`, `palette.nix`, `variants/{latte,frappe,macchiato,mocha}.nix`.

Vendored resources:
- `terminal/emulators/ghostty/themes/catppuccin-{latte,frappe,macchiato,mocha}.conf`
- `terminal/tools/bat/themes/catppuccin-*.tmTheme`
- `terminal/tools/btop/themes/catppuccin_*.theme`
- `terminal/tools/eza/themes/catppuccin-*-mauve.yml`
- `terminal/tools/opencode/themes/catppuccin-*-mauve.json`
- `terminal/tools/yazi/flavors/catppuccin-*-mauve/flavor.toml`
- `terminal/tools/zellij/themes/catppuccin.kdl`

Test to delete: `tests/theme/integrations-catppuccin.nix`.

### Provider plumbing (`modules/home/theme/default.nix`)

- `38-42`: remove `catppuccin =` registry entry.
- `70`: reword ANSI comment (drop "Catppuccin's `ansiColors`").
- `173`: drop "For Catppuccin: latte, frappe, macchiato, mocha."
- `242-243`: drop `providers.catppuccin` examples.

### Adapters

| File | Action |
| --- | --- |
| `bat/config.nix:22-25` | drop 4 entries |
| `btop/config.nix:19-26` | drop 4 entries + comment |
| `eza/config.nix:10-11,28-29,33-36` | drop 4 entries + comment |
| `opencode/config.nix:24-25,29-32` | drop 4 entries + comment |
| `yazi/config.nix:11,25-26,29-32` | drop 4 entries + comment |
| `zellij/config.nix:17-19,23` | drop entry + comment |
| `fzf/official-colors.nix:9-11,17-84` | drop 4 maps + header |
| `lazygit/official-themes.nix:7-10,16-106` | drop block + header |
| `starship/official-palettes.nix:11-19,21-137` | drop block + header |
| `starship/config.nix:32` | reword comment |
| `starship/official-styles.nix:10` | reword comment |
| `git/extras.nix:22` | reword comment |
| `tmux/config.nix:3,24-28` + `tmux/default.nix:30,70` | remove plugin branch (simplify) |
| `vscode/default.nix:65-70` | remove `iconTheme` branch |
| `vscode/default.nix:207-208` | remove Catppuccin extensions |
| `vscode/settings.nix` | remove Catppuccin-only icon-theme setting |
| `zed/default.nix:83,85` | remove `catppuccin`, `catppuccin-icons` |
| `zed/default.nix:104` | remove `icon_theme` |

### Checks

| File | Action |
| --- | --- |
| `home-portability:58-75,111-112` | rewrite `catppuccinHome`/`catppuccinDevHome` |
| `home-portability:160-166` | drop provider/ghostty asserts |
| `home-portability:177,190` | drop yazi/sketchybar asserts → sora/kanagawa |
| `home-portability:197-213,232-237` | repoint vscode/zed; drop icon asserts |
| `sketchybar-theme:151,169,187,201,258` | seed `sora/dark` instead of `catppuccin/mocha` |
| `starship-config:53,59-62` | drop the `catppuccin` config |
| `theme-catalog/generate.nix:110` | reword tmux note |

### Tests — cases to delete

- `tests/theme/integrations-catppuccin.nix` (whole file)
- `ansi.nix`: `testCatppuccinAnsiMatchesUpstream`, `testCatppuccinBrightRolesSourceAnsi`
- `providers.nix`: `testThemeCatppuccinLatte`, `testThemeCatppuccinExposesEveryVariant`, `testCatppuccinFrappeLabelIsAccented`
- `bat.nix`: `testBatCatppuccinResolvesOfficialPerVariant`
- `btop.nix`: `testBtopCatppuccinResolvesOfficialPerVariant`
- `eza.nix`: `testEzaCatppuccinMochaResolvesOfficial`, `testEzaCatppuccinEveryFlavorResolvesOfficial`, `testEzaOfficialCatppuccinSelectsVendoredFile`, `testEzaVendoredCatppuccinCarriesMochaMauve`
- `fzf.nix`: `testFzfCatppuccinMochaResolvesOfficial`, `testFzfCatppuccinResolvesOfficialPerFlavor`, `testFzfOfficialCatppuccinColorsMatchUpstream`
- `ghostty.nix`: `testGhosttyCatppuccinMochaResolvesOfficial`
- `lazygit.nix`: `testLazygitCatppuccinMochaResolvesOfficial`, `testLazygitCatppuccinEveryFlavorResolvesOfficial`, `testLazygitOfficialCatppuccinEmitsVendoredTheme`, `testLazygitCatppuccinOfficialCarriesAuthorColors`
- `opencode.nix`: `testOpencodeCatppuccinResolvesOfficialPerVariant`
- `starship.nix`: `testStarshipCatppuccinMochaResolvesOfficial`, `testStarshipCatppuccinMochaVendorsUpstreamPalette`
- `tmux.nix`: `testTmuxCatppuccinMochaResolvesOfficial`, `testTmuxCatppuccinLatteResolvesOfficial`, `testTmuxCatppuccinMaterializesOfficialPluginAndFlavor`, `testTmuxCatppuccinOverridePinsFlavor`
- `vscode.nix`: `testVscodeCatppuccinFrappeResolvesOfficial`
- `yazi.nix`: `testYaziCatppuccinResolvesOfficialPerFlavor`, `testYaziCatppuccinMochaResolvesOfficial`, `testYaziOfficialCatppuccinDeploysVendoredFlavor`, `testYaziVendoredCatppuccinFlavorIsValidFlavor`, `testYaziVendoredFlavorsExistPerFlavor`
- `zed.nix`: `testZedCatppuccinMochaResolvesOfficial`
- `zellij.nix`: `testZellijCatppuccinMochaResolvesOfficial`, `testZellijCatppuccinLatteResolvesOfficial`

### Tests — cases to repoint (generic family → Sora/Kanagawa)

- `ansi.nix`: `testActiveAnsiFollowsSelectedFamilyAndVariant`, `testOnlySoraAnsiHasDimSlots` (drop `catppuccinHasDim`)
- `providers.nix`: `testThemeIntegrationsArePerFamily`, `testThemeProvidersAgreeWithComputedPalette`
- `theme-consumers.nix:60,86` (accent/bg palette)
- `tmux.nix:90-109,188-196,307-318`
- `starship.nix:214-236`
- `vscode.nix:109-118`, `yazi.nix:151-172`, `zellij.nix:70-92`,
  `eza.nix:107-129`, `bat.nix:161-193`, `btop.nix:220-255`, `fzf.nix:162-186`,
  `zed.nix:144-164`, `jankyborders.nix:82`, `opencode.nix:130-150`

### Tests — expected lists to trim

- `providers.nix`: `testThemeExposesEveryProvider`,
  `testThemeExposesEveryFamilyIntegrations`, `testNativeAppsArePerFamily`,
  `testThemeAcceptsEveryVariant`
- `ansi.nix`: `testProvidersExposeAnsiForEveryFamilyVariant`

### Docs / meta

| File:line | Action |
| --- | --- |
| `docs/theme-system.md:22,30,59,116,140` | family, table, examples, marker, tmux row |
| `docs/theme-support-matrix.md` | regenerate |
| `README.md:64` | family list |
| `modules/home/AGENTS.md:128` | family list |
| `skills/dotfiles-coder/.../specialization-themes.md:7` | example |
| `docs/decisions/0010-...md:14` | historical note + link here |

## Execution plan (agent partitions)

Wave 1 (max 5 concurrent, disjoint files):

- **Agent A — provider core + data.** Delete provider dir, 25 vendored
  resources; edit `theme/default.nix`. Do not touch `tests/`.
- **Agent B — terminal adapters.** All `terminal/tools` edits incl. `tmux`
  simplification; reword comments.
- **Agent C — desktop adapters + checks.** `vscode`, `zed`, and the four
  `checks/` files.
- **Agent D — tests.** Delete `integrations-catppuccin.nix`; prune/repoint all
  cases above.
- **Agent E — docs text.** `theme-system.md`, `README.md`, `AGENTS.md`, skill,
  and update ADR-0010.

Wave 2 (after A completes):

- Regenerate `docs/theme-support-matrix.md`
  (`bash checks/theme-catalog/regenerate.sh`).
- Run `nix fmt` once to normalize any editor-induced formatting.
- Run the full check suite; fix fallout.

## Verification

```bash
nix fmt
nix flake check --no-build
nix build .#checks.aarch64-darwin.unit-nix-unit --no-link
nix build .#checks.aarch64-darwin.integration-theme-catalog --no-link
nix build .#checks.aarch64-darwin.integration-home-portability --no-link
nix build .#checks.aarch64-darwin.integration-starship-config --no-link
nix build .#checks.aarch64-darwin.integration-sketchybar-theme --no-link
nix build .#homeConfigurations.aytordev@wang-lin.activationPackage --no-link
```

## Progress tracker

- [x] Agent A — provider core + data
- [x] Agent B — terminal adapters
- [x] Agent C — desktop adapters + checks
- [x] Agent D — tests
- [x] Agent E — docs text
- [x] Wave 2 — matrix regeneration + `nix fmt`
- [x] Full verification green

## Outcome (2026-09-13)

Executed by this agent orchestrating five concurrent `general` sub-agents
(one per partition), then a wave-2 cleanup.

- 31 files deleted (provider 6 + vendored resources 25), one test file deleted.
- Adapters, checks, tests, and docs updated; support matrix regenerated.
- `tmux` plugin branch, VS Code Catppuccin icon theme, and Zed `icon_theme`
  removed (decisions 2 and 3).
- `home-portability` repointed: `soraDesktopHome` (Sora dark) and
  `kanagawaLightHome` (Kanagawa `lotus`).
- Extra fallout fixed during verification: `tests/apps/sketchybar.nix`
  catalog count 9 → 5; `tests/apps/firefox.nix` and `tests/apps/pi.nix`
  repointed (not enumerated up front).
- Post-removal audit found 56 orphaned Catppuccin Thunderbird `.xpi` theme
  packages under
  `modules/home/programs/desktop/communications/thunderbird/themes/`
  (4 flavors × 14 accents). They were unreferenced by any code and had been
  missed by text search because `.xpi` are binary archives; `git grep -a`
  exposed them. The whole `themes/` directory was deleted.
- Intentional remaining references: the rejection regression test in
  `tests/theme/providers.nix`, the historical note in ADR-0010, and the
  `mocha` JS test-runner mention in the sdd-init skill (not Catppuccin).

Verification (all green):

```text
nix flake check --no-build
unit-nix-unit                              383/383
integration-theme-catalog
integration-home-portability
integration-starship-config
integration-sketchybar-theme
integration-synthetic-home
integration-synthetic-darwin
integration-docs-generation
integration-theme-migration
integration-module-contract
integration-shell-init-uniqueness
production-home-aytordev-wang-lin
treefmt
homeConfigurations.aytordev@wang-lin.activationPackage
```

Operational note: after agent edits, clear `~/.cache/treefmt` before `nix fmt`
or the formatter may skip a file it has already hashed (this hid one
non-alejandra `tmux/default.nix` until the cache was cleared).
