{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.lazygit;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution: exact official resource when the active family
  # ships one for the active variant, otherwise the palette-generated theme.
  lazygitTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  themeResolution = lazygitTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeCfg.integrations.${themeCfg.name}.lazygit or null;
  };
  guiFragment = lazygitTheme.guiSelection {
    resolution = themeResolution;
    inherit (themeCfg) palette;
  };

  # Non-theme gui settings plus the palette-driven per-author/branch colors that
  # used to be hardcoded Kanagawa hexes. These stay in the config for every
  # resolution, so an opt-out (`mode = "none"`) still keeps the author colors.
  guiBase = {
    nerdFontsVersion = "3";
    showListFooter = false;
    showRandomTip = false;
    expandFocusedSidePanel = true;
    authorColors = {
      "${config.aytordev.user.fullName}" = themeCfg.palette.accent.hex;
      "dependabot[bot]" = themeCfg.palette.yellow.hex;
    };
    branchColors = {
      main = themeCfg.palette.red.hex;
      master = themeCfg.palette.red.hex;
      dev = themeCfg.palette.blue.hex;
    };
  };

  # The resolved `gui` fragment owns `theme` (and, for upstream ports that ship
  # them, author colors); its author colors are layered over the palette-driven
  # defaults instead of replacing them.
  gui =
    guiBase
    // (builtins.removeAttrs guiFragment ["authorColors"])
    // {
      authorColors = guiBase.authorColors // (guiFragment.authorColors or {});
    };

  # Vendored ids an explicit override may name. Lazygit themes are inline maps,
  # not named resources, so the only pinnable ids are the vendored ones.
  vendoredThemes = builtins.attrNames lazygitTheme.officialById;

  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated theme, manual pins id, none leaves Lazygit's default.";
      };
      id = mkOption {
        type = types.nullOr (types.enum vendoredThemes);
        default = null;
        description = "Vendored theme id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.lazygit = {
    enable = mkEnableOption "lazygit";
    package = mkPackageOption pkgs "lazygit" {};

    theme = mkOption {
      type = types.nullOr (types.either (types.enum vendoredThemes) themeOverrideType);
      default = null;
      description = ''
        Lazygit theme override. Null follows `aytordev.theme` through the hybrid
        resolver: the family's official resource when it covers the active
        variant, otherwise a theme generated from the active palette. A bare
        vendored id (or `{ mode = "manual"; id = ...; }`) pins a theme;
        `{ mode = "none"; }` leaves Lazygit's own default.
        Vendored themes: ${builtins.concatStringsSep ", " vendoredThemes}
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.lazygit =
      {
        enable = true;
        inherit (cfg) package;
        settings = {
          customCommands = import ./custom-commands.nix;
          inherit gui;
          git = {
            overrideGpg = true;
            mainBranches = [
              "main"
              "master"
            ];
          };
          os = {
            editPreset = "nvim";
          };
        };
      }
      // (lib.aytordev.shellIntegration config).flags;
    # The shell-integration wrapper owns `lg` (lazygit + cd on exit). No manual
    # alias/conf.d: a bare alias would shadow the wrapper in bash/fish/nushell.
  };
}
