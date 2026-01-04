{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.aytordev.services.protonmail-bridge;
in {
  options.aytordev.services.protonmail-bridge = {
    enable = mkEnableOption "ProtonMail Bridge";

    # Note: ProtonMail Bridge does not support automatic authentication via command-line arguments.
    # The bridge must be configured interactively first using:
    # 1. Run `protonmail-bridge` without --noninteractive
    # 2. Login with your ProtonMail credentials
    # 3. Configure mail client settings
    # After initial setup, the service can run with --noninteractive

    logLevel = mkOption {
      type = types.enum ["panic" "fatal" "error" "warn" "info" "debug"];
      default = "info";
      description = "Set the log level for ProtonMail Bridge";
    };

    enableGrpc = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the gRPC service for programmatic control";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.protonmail-bridge];

    # Service configuration
    # IMPORTANT: ProtonMail Bridge must be configured interactively before this service will work.
    # Run `protonmail-bridge` manually first to login and set up your account.
    launchd.user.agents.protonmail-bridge = {
      serviceConfig = {
        ProgramArguments =
          [
            "${pkgs.protonmail-bridge}/bin/protonmail-bridge"
            "--noninteractive"
            "--log-level"
            cfg.logLevel
          ]
          ++ (
            if cfg.enableGrpc
            then ["--grpc"]
            else []
          );
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        StandardOutPath = "/tmp/protonmail-bridge.log";
        StandardErrorPath = "/tmp/protonmail-bridge-error.log";
        EnvironmentVariables = {
          # ProtonMail Bridge stores its configuration in ~/.config/protonmail/bridge-v3
          HOME = "/Users/${config.system.primaryUser}";
        };
      };
    };
  };
}
