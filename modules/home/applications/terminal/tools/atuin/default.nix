{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption optionalAttrs;

  cfg = config.applications.terminal.tools.atuin;
in
{
  options.applications.terminal.tools.atuin = {
    enable = mkEnableOption "atuin";
    enableDebug = mkEnableOption "atuin daemon debug logging";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;

      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;

      daemon =
        {
          enable = true;
        }
        // optionalAttrs cfg.enableDebug {
          logLevel = "debug";
        };

      # flags = [
      #   "--disable-up-arrow"
      # ];

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
  };
}
