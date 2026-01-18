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
        };
        git = {
          overrideGpg = true;
        };
      };
    };
    home.shellAliases = {
      lg = "lazygit";
    };
    home.file.".config/bash/conf.d/lazygit.sh" = {
      text = ''
        if command -v lazygit &> /dev/null; then
          alias lg='lazygit'
        fi
      '';
      executable = true;
    };
  };
}
