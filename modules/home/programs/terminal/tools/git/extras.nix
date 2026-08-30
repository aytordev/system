{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
  cfg = config.aytordev.programs.terminal.tools.git;
  gitPackages = with pkgs; [
    git-absorb
    git-filter-repo
    git-lfs
    gitflow
    gitleaks
    gitlint
    tig
  ];
in {
  config = lib.mkIf cfg.enable {
    home.packages = gitPackages;
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          dark = true;
          features = mkForce "decorations side-by-side navigate";
          plus-style = "syntax #2B3328";
          minus-style = "syntax #3C2C2E";
          plus-emph-style = "syntax #76946a";
          minus-emph-style = "syntax #c34043";
          line-numbers = true;
          navigate = true;
          side-by-side = true;
        };
      };
      difftastic = {
        git = {
          enable = true;
          mode = "both";
        };
        options = {
          background = "dark";
          display = "inline";
        };
      };
      mergiraf = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
      };
    };
  };
}
