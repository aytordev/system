{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.aytordev.programs.terminal.tools.carapace;
in {
  options.aytordev.programs.terminal.tools.carapace = {
    enable = mkEnableOption "carapace - multi-shell command argument completer";
    package = lib.mkPackageOption pkgs "carapace" {};
  };
  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
    # Upstream programs.carapace owns every shell's init.
    programs.carapace = {
      enable = true;
      inherit (cfg) package;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
