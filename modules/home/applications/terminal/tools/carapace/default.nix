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
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    programs.zsh.initContent = ''
      if [ -n "$ZSH_VERSION" ]; then
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
        if [[ $- == *i* ]]; then
          if command -v carapace >/dev/null 2>&1; then
            eval "$(carapace _carapace | sed 's/^compdef /compdef -e /')"
          fi
        fi
      fi
      zstyle ':completion:*' format '%F{8}%d%f'
      zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
    '';
    home.file.".config/bash/conf.d/carapace.sh".text = ''
      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
      source <(carapace _carapace)
    '';
  };
}
