{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.applications.terminal.tools.jujutsu;
in {
  options.applications.terminal.tools.jujutsu = {
    enable = mkEnableOption "jujutsu version control system";

    package = mkOption {
      type = types.package;
      default = pkgs.jujutsu;
      defaultText = literalExpression "pkgs.jujutsu";
      description = "The jujutsu package to use.";
    };

    signByDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to sign commits by default.";
    };

    signingKey = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.ssh/ssh_key_github_ed25519";
      description = "The key ID to sign commits with.";
    };

    userName = mkOption {
      type = types.str;
      default = inputs.secrets.username;
      description = "The name to configure jujutsu with.";
    };

    userEmail = mkOption {
      type = types.str;
      default = inputs.secrets.useremail;
      description = "The email to configure jujutsu with.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package pkgs.lazyjj];

    programs.jujutsu = {
      enable = true;
      package = cfg.package;

      settings =
        {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
          fetch.prune = true;
          init.default_branch = "main";
          lfs.enable = true;
          push = {
            # autoSetupRemote = true;
            default = "current";
          };
          rebase.auto_stash = true;
        }
        // optionalAttrs cfg.signByDefault {
          operation.signing_key = cfg.signingKey;
        };
    };
  };
}
