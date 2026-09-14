{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig;

  theme = themeConfig {};

  herdrFor = family: variant:
    import ../../modules/home/programs/terminal/tools/herdr/theme.nix {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  soraDark = theme.providers.sora.variants.dark;
  soraAnsi = theme.providers.sora.ansi.dark;
in {
  testHerdrThemeFollowsHostTerminal = {
    expr = {
      inherit ((herdrFor "sora" "dark")) name;
      autoSwitch = (herdrFor "sora" "dark").auto_switch;
    };
    expected = {
      name = "terminal";
      autoSwitch = false;
    };
  };

  testHerdrThemeMapsPaletteRoles = {
    expr = {
      accent = (herdrFor "sora" "dark").custom.accent;
      panel = (herdrFor "sora" "dark").custom.panel_bg;
      text = (herdrFor "sora" "dark").custom.text;
      subtext = (herdrFor "sora" "dark").custom.subtext0;
      red = (herdrFor "sora" "dark").custom.red;
      mauve = (herdrFor "sora" "dark").custom.mauve;
    };
    expected = {
      accent = soraDark.accent.hex;
      panel = soraDark.bg.hex;
      text = soraDark.fg.hex;
      subtext = soraDark.fg_dim.hex;
      red = soraDark.pink.hex;
      mauve = soraDark.violet.hex;
    };
  };

  testHerdrThemeUsesAnsiGreen = {
    expr = (herdrFor "sora" "dark").custom.green;
    expected = soraAnsi.normal.green.hex;
  };

  testHerdrThemeFollowsActiveFamily = {
    expr = (herdrFor "kanagawa" "dragon").custom.accent == (herdrFor "sora" "dark").custom.accent;
    expected = false;
  };
}
