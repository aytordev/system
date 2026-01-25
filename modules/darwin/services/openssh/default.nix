{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.aytordev.services.openssh;
in {
  options.aytordev.services.openssh = {
    enable = mkEnableOption "OpenSSH service";
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional configuration text appended to the end of the
        sshd_config file. This can be used to add configuration options
        not explicitly supported by this module.
      '';
      example = ''
        Match User admin
          X11Forwarding yes
        Match all
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.openssh];
    services.openssh = {
      enable = true;
      inherit (cfg) extraConfig;
    };
  };
}
