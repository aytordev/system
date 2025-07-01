{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
  inherit (lib.attrsets) mapAttrs optionalAttrs nameValuePair filterAttrs;
  inherit (lib.lists) any optional;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.strings) hasInfix;

  cfg = config.darwin.security.sops;
  user = config.users.users.${config.user.name} or { home = ""; };
  
  # Helper function to create activation script for secrets
  mkSecretScript = name: { path, mode, sopsFile, ... }@secret: let
    secretName = builtins.baseNameOf path;
    secretDir = builtins.dirOf path;
  in ''
    echo "Decrypting ${name} to ${path}..."
    mkdir -p ${lib.escapeShellArg secretDir}
    ${pkgs.sops}/bin/sops -d ${lib.escapeShellArg sopsFile} > ${lib.escapeShellArg path}
    chmod ${mode} ${lib.escapeShellArg path}
  '';

  # Filter out secrets that have all required attributes
  validSecrets = filterAttrs (n: v: v.path != null && v.sopsFile != null) cfg.secrets;
  
  # Generate activation scripts for all valid secrets
  secretScripts = mapAttrs mkSecretScript validSecrets;
  
  # Create a script to decrypt all secrets
  decryptScript = pkgs.writeShellScriptBin "decrypt-secrets" ''
    set -e
    ${lib.concatStringsSep "\n" (lib.attrValues secretScripts)}
  '';
  
in
{
  options.darwin.security.sops = {
    enable = mkEnableOption "SOPS secrets management";

    defaultSopsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Default SOPS file to use for secrets";
    };

    age = {
      keyFile = mkOption {
        type = types.nullOr types.path;
        default = if user.home != "" then "${user.home}/.config/sops/age/keys.txt" else null;
        defaultText = "$HOME/.config/sops/age/keys.txt";
        description = "Path to the AGE key file";
      };

      sshKeyPaths = mkOption {
        type = types.listOf types.path;
        default = [ "${user.home}/.ssh/id_ed25519" "${user.home}/.ssh/id_rsa" ];
        description = "List of SSH key paths for AGE decryption";
      };
    };

    secrets = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          path = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Target path for the decrypted secret";
          };

          mode = mkOption {
            type = types.str;
            default = "0400";
            description = "File permissions for the decrypted secret";
          };

          sopsFile = mkOption {
            type = types.nullOr types.path;
            default = cfg.defaultSopsFile;
            description = "SOPS file containing the secret";
          };
        };
      }));
      default = { };
      description = "Secrets configuration";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.defaultSopsFile != null || !(any (s: s.sopsFile == null) (lib.attrValues cfg.secrets));
          message = "Either defaultSopsFile must be set or each secret must specify sopsFile";
        }
        {
          assertion = cfg.age.keyFile != null || cfg.age.sshKeyPaths != [];
          message = "Either age.keyFile or age.sshKeyPaths must be set";
        }
      ];

      # Add sops to system packages
      environment.systemPackages = [ pkgs.sops ];
      
      # Create activation script for secrets
      system.activationScripts.setupSecrets = {
        text = ''
          # Set up SOPS
          export SOPS_AGE_KEY_FILE="${cfg.age.keyFile}"
          ${lib.optionalString (cfg.age.sshKeyPaths != []) 
            "export SOPS_AGE_KEY_FILE=\"${toString cfg.age.sshKeyPaths}\""}
          
          # Decrypt all secrets
          ${decryptScript}/bin/decrypt-secrets
        '';
        deps = [ "users" ];
      };
    }
  ]);
}