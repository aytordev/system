{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optionalAttrs;
  cfg = config.aytordev.applications.terminal.tools.atuin;
in {
  options.aytordev.applications.terminal.tools.atuin = {
    enable = mkEnableOption "atuin";
    enableDebug = mkEnableOption "atuin daemon debug logging";
    enableBashIntegration = mkEnableOption "atuin bash integration";
    enableFishIntegration = mkEnableOption "atuin fish integration";
    enableZshIntegration = mkEnableOption "atuin zsh integration";
    enableNushellIntegration = mkEnableOption "atuin nushell integration";
  };
  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableBashIntegration = cfg.enableBashIntegration;
      enableFishIntegration = cfg.enableFishIntegration;
      enableZshIntegration = cfg.enableZshIntegration;
      enableNushellIntegration = cfg.enableNushellIntegration;
      daemon =
        {
          enable = true;
        }
        // optionalAttrs cfg.enableDebug {
          logLevel = "debug";
        };
      settings = {
        enter_accept = true;
        filter_mode = "workspace";
        keymap_mode = "auto";
        show_preview = true;
        style = "auto";
        update_check = false;
        workspaces = true;
        history_filter = [
          "^(sudo reboot)$"
          "^(reboot)$"
        ];
      };
    };
    home.file.".config/bash/conf.d/atuin.sh" = lib.mkIf cfg.enableBashIntegration {
      text = ''
        eval "$(atuin init bash)"
      '';
    };
  };
}
