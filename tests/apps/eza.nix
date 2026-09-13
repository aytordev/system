{
  self,
  lib,
}: let
  context = import ../theme/fixtures/context.nix {inherit self lib;};
  inherit (context) themeConfig throws;

  eza = import ../../modules/home/programs/terminal/tools/eza/config.nix {
    inherit lib;
    inherit (self.lib.module) resolveApp;
  };

  theme = themeConfig {};
  inherit (theme) integrations;

  resolveFor = family: variant: override:
    eza.resolve {
      inherit variant override;
      integration = integrations.${family}.eza or null;
    };

  selectionFor = family: variant: override: let
    resolution = resolveFor family variant override;
  in
    eza.themeSelection {
      inherit resolution;
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  renderFor = family: variant:
    eza.render {
      palette = theme.providers.${family}.variants.${variant};
      ansi = theme.providers.${family}.ansi.${variant};
    };

  moduleSource =
    builtins.readFile ../../modules/home/programs/terminal/tools/eza/default.nix
    + builtins.readFile ../../modules/home/programs/terminal/tools/eza/config.nix;
in {
  # ─── Official resource selection per family/variant ───────────────────────

  testEzaSoraDarkResolvesOfficial = {
    expr = resolveFor "sora" "dark" null;
    expected = {
      kind = "official";
      id = "sora";
      provenance = "official-upstream";
      variantProvenance = "official";
      source = "official";
    };
  };

  # ─── Uncovered variants generate ──────────────────────────────────────────

  testEzaKanagawaDragonResolvesGenerated = {
    expr = resolveFor "kanagawa" "dragon" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testEzaSoraLightResolvesGenerated = {
    expr = resolveFor "sora" "light" null;
    expected = {
      kind = "generated";
      id = "aytordev";
      source = "generated";
    };
  };

  testEzaSoraLightIsNotTheSoraOfficial = {
    expr = (resolveFor "sora" "light" null).id == "sora";
    expected = false;
  };

  # ─── Explicit override wins ───────────────────────────────────────────────

  testEzaStringOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" "sora";
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  testEzaManualOverrideWins = {
    expr = resolveFor "kanagawa" "dragon" {
      mode = "manual";
      id = "sora";
    };
    expected = {
      kind = "explicit";
      id = "sora";
      source = "user";
    };
  };

  # ─── Opt-out emits no theme selection ─────────────────────────────────────

  testEzaNoneOverrideEmitsNothing = {
    expr = selectionFor "sora" "dark" {mode = "none";};
    expected = {
      mode = "none";
    };
  };

  testEzaNoneOverrideDropsGeneratedTheme = {
    expr = selectionFor "kanagawa" "dragon" {mode = "none";};
    expected = {
      mode = "none";
    };
  };

  # ─── Official selection names the vendored theme.yml ──────────────────────

  testEzaOfficialSoraSelectsVendoredFile = {
    expr = selectionFor "sora" "dark" null;
    expected = {
      mode = "official";
      path = ../../modules/home/programs/terminal/tools/eza/themes/sora.yml;
    };
  };

  testEzaManualOverrideToSoraSelectsVendoredFile = {
    expr = selectionFor "kanagawa" "dragon" {
      mode = "manual";
      id = "sora";
    };
    expected = {
      mode = "official";
      path = ../../modules/home/programs/terminal/tools/eza/themes/sora.yml;
    };
  };

  # ─── Generated selection renders the palette theme ────────────────────────

  testEzaGeneratedSelectionRendersTheme = {
    expr = selectionFor "kanagawa" "dragon" null;
    expected = {
      mode = "generated";
      theme = renderFor "kanagawa" "dragon";
    };
  };

  testEzaManualOverrideToGeneratedPinsGeneratedTheme = {
    expr = selectionFor "sora" "dark" {
      mode = "manual";
      id = "aytordev";
    };
    expected = {
      mode = "generated";
      theme = renderFor "sora" "dark";
    };
  };

  # ─── Generated colors match the active palette and ANSI table ─────────────

  testEzaGeneratedThemeMapsRolesToPalette = {
    expr = let
      t = renderFor "kanagawa" "dragon";
      p = theme.providers.kanagawa.variants.dragon;
      a = theme.providers.kanagawa.ansi.dragon;
    in {
      normal = t.filekinds.normal.foreground == p.fg.hex;
      directory = t.filekinds.directory.foreground == p.accent.hex;
      executable = t.filekinds.executable.foreground == p.green.hex;
      userWrite = t.perms.user_write.foreground == p.red.hex;
      gitNew = t.git.new.foreground == a.normal.green.hex;
      image = t.file_type.image.foreground == a.normal.magenta.hex;
    };
    expected = {
      normal = true;
      directory = true;
      executable = true;
      userWrite = true;
      gitNew = true;
      image = true;
    };
  };

  testEzaGeneratedThemeFollowsActiveFamily = {
    expr = let
      p = theme.providers.sora.variants.light;
      t = renderFor "sora" "light";
    in
      t.filekinds.normal.foreground == p.fg.hex && t.filekinds.directory.foreground == p.accent.hex;
    expected = true;
  };

  # ─── Vendored theme files exist and carry upstream colors ─────────────────

  testEzaVendoredThemesExist = {
    expr = builtins.all (id: builtins.pathExists eza.officialThemes.${id}) (
      builtins.attrNames eza.officialThemes
    );
    expected = true;
  };

  testEzaVendoredSoraCarriesPaletteColors = {
    expr = let
      text = builtins.readFile eza.officialThemes.sora;
    in {
      directory = lib.hasInfix "#80c8e0" text;
      fg = lib.hasInfix "#c8d0e0" text;
      gitNew = lib.hasInfix "#68b080" text;
    };
    expected = {
      directory = true;
      fg = true;
      gitNew = true;
    };
  };

  testEzaGeneratedIdDoesNotCollideWithVendoredThemes = {
    expr = eza.officialThemes ? ${eza.generatedId};
    expected = false;
  };

  # ─── Module wiring preserves settings and excludes nushell ────────────────

  testEzaModuleKeepsSettingsAndExcludesNushell = {
    expr = {
      bash = lib.hasInfix "enableBashIntegration" moduleSource;
      fish = lib.hasInfix "enableFishIntegration" moduleSource;
      zsh = lib.hasInfix "enableZshIntegration" moduleSource;
      nushell = lib.hasInfix "enableNushellIntegration" moduleSource;
      lsAlias = lib.hasInfix "ls = " moduleSource;
      git = lib.hasInfix "git = true" moduleSource;
      icons = lib.hasInfix "icons = \"auto\"" moduleSource;
      followSymlinks = lib.hasInfix "--follow-symlinks" moduleSource;
      la = lib.hasInfix "la = " moduleSource;
      ll = lib.hasInfix "ll = " moduleSource;
      lt = lib.hasInfix "lt = " moduleSource;
      tree = lib.hasInfix "tree = " moduleSource;
    };
    expected = {
      bash = true;
      fish = true;
      zsh = true;
      nushell = false;
      lsAlias = false;
      git = true;
      icons = true;
      followSymlinks = true;
      la = true;
      ll = true;
      lt = true;
      tree = true;
    };
  };

  testEzaBrokenIntegrationThrows = {
    expr = throws (
      eza.resolve {
        variant = "dark";
        override = null;
        integration = {
          source = null;
          variants.dark.id = "sora";
        };
      }
    );
    expected = true;
  };
}
