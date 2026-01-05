{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.programs.terminal.shells.nu;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.aytordev.programs.terminal.shells.nu = {
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
      programs.nushell = {
        enable = true;
        envFile = {
          text = ''
            $env.XDG_CONFIG_HOME = "${xdgConfigHome}"
            $env.XDG_DATA_HOME = "${xdgDataHome}"
            $env.XDG_CACHE_HOME = "${xdgCacheHome}"
            $env.NU_HISTORY = "${xdgDataHome}/nu/history.txt"
            $env.NU_LIB_DIRS = [
              "${xdgConfigHome}/nushell"
            ]
            $env.NU_PLUGIN_DIRS = [
              "${xdgConfigHome}/nushell/plugins"
            ]
          '';
        };
        configFile = {
          text = ''
            $env.config = {
              show_banner: false
              ls: {
                clickable_links: true
                use_ls_colors: true
              }
              history: {
                max_size: 10000
                sync_on_enter: true
                file_format: "plaintext"
              }
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
          '';
        };
      };
      home.activation = {
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
