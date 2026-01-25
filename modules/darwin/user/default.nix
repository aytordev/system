{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.aytordev) mkOpt;

  cfg = config.aytordev.user;
in {
  options.aytordev.user = {
    name = mkOpt types.str inputs.secrets.username "The user account.";
    email = mkOpt types.str inputs.secrets.useremail "The email of the user.";
    fullName = mkOpt types.str inputs.secrets.userfullname "The full name of the user.";
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
