{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.carapace;
in {
  options.applications.terminal.tools.carapace = {
    enable = mkEnableOption "carapace - multi-shell command argument completer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      carapace
    ];

    programs.carapace = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true; # Enable Zsh integration for completions
      enableNushellIntegration = true;
    };

    # Zsh integration with fzf-tab compatibility
    programs.zsh.initContent = ''
      # Carapace shell integration
      if [ -n "$ZSH_VERSION" ]; then
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

        # Only initialize carapace if we're in an interactive shell
        if [[ $- == *i* ]]; then
          # Source carapace completions if available
          if command -v carapace >/dev/null 2>&1; then
            # Use eval to properly handle the output of carapace _carapace
            eval "$(carapace _carapace | sed 's/^compdef /compdef -e /')"
          fi
        fi
      fi

      # Custom completion formatting
      zstyle ':completion:*' format '%F{8}%d%f'
      zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
    '';

    # Add carapace to bash configuration
    home.file.".config/bash/conf.d/carapace.sh".text = ''
      # Carapace shell integration for bash
      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
      source <(carapace _carapace)
    '';
  };
}
