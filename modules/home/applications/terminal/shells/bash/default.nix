{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.applications.terminal.shells.bash;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
  bashConfigDir = "${xdgConfigHome}/bash";
  bashDataDir = "${xdgDataHome}/bash";
  bashCacheDir = "${xdgCacheHome}/bash";
  bashrc = ''
    export XDG_CONFIG_HOME="${xdgConfigHome}"
    export XDG_DATA_HOME="${xdgDataHome}"
    export XDG_CACHE_HOME="${xdgCacheHome}"
    export BASH_CONFIG_DIR="${bashConfigDir}"
    export BASH_DATA_DIR="${bashDataDir}"
    export BASH_CACHE_DIR="${bashCacheDir}"
    export BASH_SESSION_DIR="${bashDataDir}/sessions"
    export HISTFILE="${bashDataDir}/history"
    export HISTSIZE=10000
    export HISTFILESIZE=100000
    export HISTCONTROL=ignoredups:erasedups
    shopt -s histappend
    shopt -s checkwinsize extglob globstar checkjobs autocd cdspell dirspell nocaseglob
    export INPUTRC="${bashConfigDir}/inputrc"
    [ -f /etc/bashrc ] && . /etc/bashrc
    for f in "${bashConfigDir}/conf.d/"*.sh; do
      [ -f "$f" ] && . "$f"
    done
    if [ "$(uname -s)" = "Darwin" ] && [ -n "$TERM_SESSION_ID" ]; then
      :
    fi
  '';
in {
  options.aytordev.applications.terminal.shells.bash = {
    enable = mkEnableOption "Bash shell with useful defaults";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        bash
      ];
      applications.bash = {
        enable = false;
      };
      home.file.".config/bash/.bashrc" = {
        text = bashrc;
      };
      home.file.".bashrc" = {
        force = true;
        text = ''
          [ -f "$HOME/.config/bash/.bashrc" ] && . "$HOME/.config/bash/.bashrc"
        '';
      };
      home.file.".bash_profile" = {
        force = true;
        text = ''
          [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
        '';
      };
      home.file.".profile" = {
        force = true;
        text = ''
          [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
        '';
      };
      home.activation.bashDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${bashConfigDir}/conf.d"
        $DRY_RUN_CMD mkdir -p "${bashDataDir}/sessions"
        $DRY_RUN_CMD mkdir -p "${bashCacheDir}"
        $DRY_RUN_CMD chmod 700 "${bashConfigDir}"
        $DRY_RUN_CMD chmod 700 "${bashDataDir}"
        $DRY_RUN_CMD chmod 700 "${bashDataDir}/sessions"
        $DRY_RUN_CMD chmod 700 "${bashCacheDir}"
        if [ "$(uname -s)" = "Darwin" ]; then
          OLD_SESSION_DIR="$HOME/.bash_sessions"
          if [ -d "$OLD_SESSION_DIR" ] && [ ! -L "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD echo "Moving existing bash_sessions to XDG directory..."
            $DRY_RUN_CMD mv "$OLD_SESSION_DIR" "$OLD_SESSION_DIR.bak"
          fi
          if [ ! -e "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD ln -sf "${bashDataDir}/sessions" "$OLD_SESSION_DIR"
          fi
        fi
        if [ ! -f "${bashConfigDir}/inputrc" ]; then
          $DRY_RUN_CMD echo "# Bash readline settings" > "${bashConfigDir}/inputrc"
          $DRY_RUN_CMD echo "set completion-ignore-case on" >> "${bashConfigDir}/inputrc"
          $DRY_RUN_CMD echo "set show-all-if-ambiguous on" >> "${bashConfigDir}/inputrc"
          $DRY_RUN_CMD echo "set show-all-if-unmodified on" >> "${bashConfigDir}/inputrc"
        fi
        if [ ! -f "${bashConfigDir}/conf.d/example.sh" ]; then
          $DRY_RUN_CMD echo "# Add your custom Bash configurations here" > "${bashConfigDir}/conf.d/example.sh"
          $DRY_RUN_CMD echo "# This file will be automatically sourced by .bashrc" >> "${bashConfigDir}/conf.d/example.sh"
        fi
        if [ ! -f "${bashDataDir}/history" ]; then
          $DRY_RUN_CMD touch "${bashDataDir}/history"
          $DRY_RUN_CMD chmod 600 "${bashDataDir}/history"
        fi
      '';
    }
  ]);
}
