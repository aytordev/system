{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.aytordev.tools.homebrew;
in {
  options.aytordev.tools.homebrew = {
    enable = mkEnableOption "Homebrew package manager";
    masEnable = lib.mkEnableOption "Mac App Store downloads";
  };
  config = mkIf cfg.enable {
    environment.variables = {
      HOMEBREW_BAT = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };
    homebrew = {
      enable = true;
      global = {
        brewfile = true;
        autoUpdate = true;
      };
      greedyCasks = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
        upgrade = true;
      };
      taps = [
      ];
    };
  };
}
