{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.suites.business;
in {
  options.aytordev.suites.business = {
    enable = lib.mkEnableOption "business configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "bitwarden"
        "obsidian"
        "protonvpn"
      ];

      masApps = mkIf config.aytordev.tools.homebrew.masEnable {
        # TODO: Add Mac App Store apps
      };
    };
  };
}
