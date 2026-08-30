{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.emulators.warp;
in {
  options.aytordev.programs.terminal.emulators.warp = {
    enable = lib.mkEnableOption "Warp terminal emulator";
    package = lib.mkPackageOption pkgs "warp-terminal" {};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."warp/themes".source = ./themes;
  };
}
