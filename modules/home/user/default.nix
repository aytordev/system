{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption mkMerge mkDefault mkForce;
  inherit (lib.types) str package bool nullOr;
  inherit (builtins) baseNameOf;
  cfg = config.user;
  home-directory =
    if cfg.name == null
    then throw "user.name must be set"
    else if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${cfg.name}"
    else "/home/${cfg.name}";
in {
  options.user = {
    enable = mkEnableOption "user account configuration";
    home = mkOption {
      type = nullOr str;
      default = home-directory;
      defaultText = "Derived from username and platform";
      description = ''
        Absolute path to the user's home directory.
        Defaults to /Users/username on Darwin and /home/username on other platforms.
      '';
    };
    name = mkOption {
      type = nullOr str;
      default = "aytordev";
      description = "The username for the account";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "user.home must be set";
        }
      ];
      home.file = {
        "Desktop/.keep".text = "";
        "Documents/.keep".text = "";
        "Downloads/.keep".text = "";
        "Music/.keep".text = "";
        "Pictures/.keep".text = "";
        "Videos/.keep".text = "";
      };
      home.homeDirectory = mkForce cfg.home;
      home.username = mkDefault cfg.name;
    }
  ]);
}
