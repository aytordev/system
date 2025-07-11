{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.nu;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.nu = {
    enable = mkEnableOption "Nu shell with useful defaults";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        nushell
        nushellPlugins.query
        nushellPlugins.formats
        nushellPlugins.polars
      ];

      # Enable fzf (configured in tools/fzf)

      # Nu shell configuration
      programs.nushell = {
        enable = true;

        # Environment variables - using direct paths to avoid initialization issues
        envFile = {
          text = ''
            # Set up XDG directories with fallbacks
            $env.XDG_CONFIG_HOME = "${xdgConfigHome}"
            $env.XDG_DATA_HOME = "${xdgDataHome}"
            $env.XDG_CACHE_HOME = "${xdgCacheHome}"

            # Set history file location
            $env.NU_HISTORY = "${xdgDataHome}/nu/history.txt"

            # Set up completions and config paths
            $env.NU_LIB_DIRS = [
              "${xdgConfigHome}/nushell"
            ]

            $env.NU_PLUGIN_DIRS = [
              "${xdgConfigHome}/nushell/plugins"
            ]
          '';
        };

        # Main config file
        configFile = {
          text = ''
            # Enable syntax highlighting
            $env.config = {
              show_banner: false
              ls: {
                clickable_links: true
                use_ls_colors: true
              }

              # History settings
              history: {
                max_size: 10000
                sync_on_enter: true
                file_format: "plaintext"
              }

              # Completions
              completions: {
                case_sensitive: false
                quick: true
                partial: true
                algorithm: "fuzzy"
                external: {
                  enable: true
                  max_results: 100
                  completer: null
                }
              }

              # Shell integration is handled by Starship

              # Keybindings
              keybindings: [
                {
                  name: completion_menu
                  modifier: none
                  keycode: tab
                  mode: [emacs, vi_normal, vi_insert]
                  event: {
                    until: [
                      { send: menu name: completion_menu }
                      { send: menupagenext }
                    ]
                  }
                }
              ]
            }

            # fzf configuration is managed by tools/fzf module

          '';
        };
      };

      # Create necessary directories with proper activation
      home.activation = {
        # Create base XDG directories
        createXdgDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
          $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/nushell/plugins"
          $DRY_RUN_CMD mkdir -p "${xdgDataHome}/nu"
          $DRY_RUN_CMD chmod 700 "${xdgDataHome}/nu"
          $DRY_RUN_CMD mkdir -p "${xdgCacheHome}/nu"
        '';
      };
    }
  ]);
}
