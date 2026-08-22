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
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [warp-terminal];

    xdg.configFile."warp/themes".source = ./themes;
  };
}
