{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.darwin.services.openssh;
in {
  options.darwin.services.openssh = {
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
  config = {
    environment.systemPackages = [pkgs.openssh];
    services.openssh = {
      enable = true;
      extraConfig = cfg.extraConfig;
    };
  };
}
