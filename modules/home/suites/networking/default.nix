{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.suites.networking;
in {
  options.aytordev.suites.networking = {
    enable = lib.mkEnableOption "networking configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nmap
      openssh
      speedtest-cli
      ssh-copy-id
    ];
  };
}
