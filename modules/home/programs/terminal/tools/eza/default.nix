{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.eza;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution: exact official resource when the active family
  # ships one for the active variant, otherwise the palette-generated theme.
  ezaTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeResolution = ezaTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeCfg.integrations.${themeCfg.name}.eza or null;
  };

  themeSelection = ezaTheme.themeSelection {
    resolution = themeResolution;
    inherit (themeCfg) palette ansi;
  };

  # Manual override validation: only the vendored ids and the generated id are
  # materializable, so a bare override (or submodule id) must name one.
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated theme, manual pins id, none emits no theme selection.";
      };
      id = mkOption {
        type = types.nullOr (types.enum ezaTheme.themeIds);
        default = null;
        description = "Theme id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.eza = {
    enable = mkEnableOption "eza";
    package = lib.mkPackageOption pkgs "eza" {};

    theme = mkOption {
      type = types.nullOr (types.either (types.enum ezaTheme.themeIds) themeOverrideType);
      default = null;
      description = ''
        eza theme override. Null follows `aytordev.theme` through the hybrid
        resolver: the family's official resource when it covers the active
        variant, otherwise a theme generated from the active palette. A bare
        theme id, or `{ mode = "manual"; id = ...; }`, pins a theme;
        `{ mode = "none"; }` emits no theme selection and leaves eza's default.
        Theme ids: ${builtins.concatStringsSep ", " ezaTheme.themeIds}
      '';
    };
  };
  config = mkIf cfg.enable (
    let
      si = lib.aytordev.shellIntegration config;
      eza = getExe cfg.package;
    in {
      programs.eza =
        {
          enable = true;
          inherit (cfg) package;
          extraOptions = [
            "--group-directories-first"
            "--header"
            "--hyperlink"
            "--follow-symlinks"
          ];
          git = true;
          icons = "auto";
        }
        // {
          # bash/fish/zsh integrations (ls/ll/la/lt/lla) reach those shells;
          # nushell keeps its structured `ls`, so we do NOT enable nushell
          # integration and do NOT put `ls` in home.shellAliases.
          inherit
            (si.flags)
            enableBashIntegration
            enableFishIntegration
            enableZshIntegration
            ;
        }
        // optionalAttrs (themeSelection.mode == "generated") {
          inherit (themeSelection) theme;
        };

      # Official themes are vendored `theme.yml` files; the generated theme is
      # written by `programs.eza.theme` above. Only one path is ever active.
      xdg.configFile = optionalAttrs (themeSelection.mode == "official") {
        "eza/theme.yml".source = themeSelection.path;
      };

      # Shell-agnostic listing aliases (no `ls`, which would shadow nushell's
      # built-in structured `ls`). These override the HM module's minimal
      # defaults in bash/zsh/fish and reach nushell too.
      home.shellAliases = {
        la = "${eza} -la --group-directories-first --header --icons=auto --git --tree";
        ll = "${eza} -l --group-directories-first --header --icons=auto --git";
        lt = "${eza} --tree --level=2 --group-directories-first --icons=auto";
        tree = "${eza} --tree --icons=always";
      };
    }
  );
}
