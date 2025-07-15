{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  options.applications.terminal.tools.lazygit = {
    enable = lib.mkEnableOption "lazygit";
  };

  config = lib.mkIf config.applications.terminal.tools.lazygit.enable {
    home.packages = with pkgs; [
      lazygit
    ];

    programs.lazygit = {
      enable = true;

      settings = {
        gui = {
          authorColors = {
            "${inputs.secrets.userfullname}" = "#c6a0f6";
            "dependabot[bot]" = "#eed49f";
          };
          branchColors = {
            main = "#ed8796";
            master = "#ed8796";
            dev = "#8bd5ca";
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
