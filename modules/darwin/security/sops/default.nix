{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.darwin.security.sops;
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  inherit (builtins) isString;

  # Type for secret options
  secretType = types.submodule {
    options = {
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
  };

in
{
  options.darwin.security.sops = {
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
      type = types.attrsOf (types.either types.str secretType);
      default = {};
      description = "Attribute set of secrets to manage";
      example = {
        "github_ssh_private_key" = {
          path = "/Users/username/.ssh/github_ed25519";
          mode = "0600";
          owner = "username";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Base sops configuration
    {
      sops = {
        defaultSopsFile = cfg.defaultSopsFile;
        age.keyFile = cfg.age.keyFile;
        
        # Disable SSH key checking
        gnupg.sshKeyPaths = [];
      };
    }

    # Generate secrets configuration
    {
      sops.secrets = lib.mapAttrs (name: secret:
        if builtins.isString secret then {
          sopsFile = cfg.defaultSopsFile;
          key = name;
          path = secret;
        } else {
          inherit (secret) path;
          sopsFile = if secret.sopsFile != null then secret.sopsFile else cfg.defaultSopsFile;
          inherit (secret) key mode owner group;
        }
      ) cfg.secrets;
    }
  ]);
}