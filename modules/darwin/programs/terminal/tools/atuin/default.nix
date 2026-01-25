{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.aytordev.programs.terminal.tools.atuin;
  userHome = config.users.users.${config.aytordev.user.name}.home;
in {
  options.aytordev.programs.terminal.tools.atuin = {
    enable = lib.mkEnableOption "atuin log rotation";

    logPaths = {
      stdout = mkOption {
        type = types.str;
        default = "${userHome}/Library/Logs/atuin/atuin.out.log";
        description = "Path to atuin stdout log file";
      };

      stderr = mkOption {
        type = types.str;
        default = "${userHome}/Library/Logs/atuin/atuin.err.log";
        description = "Path to atuin stderr log file";
      };
    };
  };

  config = mkIf cfg.enable {
    aytordev.system.newsyslog.files.atuin-daemon = [
      {
        logfilename = cfg.logPaths.stdout;
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
      {
        logfilename = cfg.logPaths.stderr;
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
