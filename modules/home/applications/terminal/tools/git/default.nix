{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce mkOption;
  cfg = config.applications.terminal.tools.git;
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
    aliases = aliases;
    ignores = ignores;
    userName = inputs.secrets.username;
    userEmail = inputs.secrets.useremail;
    maintenance.enable = true;
    delta.enable = true;
    delta.options.dark = true;
    delta.options.features = mkForce "decorations side-by-side navigate catppuccin-macchiato";
    delta.options.line-numbers = true;
    delta.options.navigate = true;
    delta.options.side-by-side = true;
    difftastic.enableAsDifftool = true;
    difftastic.background = "dark";
    difftastic.display = "inline";
    extraConfig.branch.sort = "-committerdate";
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
    cfg = config.applications.terminal.tools.git;
    bashConfigDir = "${config.xdg.configHome}/bash/conf.d";
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        home.packages = gitPackages;
        programs.git = gitConfig;
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
