{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  options.aytordev.programs.terminal.tools.lazygit = {
    enable = lib.mkEnableOption "lazygit";
  };
  config = lib.mkIf config.aytordev.programs.terminal.tools.lazygit.enable {
    home.packages = with pkgs; [
      lazygit
    ];
    programs.lazygit = {
      enable = true;
      settings = {
        customCommands = import ./custom-commands.nix;
        gui = {
          authorColors = {
            "${inputs.secrets.userfullname}" = "#957fb8";
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
