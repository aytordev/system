{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.lsd;

  aliases = {
    ls = "${lib.getExe cfg.package} -al";
    lt = "${lib.getExe cfg.package} --tree";
    llt = "${lib.getExe cfg.package} -l --tree";
  };
in {
  options.aytordev.programs.terminal.tools.lsd = {
    enable = lib.mkEnableOption "lsd";
    package = lib.mkPackageOption pkgs "lsd" {};
  };

  config = mkIf cfg.enable {
    home.shellAliases = aliases;

    programs.lsd = {
      enable = true;
      inherit (cfg) package;

      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;

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
  };
}
