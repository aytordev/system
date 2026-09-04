{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.shells;
  userName = config.aytordev.user.name;

  shellPackages = {
    bash = pkgs.bashInteractive;
    inherit (pkgs) fish;
    inherit (pkgs) zsh;
  };
in {
  options.aytordev.programs.terminal.shells = {
    enable = mkOption {
      type = types.bool;
      default = cfg.default != null;
      description = "Whether to register the login shell for the user account.";
    };

    default = mkOption {
      type = types.nullOr (
        types.enum [
          "bash"
          "fish"
          "zsh"
        ]
      );
      default = "zsh";
      description = "The login shell to register for the user account on darwin.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      description = "Package backing the login shell.";
      default = cfg.loginPackage;
    };

    loginPackage = mkOption {
      type = types.nullOr types.package;
      readOnly = true;
      description = "Package backing the login shell.";
      default =
        if cfg.default == null
        then null
        else shellPackages.${cfg.default};
    };
  };

  config = mkIf cfg.enable {
    # Account management is only applied to users listed here; without it the
    # macOS UserShell stays external state despite the shell option.

    users.knownUsers = [userName];

    environment.shells = [cfg.package];

    users.users.${userName}.shell = cfg.package;

    # nix-darwin requires the shell program for PATH setup; keep system zsh
    # for PATH but let Home Manager own completion (B2: no double compinit).
    programs.zsh.enable = mkDefault (cfg.default == "zsh");
    programs.zsh.enableGlobalCompInit = mkDefault false;
    programs.zsh.enableBashCompletion = mkDefault false;

    programs.fish.enable = mkDefault (cfg.default == "fish");
    programs.bash.enable = mkDefault (cfg.default == "bash");
  };
}
