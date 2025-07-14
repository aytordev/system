{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.darwin.tools.homebrew;
in {
  options.darwin.tools.homebrew = {
    enable = mkEnableOption "Homebrew package manager";
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
