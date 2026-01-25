{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.aytordev.services.jankyborders;
  userHome = config.users.users.${config.aytordev.user.name}.home;
in {
  options.aytordev.services.jankyborders = {
    enable = lib.mkEnableOption "jankyborders log rotation";

    logPath = mkOption {
      type = types.str;
      default = "${userHome}/Library/Logs/jankyborders.log";
      description = "Path to jankyborders log file";
    };
  };

  config = mkIf cfg.enable {
    aytordev.system.newsyslog.files.jankyborders = [
      {
        logfilename = cfg.logPath;
        mode = "644";
        owner = config.aytordev.user.name;
        group = "staff";
        count = 7;
        size = "2048";
        flags = [
          "Z"
          "C"
        ];
      }
    ];
  };
}
