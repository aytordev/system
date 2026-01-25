{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  inherit (builtins) isString;

  cfg = config.aytordev.security.sops;

  secretOptions = {
    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the sops file containing this secret";
    };
    key = mkOption {
      type = types.str;
      description = "Key of the secret in the sops file";
    };
    path = mkOption {
      type = types.str;
      description = "Path where the decrypted secret should be stored";
    };
    mode = mkOption {
      type = types.str;
      default = "0400";
      description = "Permissions mode for the decrypted file";
    };
    owner = mkOption {
      type = types.str;
      default = "root";
      description = "Owner of the decrypted file";
    };
    group = mkOption {
      type = types.str;
      default = "wheel";
      description = "Group of the decrypted file";
    };
  };

  mkStringSecret = name: path: {
    sopsFile = cfg.defaultSopsFile;
    key = name;
    inherit path;
    mode = "0400";
    owner = "root";
    group = "wheel";
  };

  mkAttrsSecret = _name: secret: {
    inherit (secret) path key mode owner group;
    sopsFile =
      if secret ? sopsFile && secret.sopsFile != null
      then secret.sopsFile
      else cfg.defaultSopsFile;
  };

  mapSecret = name: secret:
    if isString secret
    then mkStringSecret name secret
    else mkAttrsSecret name secret;

  sopsBaseConfig = {
    sops = {
      inherit (cfg) defaultSopsFile;
      age.keyFile = cfg.age.keyFile;
      gnupg.sshKeyPaths = [];
    };
  };

  secretsConfig = {
    sops.secrets = lib.mapAttrs mapSecret cfg.secrets;
  };
in {
  options.aytordev.security.sops = {
    enable = mkEnableOption "SOPS secrets management";

    defaultSopsFile = mkOption {
      type = types.path;
      description = "Default sops file to use for secrets";
      example = "/path/to/secrets.yaml";
    };

    age = {
      keyFile = mkOption {
        type = types.path;
        description = "Path to the age key file for decryption";
        example = "/Users/username/.config/sops/age/keys.txt";
      };
    };

    secrets = mkOption {
      type = types.attrsOf (types.either types.str (types.submodule {options = secretOptions;}));
      default = {};
      description = "Attribute set of secrets to manage";
      example = ''
        {
          "github_ssh_private_key" = {
            path = "/Users/username/.ssh/github_ed25519";
            mode = "0600";
            owner = "username";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    sopsBaseConfig
    secretsConfig
  ]);
}
