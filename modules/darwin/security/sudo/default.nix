{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.aytordev.security.sudo;
in {
  options.aytordev.security.sudo = {
    enable = mkEnableOption "sudo configuration with Touch ID support";
  };
  config = mkIf cfg.enable {
    security = {
      pam.services = {
        sudo_local = {
          reattach = true;
          touchIdAuth = true;
        };
      };
      sudo.extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults env_keep += "HOME"
        Defaults env_keep += "PATH"
        Defaults env_keep += "SSH_AUTH_SOCK"
      '';
    };
  };
}
