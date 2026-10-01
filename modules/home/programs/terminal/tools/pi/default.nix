{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.pi;
in {
  imports = [
    ./provider.nix
    ./startup-header.nix
    ./agent-profiles.nix
    ./gui-environment.nix
  ];

  options.aytordev.programs.terminal.tools.pi = {
    enable = mkEnableOption "Pi coding agent";
    package = mkPackageOption pkgs "pi-coding-agent" {};

    # Contained GUI adapter (Darwin only); see gui-environment.nix/README.md.
    guiEnvironment = {
      enable = mkEnableOption ''
        publishing the Gentle Pi subagent command override into the user's GUI
        login launchd context
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
