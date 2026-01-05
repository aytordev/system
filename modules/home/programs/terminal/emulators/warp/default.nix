{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.emulators.warp;
in {
  options.aytordev.programs.terminal.emulators.warp = {
    enable = lib.mkEnableOption "Warp terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [warp-terminal];

    # Copy themes to XDG config directory
    xdg.configFile."warp/themes".source = ./themes;

    home.activation = {
      createWarpDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p "${config.xdg.configHome}/warp"
        mkdir -p "${config.xdg.cacheHome}/warp"
        mkdir -p "${config.xdg.dataHome}/warp"

        # Create themes directory if it doesn't exist
        mkdir -p "${config.xdg.configHome}/warp/themes"

        # Copy themes if they don't exist to allow user customization
        if [ ! -f "${config.xdg.configHome}/warp/themes/catppuccin_mocha.yml" ]; then
          cp -n ${./themes}/*.yml "${config.xdg.configHome}/warp/themes/" 2>/dev/null || true
        fi

        if [ -d "$HOME/.warp" ] && [ ! -L "$HOME/.warp" ]; then
          if [ -n "$(ls -A $HOME/.warp 2>/dev/null)" ]; then
            # Don't overwrite existing themes when migrating
            if [ -d "$HOME/.warp/themes" ]; then
              mkdir -p "${config.xdg.configHome}/warp/themes"
              cp -n $HOME/.warp/themes/*.yml "${config.xdg.configHome}/warp/themes/" 2>/dev/null || true
            fi
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
