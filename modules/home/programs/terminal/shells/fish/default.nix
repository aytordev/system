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
    mkMerge
    mkPackageOption
    ;
  cfg = config.aytordev.programs.terminal.shells.fish;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.aytordev.programs.terminal.shells.fish = {
    enable = mkEnableOption "Fish shell with useful defaults";
    package = mkPackageOption pkgs "fish" {};
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        cfg.package
        # fishPlugins that ship vendored conf.d/functions auto-load via the
        # nixpkgs fish wrapper; keeping them here is enough, no plugins wiring.
        fishPlugins.done
        fishPlugins.forgit
        fishPlugins.pisces
        fishPlugins.z
      ];
      programs.fish = {
        enable = true;
        inherit (cfg) package;
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
          set -gx VISUAL (command -v nvim || command -v vim || command -v vi || echo "vi")
          set -gx BAT_THEME "base16"
        '';
      };
      home.activation.fishDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/fish/functions"
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/fish"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/fish"
      '';
    }
  ]);
}
