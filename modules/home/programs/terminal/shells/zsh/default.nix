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
  cfg = config.aytordev.programs.terminal.shells.zsh;
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in
{
  options.aytordev.programs.terminal.shells.zsh = {
    enable = mkEnableOption "Z shell with useful defaults";
    package = mkPackageOption pkgs "zsh" { };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home = {
        packages = with pkgs; [
          zsh-completions
        ];
        activation = {
          zshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/zsh"
            $DRY_RUN_CMD chmod 700 "${config.xdg.configHome}/zsh"
          '';
          zshSessionDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            export ZSH_SESSION_DIR="${config.xdg.dataHome}/zsh/sessions"
            $DRY_RUN_CMD mkdir -p "$ZSH_SESSION_DIR"
            $DRY_RUN_CMD chmod 700 "$ZSH_SESSION_DIR"
            ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
              OLD_SESSION_DIR="$HOME/.zsh_sessions"
              if [ -d "$OLD_SESSION_DIR" ] && [ ! -L "$OLD_SESSION_DIR" ]; then
                $DRY_RUN_CMD echo "Migrando sesiones Zsh antiguas a directorio XDG..."
                STAMP="$(date +%s 2>/dev/null || echo "prev")"
                $DRY_RUN_CMD mv "$OLD_SESSION_DIR" "$OLD_SESSION_DIR.bak.$STAMP"
              fi
              if [ ! -e "$OLD_SESSION_DIR" ]; then
                $DRY_RUN_CMD ln -sf "$ZSH_SESSION_DIR" "$OLD_SESSION_DIR"
              fi
              unset OLD_SESSION_DIR STAMP
            ''}
          '';
        };
      };

      programs.zsh = {
        enable = true;
        inherit (cfg) package;
        dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        enableVteIntegration = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        # Upstream writes ZDOTDIR into .zshenv when dotDir is set; only the
        # ZSH_* overrides are needed here.
        envExtra = ''
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
        # Upstream runs compinit once (order 570) and sources autosuggestion
        # (700) and syntax highlighting (1200). This block only adds fpath for
        # zsh-completions and the completion styles.
        initContent = ''
          fpath=(
            ${pkgs.zsh-completions}/share/zsh/site-functions
            "$fpath[@]"
          )
          [[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
          [[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"
          [[ ! -d "$ZSH_SESSION_DIR" ]] && mkdir -p "$ZSH_SESSION_DIR"
          zstyle ":completion:*" menu select
          zstyle ":completion:*" group-name ""
          zstyle ":completion:*:descriptions" format "%F{green}-- %d --%f"
          zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|=*" "l:|=* r:|=*"
          zstyle ":completion:*" use-cache on
          zstyle ":completion:*" cache-path "$ZSH_CACHE_DIR/zcompcache"
        '';
      };
    }
  ]);
}
