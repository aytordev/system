# Git configuration module
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.terminal.tools.git;

  # Import submodules
  aliases = import ./aliases.nix {inherit lib;};

  # Import git ignore patterns
  ignores = import ./git-ignore.nix;

  # Import shell aliases
  shell-aliases = import ./shell-aliases.nix {inherit config lib pkgs;};

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

    # Import aliases directly
    aliases = aliases;

    # Include git ignore patterns
    ignores = ignores;

    # User configuration
    userName = inputs.secrets.username;
    userEmail = inputs.secrets.useremail;
  };
in {
  options.applications.terminal.tools.git = {
    enable = mkEnableOption "Git configuration";
  };

  config = mkIf cfg.enable {
    home.packages = gitPackages;
    programs.git = gitConfig;
    home.shellAliases = shell-aliases;
  };
}
