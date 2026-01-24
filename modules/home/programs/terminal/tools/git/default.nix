{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkOption;
  cfg = config.aytordev.programs.terminal.tools.git;
  aliases = import ./aliases.nix {inherit lib;};
  ignores = import ./git-ignore.nix;
  shell-aliases = import ./shell-aliases.nix {inherit config lib pkgs;};
  gitPackages = with pkgs; [
    git-absorb
    git-filter-repo
    git-lfs
    gitflow
    gitleaks
    gitlint
    tig
  ];
  gitConfig = {
    enable = true;
    package = pkgs.git;
    ignores = ignores;
    maintenance.enable = true;
    settings = {
      alias = aliases;
      user = {
        name = inputs.secrets.username;
        email = inputs.secrets.useremail;
      };
      branch.sort = "-committerdate";
      core.editor = "nano";
      useHttpPath.enable = true;
      fetch.prune = true;
      init.defaultBranch = "main";
      lfs.enable = true;
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      rerere.enabled = true;
      rebase.autostash = true;
      safe.directory = [
        "/Users/${inputs.secrets.username}/"
        "/etc/nixos"
        "/etc/nix-darwin"
      ];
    };
    signing = {
      key = cfg.signingKey;
      format = "ssh";
      inherit (cfg) signByDefault;
    };
  };
in {
  options.aytordev.programs.terminal.tools.git = {
    enable =
      mkEnableOption "Git configuration"
      // {
        description = ''
          Whether to enable the Git configuration module.
          This includes Git itself, common tools, and configuration.
        '';
      };
    signingKey = mkOption {
      type = with lib.types; nullOr (either str path);
      default = null;
      description = ''
        Path to the SSH private key used for signing Git commits and tags.
        Set to `null` to disable signing.
      '';
      example = "~/.ssh/id_ed25519";
    };
    signByDefault = mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to automatically sign all Git commits by default.
        When enabled, you won't need to use the -S flag with git commit.
      '';
    };
  };
  config = let
    cfg = config.aytordev.programs.terminal.tools.git;
    bashConfigDir = "${config.xdg.configHome}/bash/conf.d";
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        home.packages = gitPackages;
        programs = {
          git = gitConfig;
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
            git.diffToolMode = true;
            options = {
              background = "dark";
              display = "inline";
            };
          };
          mergiraf.enable = true;
        };
      }
      (lib.mkIf (shell-aliases.allAliases != {}) {
        home.file."${bashConfigDir}/git-aliases.sh" = {
          text = shell-aliases.generateGitAliasesFile shell-aliases.allAliases;
          executable = true;
        };
        home.shellAliases = shell-aliases.allAliases;
      })
    ]);
}
