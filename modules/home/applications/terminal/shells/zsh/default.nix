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
      # Zsh packages
      home.packages = with pkgs; [
        zsh
        zsh-completions
        nix-zsh-completions
      ];

      # Zsh configuration
      programs.zsh = {
        enable = true;

        # XDG Base Directory compliance
        dotDir = ".config/zsh";
        enableCompletion = true;
        enableVteIntegration = true;
        
        # Enable autosuggestions with the new format
        autosuggestion.enable = true;

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

        # Completion system initialization
        completionInit = ''
          # Initialize completion system
          autoload -Uz compinit
          compinit -d ${xdgCacheHome}/zsh/zcompdump-$ZSH_VERSION
          
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
        
        # Additional initialization code
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
