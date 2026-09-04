{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.lsd;
in {
  options.aytordev.programs.terminal.tools.lsd = {
    enable = mkEnableOption "lsd";
    package = mkPackageOption pkgs "lsd" {};
  };
  config = mkIf cfg.enable (
    let
      si = lib.aytordev.shellIntegration config;
    in {
      programs.lsd = {
        enable = true;
        inherit (cfg) package;
        inherit (si.flags) enableBashIntegration enableFishIntegration enableZshIntegration;
        settings = {
          blocks = [
            "permission"
            "user"
            "group"
            "size"
            "date"
            "name"
          ];
          classic = false;
          date = "date";
          dereference = false;
          header = true;
          hyperlink = "auto";
          icons = {
            when = "auto";
            theme = "fancy";
            separator = " ";
          };
          ignore-globs = [".git"];
          indicators = true;
          layout = "grid";
          # permission = "octal";
          sorting = {
            column = "name";
            reverse = false;
            dir-grouping = "first";
          };
          symlink-arrow = "=>";
          # total-size = true;
        };
      };
      home.shellAliases.llt = "${lib.getExe cfg.package} -l --tree";
    }
  );
}
