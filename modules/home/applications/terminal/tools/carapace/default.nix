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
      enableZshIntegration = false; # Prefer fzf-tab plugin
      enableNushellIntegration = true;
    };

    programs.zsh.initContent = ''
      # Carapace shell integration
      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
      
      # Custom completion formatting
      zstyle ':completion:*' format '%F{8}%d%f'
      zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
    '';
  };
}
