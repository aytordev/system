# Git configuration module
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce mkOption;

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

    maintenance.enable = true;

    delta.enable = true;
    delta.options.dark = true;
    # FIXME: module should accept a mergable list be composable
    delta.options.features = mkForce "decorations side-by-side navigate catppuccin-macchiato";
    delta.options.line-numbers = true;
    delta.options.navigate = true;
    delta.options.side-by-side = true;

    difftastic.enableAsDifftool = true;
    difftastic.background = "dark";
    difftastic.display = "inline";

    extraConfig.branch.sort = "-committerdate";
    extraConfig.useHttpPath.enable = true;
    extraConfig.fetch.prune = true;
    extraConfig.init.defaultBranch = "main";
    extraConfig.lfs.enable = true;
    extraConfig.pull.rebase = true;
    extraConfig.push.autoSetupRemote = true;
    extraConfig.push.default = "current";
    extraConfig.rerere.enabled = true;
    extraConfig.rebase.autostash = true;
    extraConfig.safe.directory = [
      "~/${inputs.secrets.username}/"
      "/etc/nixos"
      "/etc/nix-darwin"
    ];

    signing.key = cfg.signingKey;
    signing.format = "ssh";
    signing.signByDefault = cfg.signByDefault;
  };
in {
  options.applications.terminal.tools.git = {
    enable = mkEnableOption "Git configuration";

    # Configurable signing key
    signingKey = mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Path to the SSH private key for commit signing";
      example = "~/.ssh/id_ed25519";
    };

    # Whether to sign commits by default
    signByDefault = mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to sign commits by default";
    };
  };

  config = let
    cfg = config.applications.terminal.tools.git;
  in
    mkIf cfg.enable {
      home.packages = gitPackages;
      programs.git = gitConfig;
      programs.mergiraf.enable = true;
      home.shellAliases = shell-aliases;
    };
}
