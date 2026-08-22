{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.aytordev) mkOpt;

  cfg = config.aytordev.user;
in {
  options.aytordev.user = {
    name = lib.mkOption {
      type = types.str;
      description = "The user account.";
    };
    email = lib.mkOption {
      type = types.str;
      description = "The email of the user.";
    };
    fullName = lib.mkOption {
      type = types.str;
      description = "The full name of the user.";
    };
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
      shell = pkgs.zsh;
      home = "/Users/${cfg.name}";
    };
  };
}
