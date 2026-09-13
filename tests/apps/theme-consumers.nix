{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig activeThemePalette;
  yaziFlavor = import ../../modules/home/programs/terminal/tools/yazi/flavor.nix {
    palette = activeThemePalette;
  };
  piTheme = import ../../modules/home/programs/terminal/tools/pi/theme.nix {
    palette = activeThemePalette;
  };
in {
  testYaziFlavorCoversAllSections = {
    expr = map (section: lib.hasInfix section yaziFlavor) [
      "[mgr]"
      "[tabs]"
      "[mode]"
      "[status]"
      "[pick]"
      "[input]"
      "[cmp]"
      "[tasks]"
      "[which]"
      "[help]"
      "[spot]"
      "[notify]"
      "[filetype]"
    ];
    expected = [
      true
      true
      true
      true
      true
      true
      true
      true
      true
      true
      true
      true
      true
    ];
  };

  testYaziFlavorHasNoUnresolvedInterpolationOrNulls = {
    expr = {
      hasPlaceholder = lib.hasInfix "\${" yaziFlavor;
      hasNull = lib.hasInfix "null" yaziFlavor;
    };
    expected = {
      hasPlaceholder = false;
      hasNull = false;
    };
  };

  testYaziFlavorUsesActiveFamilyAccent = {
    expr = let
      inherit ((themeConfig {aytordev.theme.name = "sora";})) palette;
      flavor = import ../../modules/home/programs/terminal/tools/yazi/flavor.nix {inherit palette;};
    in
      lib.hasInfix palette.accent.hex flavor;
    expected = true;
  };

  testPiThemeIsValidJsonFollowingPalette = {
    expr = let
      parsed = builtins.fromJSON (builtins.toJSON piTheme);
    in {
      inherit (parsed) name;
      accent = parsed.vars.accent;
      hasColors = parsed.colors ? accent;
      hasExport = parsed.export ? pageBg;
    };
    expected = {
      name = "aytordev";
      accent = activeThemePalette.accent.hex;
      hasColors = true;
      hasExport = true;
    };
  };

  testPiThemeFollowsActiveFamily = {
    expr = let
      inherit ((themeConfig {aytordev.theme.name = "sora";})) palette;
    in
      (import ../../modules/home/programs/terminal/tools/pi/theme.nix {inherit palette;}).vars.bg;
    expected = "#0e1018";
  };
}
