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
    idempotentActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install declared entries without updating or upgrading existing Homebrew packages.";
    };
  };
  config = mkIf cfg.enable {
    environment.variables = {
      HOMEBREW_BAT = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };
    homebrew = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      global = {
        brewfile = true;
        autoUpdate = true;
      };
      greedyCasks = true;
      onActivation = {
        autoUpdate = !cfg.idempotentActivation;
        cleanup = "uninstall";
        upgrade = !cfg.idempotentActivation;
      };
      taps = [
      ];
    };
  };
}
