{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.fish;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.fish = {
    enable = mkEnableOption "Fish shell with useful defaults";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        fish
        fishPlugins.done
        fishPlugins.forgit
        fishPlugins.grc
        fishPlugins.pisces
        fishPlugins.pure
        fishPlugins.z
      ];
      programs.fish = {
        enable = true;
        functions = {
          __ensure_xdg_dirs = ''
            set -l xdg_config "$XDG_CONFIG_HOME/fish"
            set -l xdg_data "$XDG_DATA_HOME/fish"
            set -l xdg_cache "$XDG_CACHE_HOME/fish"
            for dir in "$xdg_config" "$xdg_data" "$xdg_cache"
              if not test -d "$dir"
                command mkdir -p "$dir"
              end
            end
          '';
        };
        shellInit = ''
          set -gx XDG_CONFIG_HOME "${xdgConfigHome}"
          set -gx XDG_DATA_HOME "${xdgDataHome}"
          set -gx XDG_CACHE_HOME "${xdgCacheHome}"
          __ensure_xdg_dirs
          set -gx fish_greeting ""
          set -gx fish_history "fish"
          set -gx fish_user_paths $fish_user_paths
          fish_add_path --path --global ~/.local/bin
          fish_add_path --path --global ~/.cargo/bin
          fish_add_path --path --global ~/go/bin
          set -gx EDITOR (command -v nvim || command -v vim || command -v vi || echo "vi")
          set -gx VISUAL $EDITOR
          set -gx PAGER (command -v less || echo "cat")
          set -gx LESS "-R"
          set -gx LANG en_US.UTF-8
          set -gx LC_ALL en_US.UTF-8
          set -gx BAT_THEME "base16"
        '';
        interactiveShellInit = ''
          if command -q zoxide
            zoxide init fish | source
          end
          if command -q direnv
            direnv hook fish | source
          end
        '';
        plugins = [
          {
            name = "z";
            src = "${pkgs.fishPlugins.z.src}";
          }
        ];
      };
      home.activation.fishDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/fish/functions"
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/fish"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/fish"
      '';
    }
  ]);
}
