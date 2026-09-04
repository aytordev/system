{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.ripgrep;
in {
  options.aytordev.programs.terminal.tools.ripgrep = {
    enable = lib.mkEnableOption "ripgrep";
    package = lib.mkPackageOption pkgs "ripgrep" {};
  };
  config = lib.mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
      inherit (cfg) package;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
    home.shellAliases = {
      grep = "${cfg.package}/bin/rg";
    };
    # grep -> rg reaches all shells via home.shellAliases; the conf.d only
    # carries the bash-only env export.
    xdg.configFile."bash/conf.d/ripgrep.sh" =
      (lib.aytordev.shellIntegration config).whenShellEnabled "bash"
      {
        text = ''
          export RIPGREP_CONFIG_PATH="${cfg.package}/share/ripgreprc"
        '';
      };
  };
}
