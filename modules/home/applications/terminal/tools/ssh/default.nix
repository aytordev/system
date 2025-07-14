{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.applications.terminal.tools.ssh;
in {
  options.applications.terminal.tools.ssh = {
    enable = mkEnableOption "SSH configuration";
    
    port = mkOption {
      type = types.port;
      default = 2222;
      description = "Default SSH port for local development hosts (*.local)";
    };

    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of authorized public keys added to ~/.ssh/authorized_keys";
    };

    knownHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          hostNames = mkOption {
            type = types.listOf types.str;
            description = "List of host names for this known host entry";
          };
          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Username to use when connecting to this host";
          };
          publicKey = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Public key for the host (for verification)";
          };
          port = mkOption {
            type = types.nullOr types.port;
            default = null;
            description = "Port to use when connecting to this host";
          };
          identityFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Path to the private key to use for this host";
          };
          identitiesOnly = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Whether to use only the specified identity file";
          };
        };
      });
      default = {};
      description = "Known hosts configuration with per-host settings";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional SSH configuration";
    };

    matchBlocks = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "SSH match blocks for specific hosts";
    };
  };

  config = lib.mkIf cfg.enable {    
    programs.ssh = {
      enable = true;
      
      forwardAgent = false;
      compression = false;
      serverAliveInterval = 15;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      controlMaster = "auto";
      controlPath = "~/.ssh/controlmasters/%r@%h:%p";
      controlPersist = "10m";
      
      # Security settings
      extraOptionOverrides = {
        Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";
        KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        Protocol = "2";
        AddressFamily = "inet";
        TCPKeepAlive = "yes";
      };
      
      extraConfig = cfg.extraConfig;
      
      matchBlocks = lib.mkMerge [
        # Configuración para hosts locales
        {
          "*.local" = {
            user = config.home.username;
            port = cfg.port;
            extraOptions = {
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "/dev/null";
            };
          };
        }
        
        # Convertir knownHosts a matchBlocks
        (lib.mapAttrs' (name: host: {
          name = lib.concatStringsSep " " host.hostNames;
          value = {
            user = host.user or null;
            port = host.port or null;
            identityFile = host.identityFile or null;
            identitiesOnly = host.identitiesOnly or null;
            extraOptions = lib.optionalAttrs (host ? publicKey) {
              # Use HostKeyAlias for proper host key verification
              HostKeyAlias = lib.head host.hostNames;
              # The public key will be added to known_hosts by Home Manager
            } // (host.extraOptions or {});
          };
        }) cfg.knownHosts)
        
        # Configuración adicional del usuario
        cfg.matchBlocks
      ];
    };

    # Set up SSH related files and directories
    home.file = lib.mkMerge [
      # Set up authorized_keys if any keys are provided
      (lib.optionalAttrs (cfg.authorizedKeys != []) {
        ".ssh/authorized_keys".text = lib.concatStringsSep "\n" cfg.authorizedKeys;
      })
    ];
    
    # Create controlmasters directory for connection sharing
    home.activation.createSshControlmastersDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/.ssh/controlmasters
      chmod 700 ~/.ssh/controlmasters
    '';

    # Shell aliases for SSH key management
    home.shellAliases = {
      # Fix SSH permissions
      ssh-fix-perms = ''
        find ~/.ssh -type f -not -name "*.pub" -exec chmod 600 {} \; && \
        find ~/.ssh -type d -exec chmod 700 {} \; && \
        find ~/.ssh -name "*.pub" -exec chmod 644 {} \;
      '';
    };
  };
}
