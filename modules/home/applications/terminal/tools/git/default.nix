# Git configuration module
{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.terminal.tools.git;

  # Common Git packages
  gitPackages = with pkgs; [
    git-absorb
    git-crypt
    git-filter-repo
    git-lfs
    gitflow
    gitleaks
    gitlint
    tig
  ];

  # Git configuration
  gitConfig = {
    enable = true;
    package = pkgs.gitFull;

    userName = inputs.secrets.username;
    userEmail = inputs.secrets.useremail;
  };

in {
  options.applications.terminal.tools.git = {
    enable = mkEnableOption "Git configuration";
  };

  config = mkIf cfg.enable {
    home.packages = gitPackages;
    
    programs = {
      git = gitConfig;
    };
  };
}
