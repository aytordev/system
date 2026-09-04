{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkMerge
    mkPackageOption
    ;
  cfg = config.aytordev.programs.terminal.shells.nushell;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in
{
  options.aytordev.programs.terminal.shells.nushell = {
    enable = mkEnableOption "Nu shell with useful defaults";
    package = mkPackageOption pkgs "nushell" { };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      programs.nushell = {
        enable = true;
        inherit (cfg) package;
        # Upstream owns the plugin registry (plugin add per package). The plugin
        # binaries are registered absolute, so they need no PATH entry.
        plugins = with pkgs; [
          nushellPlugins.query
          nushellPlugins.formats
          nushellPlugins.polars
        ];
        envFile = {
          text = ''
            $env.XDG_CONFIG_HOME = "${xdgConfigHome}"
            $env.XDG_DATA_HOME = "${xdgDataHome}"
            $env.XDG_CACHE_HOME = "${xdgCacheHome}"
            $env.NU_LIB_DIRS = [
              "${xdgConfigHome}/nushell"
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
        createXdgDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # nushell ignores NU_HISTORY and stores history.txt under the config
          # dir; seal that dir to keep plaintext history private.
          $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/nushell"
          $DRY_RUN_CMD chmod 700 "${xdgConfigHome}/nushell"
          $DRY_RUN_CMD mkdir -p "${xdgDataHome}/nu"
          $DRY_RUN_CMD chmod 700 "${xdgDataHome}/nu"
          $DRY_RUN_CMD mkdir -p "${xdgCacheHome}/nu"
        '';
      };
    }
  ]);
}
