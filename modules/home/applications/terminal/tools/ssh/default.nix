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
      
      # Generate clean SSH configuration without duplicates
      extraConfig = ''
        # Default SSH configuration for all hosts
        Host *
          AddKeysToAgent yes
          IdentitiesOnly yes
          ForwardAgent no
          Compression no
          ServerAliveInterval 15
          ServerAliveCountMax 3
          HashKnownHosts no
          UserKnownHostsFile ~/.ssh/known_hosts
          ControlMaster auto
          ControlPath ~/.ssh/controlmasters/%r@%h:%p
          ControlPersist 10m
          TCPKeepAlive yes
          ServerAliveInterval 15
          ServerAliveCountMax 3
          GSSAPIAuthentication no
          GSSAPIKeyExchange no
          AddressFamily inet
          Protocol 2
          Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
          MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
          KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256

        # Local development
        Host *.local
          Port ${toString cfg.port}
          User ${config.home.username}
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null

        # Known hosts configuration
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: host: ''
          # ${name}
          Host ${lib.concatStringsSep " " host.hostNames}
            ${lib.optionalString (host ? user) "User ${host.user}"}
            ${if host ? publicKey then "HostKey ${host.publicKey}" else ""}
            ${if host ? port then "Port ${toString host.port}" else ""}
            ${if host ? identityFile then "IdentityFile ${host.identityFile}" else ""}
            ${if host ? identitiesOnly then "IdentitiesOnly ${if host.identitiesOnly then "yes" else "no"}" else ""}
        '') cfg.knownHosts)}

        # User-provided configuration (overrides above settings)
        ${cfg.extraConfig}
      '';
      
      # User-defined match blocks
      matchBlocks = cfg.matchBlocks;
    };

    # Set up authorized_keys if any keys are provided
    home.file = lib.mkIf (cfg.authorizedKeys != []) {
      ".ssh/authorized_keys".text = lib.concatStringsSep "\n" cfg.authorizedKeys;
    };

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
