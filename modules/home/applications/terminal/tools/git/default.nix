# Git Configuration Module
#
# This module provides a comprehensive Git configuration with sensible defaults,
# including signing, delta/difftastic integration, and common aliases.
#
# ## Features
#
# - Git signing with configurable SSH key
# - Delta for beautiful diffs with syntax highlighting
# - Difftastic for semantic diffing
# - Common Git aliases and shell integration
# - Git LFS support
# - Maintenance tools (git-absorb, git-crypt, etc.)
#
# ## Example Configuration
#
# ```nix
# {
#   applications.terminal.tools.git = {
#     enable = true;
#     signingKey = "~/.ssh/id_ed25519";
#     signByDefault = true;
#   };
# }
# ```
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce mkOption;

  cfg = config.applications.terminal.tools.git;

  # Import Git aliases configuration
  # See: ./aliases.nix for the complete list of aliases
  aliases = import ./aliases.nix {inherit lib;};

  # Import global Git ignore patterns
  # These patterns will apply to all repositories unless overridden locally
  ignores = import ./git-ignore.nix;

  # Import Git-related shell aliases
  # These aliases are added to the user's shell environment
  shell-aliases = import ./shell-aliases.nix {inherit config lib pkgs;};

  # Git-related packages to be installed
  # These provide additional Git functionality and tools
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

  # Main Git configuration
  # This defines the complete Git configuration that will be generated
  gitConfig = {
    enable = true;
    package = pkgs.gitFull;

    # Import aliases directly
    aliases = aliases;

    # Include git ignore patterns
    ignores = ignores;

    # User identification
    # These values typically come from the system's secrets management
    userName = inputs.secrets.username;
    userEmail = inputs.secrets.useremail;

    # Enable Git maintenance for automatic repository optimization
    maintenance.enable = true;

    # Delta configuration for beautiful diffs
    # See: https://github.com/dandavison/delta
    delta.enable = true;
    delta.options.dark = true;
    # FIXME: This should be converted to use proper Nix types when the module is updated
    # See: https://github.com/nix-community/home-manager/issues/2064
    delta.options.features = mkForce "decorations side-by-side navigate catppuccin-macchiato";
    delta.options.line-numbers = true;
    delta.options.navigate = true;
    delta.options.side-by-side = true;

    # Difftastic configuration for semantic diffing
    # See: https://github.com/Wilfred/difftastic
    difftastic.enableAsDifftool = true;
    difftastic.background = "dark";
    difftastic.display = "inline";

    # Additional Git configuration
    extraConfig.branch.sort = "-committerdate";
    
    # Set default editor to nano
    extraConfig.core.editor = "nano";
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
      "/Users/${inputs.secrets.username}/"
      "/etc/nixos"
      "/etc/nix-darwin"
    ];

    # Git signing configuration
    signing.key = cfg.signingKey;
    signing.format = "ssh";
    signing.signByDefault = cfg.signByDefault;
  };
in {
  options.applications.terminal.tools.git = {
    enable =
      mkEnableOption "Git configuration"
      // {
        description = ''
          Whether to enable the Git configuration module.
          This includes Git itself, common tools, and configuration.
        '';
      };

    # SSH key used for commit/tag signing
    #
    # Type: null or string (path)
    #
    # Example:
    #   signingKey = "~/.ssh/id_ed25519";
    signingKey = mkOption {
      type = with lib.types; nullOr (either str path);
      default = null;
      description = ''
        Path to the SSH private key used for signing Git commits and tags.
        Set to `null` to disable signing.
      '';
      example = "~/.ssh/id_ed25519";
    };

    # Whether to sign all commits by default
    #
    # Type: boolean
    # Default: true
    #
    # Example:
    #   signByDefault = true;  # Sign all commits by default
    signByDefault = mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically sign all Git commits by default.
        When enabled, you won't need to use the -S flag with git commit.
      '';
    };
  };

  # Module implementation
  config = let
    cfg = config.applications.terminal.tools.git;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      # Base configuration
      {
        # Install Git packages
        home.packages = gitPackages;

        # Main Git configuration
        programs.git = gitConfig;

        # Shell aliases for Git
        home.shellAliases = shell-aliases;

        # Mergiraf configuration (Git merge conflict resolution tool)
        programs.mergiraf.enable = true;
      }
    ]);
}
