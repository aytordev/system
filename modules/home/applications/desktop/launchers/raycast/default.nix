{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.applications.desktop.launchers.raycast;
in {
  options.applications.desktop.launchers.raycast = {
    enable = mkEnableOption "Raycast launcher";

    package = mkOption {
      type = types.package;
      default = pkgs.raycast;
      description = "The Raycast package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    # Raycast preferences can be configured here if needed
    # home.file.".raycast" = {
    #   source = ./raycast-config;
    #   recursive = true;
    # };
  };
}
