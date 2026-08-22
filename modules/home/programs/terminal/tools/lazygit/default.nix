{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aytordev.programs.terminal.tools.lazygit = {
    enable = lib.mkEnableOption "lazygit";
    package = lib.mkPackageOption pkgs "lazygit" {};
  };
  config = lib.mkIf config.aytordev.programs.terminal.tools.lazygit.enable {
    home.packages = [
      config.aytordev.programs.terminal.tools.lazygit.package
    ];
    programs.lazygit = {
      enable = true;
      package = config.aytordev.programs.terminal.tools.lazygit.package;
      settings = {
        customCommands = import ./custom-commands.nix;
        gui = {
          authorColors = {
            "${config.aytordev.user.fullName}" = "#957fb8";
            "dependabot[bot]" = "#c0a36e";
          };
          branchColors = {
            main = "#c34043";
            master = "#c34043";
            dev = "#7e9cd8";
          };
          nerdFontsVersion = "3";
          showListFooter = false;
          showRandomTip = false;
          expandFocusedSidePanel = true;
        };
        git = {
          overrideGpg = true;
          mainBranches = [
            "main"
            "master"
          ];
        };
        os = {
          editPreset = "nvim";
        };
      };
    };
    home.shellAliases = {
      lg = "lazygit";
    };
    xdg.configFile."bash/conf.d/lazygit.sh" = {
      text = ''
        if command -v lazygit &> /dev/null; then
          alias lg='lazygit'
        fi
      '';
      executable = true;
    };
  };
}
