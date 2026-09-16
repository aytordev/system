{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.aytordev) enabled;

  cfg = config.aytordev.suites.networking;
in {
  options.aytordev.suites.networking = {
    enable = lib.mkEnableOption "networking configuration";
  };

  config = mkIf cfg.enable {
    aytordev = {
      system = {
        networking = lib.mkDefault enabled;
      };
    };

    # OpenVPN's GUI client is not in nixpkgs, so it is installed via Homebrew
    # (like ProtonVPN). The provider's `.ovpn` profile is imported into it.
    homebrew.casks = ["openvpn-connect"];
  };
}
