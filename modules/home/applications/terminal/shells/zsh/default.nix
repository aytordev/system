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

        # Enhanced completion configuration
        enableCompletion = true;
        autosuggestion.enable = true;
        
        # Completion cache in XDG cache directory
        completionInit = ''
          # Initialize completion system
          autoload -Uz compinit
          
          # Completion cache settings
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ${xdgCacheHome}/zsh/zcompcache
          
          # Load completion system and compinit
          zmodload zsh/complist
          
          # Initialize completion system with dump file in XDG cache
          compinit -d ${xdgCacheHome}/zsh/zcompdump
          
          # Load and initialize completion system with compinit
          autoload -Uz compinit && compinit -i -d ${xdgCacheHome}/zsh/zcompdump
          
          # Load bash completion compatibility
          autoload -Uz bashcompinit && bashcompinit
          
          # Menu selection for completions
          zstyle ':completion:*' menu select
          
          # Group matches and describe
          zstyle ':completion:*' group-name '''
          zstyle ':completion:*:descriptions' format ' %F{green}-- %d --%f'
          
          # Case-insensitive (all), partial-word, and then substring completion
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
          
          # Use caching for commands that are slow
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ${xdgCacheHome}/zsh/zcompcache
        '';
      };

      # Required packages
      home.packages = with pkgs; [
        zsh
      ];
      
      # Zsh plugins and completions
      programs.zsh = {
        # Enable completions from all installed packages
        initContent = ''
          # Add completion directories to fpath
          fpath=(
            ${pkgs.zsh-completions}/share/zsh/site-functions
            ${pkgs.nix-zsh-completions}/share/zsh/site-functions
            $fpath
          )
        '';
      };

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
