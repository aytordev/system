{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.aytordev.system.networking;
in {
  options.aytordev.system.networking = {
    enable = mkEnableOption "macOS networking";
  };

  config = mkIf cfg.enable {
    networking.knownNetworkServices = ["Wi-Fi" "Ethernet"];
    networking.dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    networking.applicationFirewall = {
      enable = true;
      blockAllIncoming = false;
      enableStealthMode = false;
    };
  };
}
