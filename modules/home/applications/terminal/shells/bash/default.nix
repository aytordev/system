{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.shells.bash;
  xdgConfigHome = "${config.xdg.configHome}";
  xdgDataHome = "${config.xdg.dataHome}";
  xdgCacheHome = "${config.xdg.cacheHome}";
in {
  options.applications.terminal.shells.bash = {
    enable = mkEnableOption "Bash shell with useful defaults";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        bash-completion
        nix-bash-completions
        # Add bash here since we're not using programs.bash.enable
        bash
      ];

      # Disable the default bash module to prevent it from generating .bashrc
      programs.bash.enable = false;

      # Create the main .bashrc file in XDG config with all configurations
      home.file.".config/bash/.bashrc" = {
        text = ''
          # This file is managed by NixOS/Home Manager
          # All Bash configuration is centralized here for XDG compliance

          # Set up XDG directories
          export XDG_CONFIG_HOME="${xdgConfigHome}"
          export XDG_DATA_HOME="${xdgDataHome}"
          export XDG_CACHE_HOME="${xdgCacheHome}"

          # Set up Bash specific directories
          export BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"
          export BASH_DATA_DIR="$XDG_DATA_HOME/bash"
          export BASH_CACHE_DIR="$XDG_CACHE_HOME/bash"
          export BASH_SESSION_DIR="$BASH_DATA_DIR/sessions"

          # History configuration
          export HISTFILE="$BASH_DATA_DIR/history"
          export HISTSIZE=10000
          export HISTFILESIZE=100000
          export HISTCONTROL=ignoredups:erasedups
          shopt -s histappend

          # Shell options
          shopt -s checkwinsize extglob globstar checkjobs autocd cdspell dirspell nocaseglob

          # Set inputrc location
          export INPUTRC="$BASH_CONFIG_DIR/inputrc"

          # Source system-wide bashrc if it exists
          [ -f /etc/bashrc ] && . /etc/bashrc

          # Enable programmable completion
          if ! shopt -oq posix; then
            if [ -f /usr/share/bash-completion/bash_completion ]; then
              . /usr/share/bash-completion/bash_completion
            elif [ -f /etc/bash_completion ]; then
              . /etc/bash_completion
            fi
          fi

          # Load nix completions
          [ -f ${pkgs.nix-bash-completions}/share/bash-completion/completions/nix ] &&
            . ${pkgs.nix-bash-completions}/share/bash-completion/completions/nix

          # Source additional configs from conf.d if they exist
          for f in "$BASH_CONFIG_DIR/conf.d/"*.sh; do
            [ -f "$f" ] && . "$f"
          done

          # For macOS Terminal.app session restoration
          if [ "$(uname -s)" = "Darwin" ] && [ -n "$TERM_SESSION_ID" ]; then
            # Just ensure the symlink exists (handled by home.activation)
            :
          fi
        '';
      };

      # Create minimal stubs in $HOME that source our XDG config
      home.file.".bashrc" = {
        force = true; # Force overwrite any existing file
        text = ''
          # This is a minimal .bashrc that sources the XDG config
          # All configuration is in ~/.config/bash/.bashrc

          # Source the main config if it exists
          [ -f "$HOME/.config/bash/.bashrc" ] && . "$HOME/.config/bash/.bashrc"
        '';
      };

      # For login shells (macOS Terminal, SSH, etc.)
      home.file.".bash_profile" = {
        force = true;
        text = ''
          # This is a minimal .bash_profile that sources the XDG config
          [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
        '';
      };

      # For POSIX-compliant login shells (fallback)
      home.file.".profile" = {
        force = true;
        text = ''
          # This is a minimal .profile that sources the XDG config
          [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
        '';
      };

      # Create necessary directories with proper permissions
      home.activation.bashDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Create XDG base directories
        $DRY_RUN_CMD mkdir -p "${xdgConfigHome}/bash/conf.d"
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/bash/sessions"  # Aseguramos que el directorio de sesiones exista
        $DRY_RUN_CMD mkdir -p "${xdgCacheHome}/bash"

        # Set secure permissions
        $DRY_RUN_CMD chmod 700 "${xdgConfigHome}/bash"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/bash"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/bash/sessions"  # Aseguramos permisos correctos

        # Handle macOS Terminal.app session directory
        if [ "$(uname -s)" = "Darwin" ]; then
          OLD_SESSION_DIR="$HOME/.bash_sessions"

          # If old session dir exists and is not a symlink, back it up
          if [ -d "$OLD_SESSION_DIR" ] && [ ! -L "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD echo "Moving existing bash_sessions to XDG directory..."
            $DRY_RUN_CMD mv "$OLD_SESSION_DIR" "$OLD_SESSION_DIR.bak"
          fi

          # Create symlink if it doesn't exist
          if [ ! -e "$OLD_SESSION_DIR" ]; then
            $DRY_RUN_CMD ln -sf "${xdgDataHome}/bash/sessions" "$OLD_SESSION_DIR"
          fi
        fi
        $DRY_RUN_CMD chmod 700 "${xdgCacheHome}/bash"

        # Create a sample inputrc if it doesn't exist
        if [ ! -f "${xdgConfigHome}/bash/inputrc" ]; then
          $DRY_RUN_CMD echo "# Bash readline settings" > "${xdgConfigHome}/bash/inputrc"
          $DRY_RUN_CMD echo "set completion-ignore-case on" >> "${xdgConfigHome}/bash/inputrc"
          $DRY_RUN_CMD echo "set show-all-if-ambiguous on" >> "${xdgConfigHome}/bash/inputrc"
          $DRY_RUN_CMD echo "set show-all-if-unmodified on" >> "${xdgConfigHome}/bash/inputrc"
        fi

        # Create a sample custom config if conf.d is empty
        if [ ! -f "${xdgConfigHome}/bash/conf.d/example.sh" ]; then
          $DRY_RUN_CMD echo "# Add your custom Bash configurations here" > "${xdgConfigHome}/bash/conf.d/example.sh"
          $DRY_RUN_CMD echo "# This file will be automatically sourced by .bashrc" >> "${xdgConfigHome}/bash/conf.d/example.sh"
        fi
      '';
    }
  ]);
}
