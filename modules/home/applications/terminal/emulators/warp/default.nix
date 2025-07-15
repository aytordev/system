{ config, lib, pkgs, ... }:

let
  cfg = config.applications.terminal.emulators.warp;
in {
  options.applications.terminal.emulators.warp = {
    enable = lib.mkEnableOption "Warp terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ warp-terminal ];
    
    home.activation = {
      createWarpDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.xdg.configHome}/warp"
        mkdir -p "${config.xdg.cacheHome}/warp"
        mkdir -p "${config.xdg.dataHome}/warp"
        
        if [ -d "$HOME/.warp" ] && [ ! -L "$HOME/.warp" ]; then
          if [ -n "$(ls -A $HOME/.warp 2>/dev/null)" ]; then
            cp -r $HOME/.warp/* "${config.xdg.configHome}/warp/" 2>/dev/null || true
            rm -rf $HOME/.warp
          fi
        fi
        
        if [ ! -e "$HOME/.warp" ]; then
          ln -sfn "${config.xdg.configHome}/warp" "$HOME/.warp"
        fi
      '';
    };
  };
}