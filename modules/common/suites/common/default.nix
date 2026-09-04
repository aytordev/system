{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;

  cfg = config.aytordev.suites.common;
in {
  options.aytordev.suites.common = {
    enable = mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkDefault [
      pkgs.coreutils
      pkgs.curl
      pkgs.fd
      pkgs.file
      pkgs.findutils
      pkgs.killall
      pkgs.lsof
      pkgs.tldr
      pkgs.unzip
      pkgs.wget
    ];
  };
}
