# Shared evaluation helpers for theme and theme-consumer tests.
# Kept under fixtures/ so the test-file glob in tests/default.nix never
# imports it as a test suite.
{
  self,
  lib,
}: let
  themeLib = import ../../../modules/home/theme/lib.nix {inherit lib;};

  # Evaluate the theme module with optional overrides. `assertions` is declared
  # locally so the pure-data theme module can be evaluated without Home Manager.
  evalTheme = extra:
    lib.evalModules {
      modules = [
        ../../../modules/home/theme
        {
          options.assertions = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [];
          };
        }
        extra
      ];
    };

  themeConfig = extra: (evalTheme extra).config.aytordev.theme;
  themeAssertionsHold = extra: builtins.all (assertion: assertion.assertion) (evalTheme extra).config.assertions;
  activeThemePalette = (themeConfig {}).palette;
in {
  inherit
    themeLib
    evalTheme
    themeConfig
    themeAssertionsHold
    activeThemePalette
    ;

  # Pure per-app integration resolver from the shared module library.
  resolveApp = self.lib.module.resolveApp;

  # Force an expression past WHNF so nested errors are caught. `tryEval` alone
  # only evaluates to WHNF; `deepSeq` walks the whole value first.
  throws = expression: !(builtins.tryEval (builtins.deepSeq expression true)).success;
}
