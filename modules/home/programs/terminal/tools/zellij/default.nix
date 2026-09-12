{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.programs.terminal.tools.zellij;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution: exact official resource when the active family
  # ships one for the active variant, otherwise the palette-generated theme.
  zellijTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  zellijIntegration = themeCfg.integrations.${themeCfg.name}.zellij or null;
  themeResolution = zellijTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = zellijIntegration;
  };
  generatedTheme = zellijTheme.render {inherit (themeCfg) palette;};
  officialThemeFile = zellijTheme.officialThemeFiles.${themeCfg.name} or null;

  # zns/zas/zo need command substitution and a local variable; put the logic in
  # a bin so it is shell-agnostic and `exec` preserves the TTY/signals for the
  # interactive multiplexer. The aliases become thin, Nu-safe forwards.
  zellijSession = pkgs.writeShellApplication {
    name = "zellij-session";
    runtimeInputs = [pkgs.zellij];
    text = ''
      mode="''${1:-}"
      session_name="$(basename "$(pwd)")"
      case "$mode" in
        new)
          exec ${lib.getExe cfg.package} -s "$session_name" options --default-cwd "$(pwd)"
          ;;
        attach)
          exec ${lib.getExe cfg.package} a "$session_name"
          ;;
        open)
          exec ${lib.getExe cfg.package} attach --create "$session_name" options --default-cwd "$(pwd)"
          ;;
        *)
          echo "usage: zellij-session {new|attach|open}" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  imports = [
    ./keybinds.nix
    ./layouts/dev.nix
    ./layouts/system.nix
  ];
  options.aytordev.programs.terminal.tools.zellij = {
    enable = lib.mkEnableOption "zellij";
    package = lib.mkPackageOption pkgs "zellij" {};
    theme = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.either lib.types.str (
          lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.enum [
                  "auto"
                  "manual"
                  "none"
                ];
                default = "auto";
                description = "auto follows the family's official resource or the generated theme; manual pins id; none leaves Zellij's default theme.";
              };
              id = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Theme name to pin when mode = \"manual\".";
              };
            };
          }
        )
      );
      default = null;
      description = ''
        Zellij theme override. Null follows `aytordev.theme` through the hybrid
        resolver. A bare theme name (or `{ mode = "manual"; id = ...; }`) pins a
        theme; `{ mode = "none"; }` leaves Zellij's own default.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [zellijSession];
    home.shellAliases = {
      zns = "zellij-session new";
      zas = "zellij-session attach";
      zo = "zellij-session open";
    };
    programs = {
      zellij = {
        enable = true;
        inherit (cfg) package;
        settings =
          {
            copy_command =
              if pkgs.stdenv.hostPlatform.isDarwin
              then "pbcopy"
              else "";
            auto_layouts = true;
            default_layout = "dev";
            default_mode = "locked";
            support_kitty_keyboard_protocol = true;
            on_force_close = "quit";
            pane_frames = true;
            pane_viewport_serialization = true;
            scrollback_lines_to_serialize = 1000;
            session_serialization = true;
            ui.pane_frames = {
              rounded_corners = true;
              hide_session_name = true;
            };
            plugins = {
              tab-bar.path = "tab-bar";
              status-bar.path = "status-bar";
              strider.path = "strider";
              compact-bar.path = "compact-bar";
            };
          }
          // zellijTheme.themeSetting themeResolution;
        themes = zellijTheme.themeFiles {
          officialName = themeCfg.name;
          officialFile = officialThemeFile;
          resolution = themeResolution;
          generatedText = generatedTheme;
        };
      };
    };
  };
}
