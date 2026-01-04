{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce mkOption;
  cfg = config.aytordev.applications.terminal.tools.git;
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
    settings.alias = aliases;
    ignores = ignores;
    settings.user.name = inputs.secrets.username;
    settings.user.email = inputs.secrets.useremail;
    maintenance.enable = true;
    settings.branch.sort = "-committerdate";
    settings.core.editor = "nano";
    settings.useHttpPath.enable = true;
    settings.fetch.prune = true;
    settings.init.defaultBranch = "main";
    settings.lfs.enable = true;
    settings.pull.rebase = true;
    settings.push.autoSetupRemote = true;
    settings.push.default = "current";
    settings.rerere.enabled = true;
    settings.rebase.autostash = true;
    settings.safe.directory = [
      "/Users/${inputs.secrets.username}/"
      "/etc/nixos"
      "/etc/nix-darwin"
    ];
    signing.key = cfg.signingKey;
    signing.format = "ssh";
    signing.signByDefault = cfg.signByDefault;
  };
in {
  options.aytordev.applications.terminal.tools.git = {
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
    cfg = config.aytordev.applications.terminal.tools.git;
    bashConfigDir = "${config.xdg.configHome}/bash/conf.d";
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        home.packages = gitPackages;
        programs.git = gitConfig;
        programs.delta.enable = true;
        programs.delta.enableGitIntegration = true;
        programs.delta.options.dark = true;
        programs.delta.options.features = mkForce "decorations side-by-side navigate catppuccin-macchiato";
        programs.delta.options.line-numbers = true;
        programs.delta.options.navigate = true;
        programs.delta.options.side-by-side = true;
        programs.difftastic.git.diffToolMode = true;
        programs.difftastic.options.background = "dark";
        programs.difftastic.options.display = "inline";
        programs.mergiraf.enable = true;
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
