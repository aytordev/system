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

        # Environment variables
        envExtra = ''
          # XDG Base Directory variables
          export ZDOTDIR="${xdgConfigHome}/zsh"
          export ZSH_CACHE_DIR="${xdgCacheHome}/zsh"
          export ZSH_DATA_DIR="${xdgDataHome}/zsh"
          export ZSH_SESSION_DIR="$ZSH_DATA_DIR/sessions"
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

        # Empty completionInit as we handle everything in initContent
        completionInit = '''';

        # Main initialization code
        initContent = ''
          # Set up fpath for completions
          fpath=(
            ${pkgs.zsh-completions}/share/zsh/site-functions
            ${pkgs.nix-zsh-completions}/share/zsh/site-functions
            "$fpath[@]"
          )

          # Create necessary directories if they don't exist
          [[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
          [[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"
          [[ ! -d "$ZSH_SESSION_DIR" ]] && mkdir -p "$ZSH_SESSION_DIR"

          # Initialize completion system
          autoload -Uz compinit
          compinit -d "$ZSH_CACHE_DIR/zcompdump-''${ZSH_VERSION}"

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
          zstyle ":completion:*" cache-path "$ZSH_CACHE_DIR/zcompcache"
        '';
      };

      # Ensure the ZDOTDIR exists and has the correct permissions
      home.activation.zshDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/zsh"
        $DRY_RUN_CMD chmod 700 "${config.xdg.configHome}/zsh"
      '';

      # Ensure ZSH session directory exists with correct permissions
      home.activation.zshSessionDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export ZSH_SESSION_DIR="${config.xdg.dataHome}/zsh/sessions"
        $DRY_RUN_CMD mkdir -p "$ZSH_SESSION_DIR"
        $DRY_RUN_CMD chmod 700 "$ZSH_SESSION_DIR"
        
        # For macOS Terminal.app compatibility
        if [ "$(uname -s)" = "Darwin" ]; then
          OLD_SESSION_DIR="$HOME/.zsh_sessions"
          if [ -d "$OLD_SESSION_DIR" ] && [ ! -L "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD echo "Migrando sesiones Zsh antiguas a directorio XDG..."
            $DRY_RUN_CMD mv "$OLD_SESSION_DIR" "$OLD_SESSION_DIR.bak"
          fi
          if [ ! -e "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD ln -sf "$ZSH_SESSION_DIR" "$OLD_SESSION_DIR"
          fi
          unset OLD_SESSION_DIR
        fi
      '';
    }
  ]);
}
