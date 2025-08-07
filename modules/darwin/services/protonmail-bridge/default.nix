{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.darwin.services.protonmail-bridge;
in {
  options.darwin.services.protonmail-bridge = {
    enable = mkEnableOption "ProtonMail Bridge";

    username = mkOption {
      type = types.str;
      default = "";
      description = "[DEPRECATED] ProtonMail username/email. Use usernameFile with sops-nix instead.";
    };

    password = mkOption {
      type = types.str;
      default = "";
      description = "[DEPRECATED] ProtonMail password. Use passwordFile with sops-nix instead.";
    };

    usernameFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing the ProtonMail username/email (recommended: use sops-nix).";
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing the ProtonMail password (recommended: use sops-nix).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.protonmail-bridge];

    # Service configuration
    launchd.user.agents.protonmail-bridge = {
      serviceConfig = {
        ProgramArguments =
          [
            "${pkgs.protonmail-bridge}/bin/protonmail-bridge"
            "--noninteractive"
          ]
          ++ (
            if cfg.usernameFile != null
            then ["--username-file" cfg.usernameFile]
            else if cfg.username != ""
            then ["--username" cfg.username]
            else []
          )
          ++ (
            if cfg.passwordFile != null
            then ["--password-file" cfg.passwordFile]
            else if cfg.password != ""
            then ["--password" cfg.password]
            else []
          );
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        StandardOutPath = "/tmp/protonmail-bridge.log";
        StandardErrorPath = "/tmp/protonmail-bridge-error.log";
      };
    };
  };
}
