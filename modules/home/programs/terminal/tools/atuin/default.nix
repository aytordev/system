{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optionalAttrs;
  cfg = config.aytordev.programs.terminal.tools.atuin;
in {
  options.aytordev.programs.terminal.tools.atuin = {
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
      inherit (cfg) enableBashIntegration;
      inherit (cfg) enableFishIntegration;
      inherit (cfg) enableZshIntegration;
      inherit (cfg) enableNushellIntegration;
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
