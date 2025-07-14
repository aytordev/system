{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.applications.terminal.tools.eza;
in {
  options.applications.terminal.tools.eza = {
    enable = mkEnableOption "eza";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      package = pkgs.eza;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;

      extraOptions = [
        "--group-directories-first"
        "--header"
        "--hyperlink"
        "--follow-symlinks"
      ];

      git = true;
      icons = "auto";
    };

    home.shellAliases = {
      la = mkForce "${getExe config.programs.eza.package} -lah --tree";
      tree = mkForce "${getExe config.programs.eza.package} --tree --icons=always";
    };

    home.packages = with pkgs; [ eza ];
  };
}
