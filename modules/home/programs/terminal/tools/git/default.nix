{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.aytordev.programs.terminal.tools.git;
  aliases = import ./aliases.nix {inherit lib;};
  ignores = import ./git-ignore.nix;
  shell-aliases = import ./shell-aliases.nix {inherit config lib pkgs;};
  gitConfig =
    {
      enable = true;
      inherit (cfg) package;
      inherit ignores;
      maintenance.enable = true;
      settings = {
        alias = aliases;
        user = {
          name = config.aytordev.user.fullName;
          inherit (config.aytordev.user) email;
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
        credential.helper =
          if pkgs.stdenv.hostPlatform.isDarwin
          then "osxkeychain"
          else "${cfg.package}/libexec/git-core/git-credential-libsecret";
        safe.directory = [
          config.home.homeDirectory
          "/etc/nixos"
          "/etc/nix-darwin"
        ];
      };
    }
    // lib.optionalAttrs cfg.signing.enable {
      signing = {
        inherit (cfg.signing) key;
        format = "ssh";
        signByDefault = true;
      };
    };
in {
  imports = [./extras.nix];

  options.aytordev.programs.terminal.tools.git = {
    enable =
      mkEnableOption "Git configuration"
      // {
        description = ''
          Whether to enable the Git configuration module.
          This includes Git itself, common tools, and configuration.
        '';
      };
    package = lib.mkPackageOption pkgs "Git" {
      default = "gitFull";
    };
    signing = {
      enable = mkEnableOption "SSH signing for Git commits and tags";
      key = mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the SSH private key used for signing Git commits and tags.";
        example = "~/.ssh/id_ed25519";
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !cfg.signing.enable || cfg.signing.key != null;
            message = "aytordev.programs.terminal.tools.git.signing.key must be set when signing is enabled";
          }
        ];
        programs.git = gitConfig;
      }
      # Bare-command shorthands reach all shells via home.shellAliases. The
      # old bash/conf.d/git-aliases.sh duplicate is gone: home.shellAliases
      # already fans out to bash.
      (lib.mkIf (shell-aliases.allAliases != {}) {
        home.shellAliases = shell-aliases.allAliases;
      })
    ]
  );
}
