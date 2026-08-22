{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    literalExpression
    optionalAttrs
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.jujutsu;
in {
  options.aytordev.programs.terminal.tools.jujutsu = {
    enable = mkEnableOption "jujutsu version control system";
    package = mkOption {
      type = types.package;
      default = pkgs.jujutsu;
      defaultText = literalExpression "pkgs.jujutsu";
      description = "The jujutsu package to use.";
    };
    signing = {
      enable = mkEnableOption "SSH signing for jujutsu commits";
      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The SSH key ID to sign commits with.";
      };
    };
    userName = mkOption {
      type = types.str;
      default = config.aytordev.user.name;
      description = "The name to configure jujutsu with.";
    };
    userEmail = mkOption {
      type = types.str;
      default = config.aytordev.user.email;
      description = "The email to configure jujutsu with.";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.signing.enable || cfg.signing.key != null;
        message = "aytordev.programs.terminal.tools.jujutsu.signing.key must be set when signing is enabled";
      }
    ];
    home.packages = [
      cfg.package
      pkgs.lazyjj
    ];
    home.sessionVariables.RAYON_NUM_THREADS = "4";
    programs.jujutsu = {
      enable = true;
      inherit (cfg) package;
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
            default = "current";
          };
          rebase.auto_stash = true;
          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            diff-instructions = false;
          };
        }
        // optionalAttrs cfg.signing.enable {
          signing = {
            backend = "ssh";
            inherit (cfg.signing) key;
            sign-all = true;
          };
        };
    };
  };
}
