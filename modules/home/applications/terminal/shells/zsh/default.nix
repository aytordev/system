{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.zsh;

  # XDG Base Directory paths
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.zsh = {
    enable = mkEnableOption "Z shell with useful defaults";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.zsh = {
        enable = true;

        # XDG Base Directory compliance
        dotDir = ".config/zsh";

        # Set ZDOTDIR to ensure all zsh files are in XDG config
        envExtra = ''
          # Set ZDOTDIR if not already set
          export ZDOTDIR="${xdgConfigHome}/zsh"

          # Ensure ZDOTDIR exists
          if [ ! -d "$ZDOTDIR" ]; then
            mkdir -p "$ZDOTDIR"
          fi

          # Set ZSH data directories according to XDG spec
          export ZSH="${xdgDataHome}/zsh"
          export ZSH_CACHE_DIR="${xdgCacheHome}/zsh"

          # Create necessary directories
          mkdir -p "$ZSH"
          mkdir -p "$ZSH_CACHE_DIR"
        '';

        # History settings with XDG compliance
        history = {
          path = "${xdgDataHome}/zsh/history";
          save = 10000;
          size = 10000;
          share = true;
          expireDuplicatesFirst = true;
          extended = true;
        };

        # Completion cache in XDG cache directory
        completionInit = ''
          autoload -Uz compinit
          zstyle ':completion:*' cache-path ${xdgCacheHome}/zsh/zcompcache
          zmodload zsh/complist
          compinit -d ${xdgCacheHome}/zsh/zcompdump
        '';
      };

      # Required packages
      home.packages = with pkgs; [
        zsh
      ];

      # Create necessary XDG directories
      xdg.configFile."zsh".source =
        lib.mkIf (config.programs.zsh.dotDir == ".config/zsh")
        (pkgs.runCommand "zsh-config-dir" {} ''
          mkdir -p $out
          # Add any default zsh configuration files here if needed
        '');
    }
  ]);
}
