{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.suites.music;
in {
  options.aytordev.suites.music = {
    enable = lib.mkEnableOption "music configuration";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "spotify"
      ];
      masApps = mkIf config.aytordev.tools.homebrew.masEnable {
        # TODO: Add Mac App Store apps
      };
    };
  };
}
