{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  themeCfg = config.aytordev.theme;

  cfg = config.aytordev.programs.terminal.tools.tmux;

  # Pure per-family theme adapter (resolve + materialize + palette renderer).
  tmuxTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeResolution = tmuxTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeCfg.integrations.${themeCfg.name}.tmux or null;
  };

  themeArtifacts = tmuxTheme.materialize {
    family = themeCfg.name;
    inherit (themeCfg) palette;
    resolution = themeResolution;
  };

  # A plugin-backed family (catppuccin) carries its selection on the plugin
  # entry so the option is set before the plugin's `run-shell`; sourced
  # (sora) and generated (kanagawa) families append to `extraConfig` instead.
  themePlugin = lib.optional (themeArtifacts.pluginName != null) {
    plugin = pkgs.tmuxPlugins.${themeArtifacts.pluginName};
    inherit (themeArtifacts) extraConfig;
  };
  themeExtraConfig =
    lib.optionalString (
      themeArtifacts.pluginName == null
    )
    themeArtifacts.extraConfig;

  themeOverrideType = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family integration, manual pins id, none leaves the app default.";
      };
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Theme/flavour id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.tmux = {
    enable = lib.mkEnableOption "tmux";
    package = lib.mkPackageOption pkgs "tmux" {nullable = true;};
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.str themeOverrideType);
      default = null;
      description = ''
        tmux theme override. Null follows `aytordev.theme` through the hybrid
        resolver: the family's official resource when it exists (catppuccin
        plugin flavour, sora conf), otherwise a palette-generated fallback.
        A bare id (or `{ mode = "manual"; id = ...; }`) pins a selection;
        `{ mode = "none"; }` leaves tmux's own default.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      inherit (cfg) package;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      # HM's default (isLinux) keeps secureSocket off on macOS, where
      # /run/user does not exist and TMUX_TMPDIR would point nowhere.
      sensibleOnTop = false;
      terminal = "tmux-256color";

      plugins =
        (with pkgs.tmuxPlugins; [
          # Tested options for TMUX compatibility
          {plugin = sensible;}

          # Clipboard management
          {plugin = yank;}

          # Tmux Navigation
          {plugin = vim-tmux-navigator;}

          # Tmux Resurrect
          {plugin = resurrect;}

          # Continuous saving of tmux environment
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '10'
            '';
          }

          # Floating pane
          {
            plugin = tmux-floax;
            extraConfig = ''
              set -g @floax-bind 'p'
              set -g @floax-change-path 'true'
            '';
          }

          # Session manager with fuzzy finding
          {
            plugin = tmux-sessionx;
            extraConfig = ''
              set -g @sessionx-bind 'o'
            '';
          }

          # Which Key
          {plugin = tmux-which-key;}
        ])
        # Theme loads last so it takes effect.
        ++ themePlugin;

      # Theme settings first, then the theme-independent layout so user
      # preferences (for example `status-position top`) win over a sourced conf.
      extraConfig = tmuxTheme.composeExtraConfig {inherit themeExtraConfig;};
    };
  };
}
