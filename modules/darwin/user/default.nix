{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption;
  cfg = config.darwin.user;
in {
  options.darwin.user = {
    enable = mkEnableOption "user configuration";
    name = mkOption {
      type = types.str;
      default = inputs.secrets.username;
      description = "The username for the user account.";
    };
    email = mkOption {
      type = types.str;
      default = inputs.secrets.useremail;
      description = "The email address of the user.";
    };
    fullName = mkOption {
      type = types.str;
      default = inputs.secrets.userfullname;
      description = "The full name of the user.";
    };
    uid = mkOption {
      type = types.nullOr types.int;
      default = 501;
      description = "The UID for the user account. Set to null for automatic assignment.";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.${inputs.secrets.username} = {
      inherit (cfg) uid;
      home = "/Users/${inputs.secrets.username}";
      shell = pkgs.zsh;
      description = inputs.secrets.userfullname;
    };
  };
}
