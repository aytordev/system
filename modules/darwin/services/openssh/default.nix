{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.aytordev.services.openssh;
in {
  options.aytordev.services.openssh = {
    enable = mkEnableOption "OpenSSH service";
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Public keys permitted to authenticate as the primary user.";
    };
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
    assertions = [
      {
        assertion = cfg.authorizedKeys != [];
        message = "aytordev.services.openssh requires at least one authorized key";
      }
    ];

    environment.systemPackages = [pkgs.openssh];
    services.openssh = {
      enable = true;
      extraConfig = ''
        AuthenticationMethods publickey
        KbdInteractiveAuthentication no
        LoginGraceTime 30
        MaxAuthTries 3
        PasswordAuthentication no
        PermitEmptyPasswords no
        PermitRootLogin no
        PubkeyAuthentication yes
        X11Forwarding no
        ${cfg.extraConfig}
      '';
    };

    users.users.${config.aytordev.user.name}.openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
