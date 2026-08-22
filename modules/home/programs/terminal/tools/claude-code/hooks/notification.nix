{
  lib,
  pkgs,
  ...
}: let
  notify = title: message:
    if pkgs.stdenv.hostPlatform.isDarwin
    then "${lib.getExe pkgs.terminal-notifier} -title ${lib.escapeShellArg title} -message ${lib.escapeShellArg message} -sender com.anthropic.claudecode -sound default"
    else "${lib.getExe' pkgs.libnotify "notify-send"} -a ${lib.escapeShellArg title} ${lib.escapeShellArg title} ${lib.escapeShellArg message}";
in {
  Notification = [
    {
      matcher = "";
      hooks = [
        {
          type = "command";
          command = notify "Claude Code" "Awaiting your input";
        }
      ];
    }
  ];
}
