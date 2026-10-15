{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.pi;
  theme = import ./theme.nix {
    inherit (config.aytordev.theme) palette isLight;
  };
  seedDefault = pkgs.writeShellApplication {
    name = "pi-theme-default";
    runtimeInputs = [pkgs.jq pkgs.coreutils];
    text = builtins.readFile ./theme-default.sh;
  };
in {
  config = lib.mkIf cfg.enable {
    # Own one leaf, not the themes directory or the mutable Pi profile.
    home.file.".pi/agent/themes/aytordev.json".text = builtins.toJSON theme;
    home.activation.piThemeDefault = lib.hm.dag.entryAfter ["linkGeneration"] ''
      $DRY_RUN_CMD ${lib.getExe seedDefault} "${config.home.homeDirectory}/.pi/agent/settings.json"
    '';
  };
}
