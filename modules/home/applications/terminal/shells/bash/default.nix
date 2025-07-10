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
      ];
      
      # Enable fzf (configured in tools/fzf)

      programs.bash = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;

        # XDG Base Directory compliance
        profileExtra = ''
          # Set up XDG directories
          export XDG_CONFIG_HOME="${xdgConfigHome}"
          export XDG_DATA_HOME="${xdgDataHome}"
          export XDG_CACHE_HOME="${xdgCacheHome}"
          
          # Ensure directories exist
          mkdir -p "$XDG_CACHE_HOME/bash"
          mkdir -p "$XDG_DATA_HOME/bash"
          
          # Set history file location
          export HISTFILE="$XDG_DATA_HOME/bash/history"
          export HISTSIZE=10000
          export HISTFILESIZE=10000
          export HISTCONTROL=ignoredups:erasedups
          
          # Append to history file, don't overwrite it
          shopt -s histappend
          
          # Update LINES and COLUMNS after each command
          shopt -s checkwinsize
        '';

        # Shell options and completions
        bashrcExtra = ''
          # Source system-wide bashrc if it exists
          if [ -f /etc/bashrc ]; then
            . /etc/bashrc
          fi
          
          # Enable programmable completion features
          if ! shopt -oq posix; then
            if [ -f /usr/share/bash-completion/bash_completion ]; then
              . /usr/share/bash-completion/bash_completion
            elif [ -f /etc/bash_completion ]; then
              . /etc/bash_completion
            fi
          fi
          
          # Load nix completions
          if [ -f ${pkgs.nix-bash-completions}/share/bash-completion/completions/nix ]; then
            . ${pkgs.nix-bash-completions}/share/bash-completion/completions/nix
          fi
          
          # Custom prompt with git support
          if [ -f ${pkgs.git}/share/git/contrib/completion/git-prompt.sh ]; then
            . ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
            GIT_PS1_SHOWDIRTYSTATE=1
            GIT_PS1_SHOWUNTRACKEDFILES=1
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\n\\$ '
          else
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\\$ '
          fi
          
          # Better directory navigation
          shopt -s autocd
          shopt -s cdspell
          shopt -s dirspell
          
          # Case-insensitive globbing
          shopt -s nocaseglob
          
          # Enable ** pattern
          shopt -s globstar
          
          # fzf configuration is managed by tools/fzf module
        '';
      };

      # Create necessary directories
      home.activation.bashDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/bash"
        $DRY_RUN_CMD mkdir -p "${xdgCacheHome}/bash"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/bash"
      '';
    }
  ]);
}
