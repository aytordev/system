{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    getExe
    mkIf
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.bat;
  themeCfg = config.aytordev.theme;

  inherit
    (pkgs.bat-extras)
    batdiff
    batgrep
    batman
    batpipe
    batwatch
    prettybat
    ;

  # Hybrid theme resolution: exact official tmTheme when the active family
  # ships one for the active variant, otherwise the palette-generated tmTheme.
  batTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeIntegration = themeCfg.integrations.${themeCfg.name}.bat or null;
  themeResolution = batTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeIntegration;
  };

  generatedTheme = batTheme.render {
    inherit (themeCfg) palette ansi;
  };

  # The generated tmTheme is materialized only when the resolver selects it;
  # `writeText` stays lazy and unbuilt otherwise.
  generatedSource = pkgs.writeText "aytordev.tmTheme" generatedTheme;

  # `programs.bat.themes` keys are filenames; values are the resolved file.
  # Official ids resolve to vendored files, the generated id to the rendered
  # tmTheme. A `none` selection deploys no theme at all.
  themeNames = builtins.attrNames batTheme.officialThemes ++ [batTheme.generatedId];
  themes = lib.mapAttrs (_: src: {inherit src;}) (
    batTheme.themeSources {
      resolution = themeResolution;
      inherit generatedSource;
    }
  );

  # An explicit selection pins `--theme`; `none` leaves bat's own default.
  themeConfig = lib.optionalAttrs (themeResolution.kind != "none") {theme = themeResolution.id;};

  # Manual override validation: only the vendored official names and the
  # generated name are materializable, so a bare override (or submodule id)
  # must name one of them.
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated tmTheme, manual pins id, none leaves bat's default.";
      };
      id = mkOption {
        type = types.nullOr (types.enum themeNames);
        default = null;
        description = "Theme name to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.bat = {
    enable = lib.mkEnableOption "bat";
    package = lib.mkPackageOption pkgs "bat" {};

    theme = mkOption {
      type = types.nullOr (types.either (types.enum themeNames) themeOverrideType);
      default = null;
      description = ''
        bat theme override. Null follows `aytordev.theme` through the hybrid
        resolver. A bare vendored theme name, or `{ mode = "manual"; id = ...; }`,
        pins a theme; `{ mode = "none"; }` leaves bat's own default.
        Available themes: ${builtins.concatStringsSep ", " themeNames}
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      inherit (cfg) package;
      inherit themes;
      config =
        {
          style = "auto,header-filesize";
        }
        // themeConfig;
      extraPackages = [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };
    # cat is a drop-in for bat in every shell (nushell has no cat builtin, so
    # no conflict). No --style override: let cat honor the configured style.
    home.shellAliases = {
      cat = "${getExe cfg.package}";
    };
  };
}
