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
      # Zsh packages - only include packages that provide binaries or need to be in PATH
      home.packages = with pkgs; [
        zsh # The Z shell itself
        zsh-completions
        nix-zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
      ];

      # Zsh configuration
      programs.zsh = {
        enable = true;

        # XDG Base Directory compliance
        dotDir = ".config/zsh";
        enableCompletion = true;
        enableVteIntegration = true;

        # Plugins configuration
        plugins = [
          {
            name = "zsh-completions";
            src = "${pkgs.zsh-completions}/share/zsh/site-functions";
          }
          {
            name = "nix-zsh-completions";
            src = "${pkgs.nix-zsh-completions}/share/zsh/site-functions";
          }
          {
            name = "zsh-autosuggestions";
            src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
          }
          {
            name = "zsh-syntax-highlighting";
            src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
          }
        ];

        # Environment variables and directory setup
        envExtra = ''
          # Set ZDOTDIR if not already set
          export ZDOTDIR="${xdgConfigHome}/zsh"

          # Ensure ZDOTDIR exists
          if [ ! -d "$ZDOTDIR" ]; then
            mkdir -p "$ZDOTDIR"
          fi

          # Set ZSH_CACHE_DIR for completion cache
          export ZSH_CACHE_DIR="${xdgCacheHome}/zsh"
          if [ ! -d "$ZSH_CACHE_DIR" ]; then
            mkdir -p "$ZSH_CACHE_DIR"
          fi
        '';

        # History configuration
        history = {
          size = 10000;
          save = 10000;
          path = "${xdgDataHome}/zsh/history";
          ignoreDups = true;
          share = true;
          expireDuplicatesFirst = true;
          extended = true;
        };

        # Completion system initialization (kept for backward compatibility)
        completionInit = ''
          # Completion initialization moved to initContent
        '';

        # Additional initialization code
        initContent = ''
          # Set up fpath for completions
          fpath=(
            ${pkgs.zsh-completions}/share/zsh/site-functions
            ${pkgs.nix-zsh-completions}/share/zsh/site-functions
            "$fpath[@]"
          )

          # Initialize completion system
          autoload -Uz compinit
          compinit -d "${xdgCacheHome}/zsh/zcompdump-''${ZSH_VERSION}"

          # Load bash completion compatibility
          autoload -Uz bashcompinit && bashcompinit

          # Source plugins
          source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
          source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

          # Apply completion styles
          zstyle ":completion:*" menu select
          zstyle ":completion:*" group-name ""
          zstyle ":completion:*:descriptions" format "%F{green}-- %d --%f"
          zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|=*" "l:|=* r:|=*"
          zstyle ":completion:*" use-cache on
          zstyle ":completion:*" cache-path "${xdgCacheHome}/zsh/zcompcache"
        '';
      };

      # Ensure the ZDOTDIR exists and has the correct permissions
      home.activation.zshDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/zsh"
        $DRY_RUN_CMD chmod 700 "${config.xdg.configHome}/zsh"
      '';
    }
  ]);
}
