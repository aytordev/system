{
  config,
  lib,
  pkgs,
  username ? null,
  ...
}: let
  inherit (lib) mkDefault mkIf types;
  inherit (lib.aytordev) mkOpt;
  cfg = config.aytordev.user;
  defaultHome =
    if cfg.name == null
    then null
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.aytordev.user = {
    enable = mkOpt types.bool false "Whether to configure the user identity.";
    email = lib.mkOption {
      type = types.str;
      description = "The user's email address.";
    };
    fullName = lib.mkOption {
      type = types.str;
      description = "The user's full name.";
    };
    home = mkOpt (types.nullOr types.str) defaultHome "The user's home directory.";
    icon = mkOpt (types.nullOr types.package) null "The user's profile picture.";
    name = mkOpt (types.nullOr types.str) username "The user account name.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.name != null;
        message = "aytordev.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "aytordev.user.home must be set";
      }
    ];

    home = {
      homeDirectory = mkIf (cfg.home != null) (mkDefault cfg.home);
      username = mkIf (cfg.name != null) (mkDefault cfg.name);
    };
  };
}
