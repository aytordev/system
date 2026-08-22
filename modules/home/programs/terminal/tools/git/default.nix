{
  config,
  lib,
  pkgs,
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
  gitConfig =
    {
      enable = true;
      package = pkgs.gitFull;
      inherit ignores;
      maintenance.enable = true;
      hooks.pre-commit = pkgs.writeShellScript "git-pre-commit-conflict-check" ''
        if git diff --cached | grep -qE '^\+(<{7}|>{7})'; then
          printf 'Error: staged changes contain conflict markers\n' >&2
          exit 1
        fi
      '';
      settings = {
        alias = aliases;
        user = {
          inherit (config.aytordev.user) name email;
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
          else "${pkgs.gitFull}/libexec/git-core/git-credential-libsecret";
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
  options.aytordev.programs.terminal.tools.git = {
    enable =
      mkEnableOption "Git configuration"
      // {
        description = ''
          Whether to enable the Git configuration module.
          This includes Git itself, common tools, and configuration.
        '';
      };
    signing = {
      enable = mkEnableOption "SSH signing for Git commits and tags";
      key = mkOption {
        type = with lib.types; nullOr (either str path);
        default = null;
        description = "Path to the SSH private key used for signing Git commits and tags.";
        example = "~/.ssh/id_ed25519";
      };
    };
  };
  config = let
    cfg = config.aytordev.programs.terminal.tools.git;
    bashConfigDir = "${config.xdg.configHome}/bash/conf.d";
  in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          assertions = [
            {
              assertion = !cfg.signing.enable || cfg.signing.key != null;
              message = "aytordev.programs.terminal.tools.git.signing.key must be set when signing is enabled";
            }
          ];
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
        }
        (lib.mkIf (shell-aliases.allAliases != {}) {
          home.file."${bashConfigDir}/git-aliases.sh" = {
            text = shell-aliases.generateGitAliasesFile shell-aliases.allAliases;
            executable = true;
          };
          home.shellAliases = shell-aliases.allAliases;
        })
      ]
    );
}
