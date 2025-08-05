{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.zsh;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.zsh = {
    enable = mkEnableOption "Z shell with useful defaults";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        zsh
        zsh-completions
        nix-zsh-completions
        zsh-autosuggestions
        zsh-syntax-highlighting
      ];
      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        enableVteIntegration = true;
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
        envExtra = ''
          export ZDOTDIR="${xdgConfigHome}/zsh"
          export ZSH_CACHE_DIR="${xdgCacheHome}/zsh"
          export ZSH_DATA_DIR="${xdgDataHome}/zsh"
          export ZSH_SESSION_DIR="$ZSH_DATA_DIR/sessions"
        '';
        history = {
          size = 10000;
          save = 10000;
          path = "${xdgDataHome}/zsh/history";
          ignoreDups = true;
          share = true;
          expireDuplicatesFirst = true;
          extended = true;
        };
        completionInit = '''';
        initContent = ''
          fpath=(
            ${pkgs.zsh-completions}/share/zsh/site-functions
            ${pkgs.nix-zsh-completions}/share/zsh/site-functions
            "$fpath[@]"
          )
          [[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
          [[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"
          [[ ! -d "$ZSH_SESSION_DIR" ]] && mkdir -p "$ZSH_SESSION_DIR"
          autoload -Uz compinit
          compinit -d "$ZSH_CACHE_DIR/zcompdump-''${ZSH_VERSION}"
          autoload -Uz bashcompinit && bashcompinit
          source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
          source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
          zstyle ":completion:*" menu select
          zstyle ":completion:*" group-name ""
          zstyle ":completion:*:descriptions" format "%F{green}-- %d --%f"
          zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|=*" "l:|=* r:|=*"
          zstyle ":completion:*" use-cache on
          zstyle ":completion:*" cache-path "$ZSH_CACHE_DIR/zcompcache"
        '';
      };
      home.activation.zshDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/zsh"
        $DRY_RUN_CMD chmod 700 "${config.xdg.configHome}/zsh"
      '';
      home.activation.zshSessionDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export ZSH_SESSION_DIR="${config.xdg.dataHome}/zsh/sessions"
        $DRY_RUN_CMD mkdir -p "$ZSH_SESSION_DIR"
        $DRY_RUN_CMD chmod 700 "$ZSH_SESSION_DIR"
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
