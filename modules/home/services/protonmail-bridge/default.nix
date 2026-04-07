{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.aytordev.services.protonmail-bridge;

  # Bridge self-updater bug (root cause fixed by overlay):
  # The upstream Darwin updater resolves os.Executable() to a Nix store path,
  # walks up to /nix/store as the .app bundle root, and copies the entire
  # store (~15 GB) to $TMPDIR/proton-update-source{random}/ on every hourly
  # update check (~720 GB over 48 h). Fixed in overlays/protonmail-bridge by
  # replacing install_darwin.go with a no-op implementation.
  #
  # TMPDIR redirect below is defense-in-depth only: it contains any residual
  # writes to a bounded directory and enables the startup purge of legacy dirs.
  bridgeTmpDir = "${config.home.homeDirectory}/.local/state/protonmail-bridge/tmp";

  grpcFlag = lib.optional cfg.enableGrpc "--grpc";

  startScript = pkgs.writeShellScript "protonmail-bridge-start" ''
    /bin/wait4path /nix/store
    mkdir -p "${bridgeTmpDir}"
    # One-shot purge of any legacy proton-update-source* dirs accumulated
    # before the overlay fix. Safe to remove once all hosts are updated.
    rm -rf "${bridgeTmpDir}"/proton-update-source* 2>/dev/null || true

    export TMPDIR="${bridgeTmpDir}"
    export HOME="${config.home.homeDirectory}"
    exec ${pkgs.protonmail-bridge}/bin/protonmail-bridge \
      --noninteractive \
      --log-level ${cfg.logLevel} \
      ${lib.concatStringsSep " " grpcFlag}
  '';
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
    home.packages = [pkgs.protonmail-bridge];

    # Service configuration
    # IMPORTANT: ProtonMail Bridge must be configured interactively before this service will work.
    # Run `protonmail-bridge` manually first to login and set up your account.
    launchd.agents.protonmail-bridge = {
      enable = true;
      config = {
        ProgramArguments = ["/bin/sh" "-c" "exec ${startScript}"];
        KeepAlive = {SuccessfulExit = false;};
        RunAtLoad = true;
        ProcessType = "Background";
        # Throttle restarts to avoid rapid crash loops saturating disk
        ThrottleInterval = 30;
        StandardOutPath = "${config.xdg.cacheHome}/protonmail-bridge.log";
        StandardErrorPath = "${config.xdg.cacheHome}/protonmail-bridge-error.log";
      };
    };
  };
}
