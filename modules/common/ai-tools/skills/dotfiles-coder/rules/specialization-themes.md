## Theme System

**Impact:** HIGH

`aytordev.theme` is the single source of truth for all theming. Use the semantic palette API (`cfg.palette.accent.hex`, `cfg.palette.red.rgb`). Never hardcode colors or use variant-specific color names. Native themes resolve through `lib.aytordev.resolveApp`.

Three families are registered (`kanagawa`, `catppuccin`, `sora`) and more can be
added by importing a provider that satisfies `themeLib.validateProvider`.
`integrations` is the single source of native-resource truth: each app entry
declares `source.provenance` (`official-upstream`/`community-port`), a concrete
pinned `source.ref.{url,rev}`, an SRI `hash` when the resource is `vendored`, the
exact per-variant `id` and `complete` coverage. Apps that generate their config
from `palette` support every family for free. Apps that select a native theme
resolve the name through `lib.aytordev.resolveApp` with the policy **explicit
override > official exact (app + family + variant) > generated fallback > none**;
otherwise leave the app default and expose a nullable `theme` override.
A per-app override is a bare id,
`{ mode = "manual"; id = ...; }`, or `{ mode = "none"; }`; `null` / `auto`
follows the policy. The derived family × app matrix and its provenance live in
`docs/theme-support-matrix.md` (regenerate with
`bash checks/theme-catalog/regenerate.sh`); the human guide is
`docs/theme-system.md` and the policy is
[ADR-0012](../../../../../../docs/decisions/0012-theme-resolution-policy.md).

**Incorrect (Hardcoded Colors):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
in
{
  config = lib.mkIf cfg.enable {
    # BAD: hardcoded colors
    programs.myApp.accentColor = "#7e9cd8";

    # BAD: variant-specific names
    programs.myApp.theme =
      if config.aytordev.theme.variant == "wave"
      then "Kanagawa Wave"
      else "Kanagawa Lotus";
  };
}
```

**Correct (Semantic Palette):**

```nix
{ config, lib, ... }:
let
  cfg = config.aytordev.programs.myApp;
  theme = config.aytordev.theme;
in
{
  config = lib.mkIf cfg.enable {
    programs.myApp = {
      # Semantic colors — work with any theme/variant
      accentColor = theme.palette.accent.hex;
      errorColor = theme.palette.red.hex;
      bgColor = theme.palette.bg.hex;

      # Named native theme resolved through the hybrid policy
      theme = lib.aytordev.resolveApp {
        app = "myApp";
        inherit (theme) variant;
        official = theme.integrations.${theme.name}.myApp or null;
      };

      # Polarity detection
      lightMode = theme.isLight;
    };
  };
}
```
