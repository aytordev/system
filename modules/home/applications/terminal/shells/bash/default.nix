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
          
          # Ensure directories exist
          mkdir -p "$BASH_CONFIG_DIR/conf.d"
          mkdir -p "$BASH_DATA_DIR"
          mkdir -p "$BASH_CACHE_DIR"
          
          # History configuration
          export HISTFILE="$BASH_DATA_DIR/history"
          export HISTSIZE=10000
          export HISTFILESIZE=100000
          export HISTCONTROL=ignoredups:erasedups
          shopt -s histappend
          
          # Shell options
          shopt -s checkwinsize
          shopt -s extglob
          shopt -s globstar
          shopt -s checkjobs
          shopt -s autocd
          shopt -s cdspell
          shopt -s dirspell
          shopt -s nocaseglob
          
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
          
          # Git prompt
          if [ -f ${pkgs.git}/share/git/contrib/completion/git-prompt.sh ]; then
            . ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
            GIT_PS1_SHOWDIRTYSTATE=1
            GIT_PS1_SHOWUNTRACKEDFILES=1
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\n\\$ '
          else
            PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\\$ '
          fi
          
          # fzf configuration
          if [ -n "$(command -v fzf)" ]; then
            # Source fzf key bindings and completion
            for file in "${pkgs.fzf}/share/fzf/"{key-bindings,completion}.bash; do
              [ -f "$file" ] && . "$file"
            done
            
            # Use fd for fzf
            if [ -n "$(command -v fd)" ]; then
              export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
              
              _fzf_compgen_path() {
                fd --hidden --follow --exclude .git . "$1"
              }
              
              _fzf_compgen_dir() {
                fd --type d --hidden --follow --exclude .git . "$1"
              }
            fi
          fi
          
          # zoxide initialization
          if [ -n "$(command -v zoxide)" ]; then
            eval "$(zoxide init bash --cmd cd --no-aliases)"
          fi
          
          # Starship prompt
          if [ -n "$(command -v starship)" ]; then
            export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/config.toml"
            export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
            mkdir -p "$STARSHIP_CACHE"
            eval "$(starship init bash)"
          fi
          
          # Source additional configs from conf.d if they exist
          for f in "$BASH_CONFIG_DIR/conf.d/"*.sh; do
            [ -f "$f" ] && . "$f"
          done
        '';
      };
      
      # Create minimal stubs in $HOME that source our XDG config
      home.file.".bashrc" = {
        force = true;  # Force overwrite any existing file
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
        $DRY_RUN_CMD mkdir -p "${xdgDataHome}/bash"
        $DRY_RUN_CMD mkdir -p "${xdgCacheHome}/bash"
        
        # Set secure permissions
        $DRY_RUN_CMD chmod 700 "${xdgConfigHome}/bash"
        $DRY_RUN_CMD chmod 700 "${xdgDataHome}/bash"
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
