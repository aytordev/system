{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Re-export commonly used functions and types for cleaner code
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  inherit (builtins) isString;

  # Module configuration
  cfg = config.darwin.security.sops;

  ####################################
  # Type Definitions
  ####################################
  secretOptions = {
    # Type for secret file configuration
    sopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to the sops file containing this secret";
    };

    # Type for secret key
    key = mkOption {
      type = types.str;
      description = "Key of the secret in the sops file";
    };

    # Type for secret destination path
    path = mkOption {
      type = types.str;
      description = "Path where the decrypted secret should be stored";
    };

    # Type for file permissions
    mode = mkOption {
      type = types.str;
      default = "0400";
      description = "Permissions mode for the decrypted file";
    };

    # Type for file owner
    owner = mkOption {
      type = types.str;
      default = "root";
      description = "Owner of the decrypted file";
    };

    # Type for file group
    group = mkOption {
      type = types.str;
      default = "wheel";
      description = "Group of the decrypted file";
    };
  };

  ####################################
  # Helper Functions
  ####################################

  # Create a secret configuration from a string (simple case)
  mkStringSecret = name: path: {
    sopsFile = cfg.defaultSopsFile;
    key = name;
    path = path;
    mode = "0400";
    owner = "root";
    group = "wheel";
  };

  # Create a secret configuration from an attribute set (advanced case)
  mkAttrsSecret = name: secret: {
    inherit (secret) path key mode owner group;
    sopsFile =
      if secret ? sopsFile && secret.sopsFile != null
      then secret.sopsFile
      else cfg.defaultSopsFile;
  };

  # Map a secret definition to its configuration
  mapSecret = name: secret:
    if isString secret
    then mkStringSecret name secret
    else mkAttrsSecret name secret;

  ####################################
  # Module Configuration
  ####################################

  # Base sops configuration
  sopsBaseConfig = {
    sops = {
      inherit (cfg) defaultSopsFile;
      age.keyFile = cfg.age.keyFile;
      gnupg.sshKeyPaths = []; # Disable SSH key checking
    };
  };

  # Secrets configuration
  secretsConfig = {
    sops.secrets = lib.mapAttrs mapSecret cfg.secrets;
  };
in {
  ####################################
  # Module Options
  ####################################
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

  ####################################
  # Module Implementation
  ####################################

  config = mkIf cfg.enable (mkMerge [
    sopsBaseConfig
    secretsConfig
  ]);
}
