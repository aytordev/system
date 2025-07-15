{
  config,
  lib,
  pkgs,
  ...
}: {
  options.applications.terminal.emulators.warp = {
    enable = lib.mkEnableOption "Warp terminal emulator";
  };

  config = lib.mkIf config.applications.terminal.emulators.warp.enable {
    home.packages = with pkgs; [ warp-terminal ];
  };
}
