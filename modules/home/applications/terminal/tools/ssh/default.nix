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
          publicKey = mkOption {
            type = types.str;
            description = "Public key for the host";
          };
        };
      });
      default = {};
      description = "Known hosts configuration";
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
      
      # Combine default configuration, known hosts, and user-provided config
      extraConfig = ''
        # Default SSH configuration
        Host *
          AddKeysToAgent yes
          IdentitiesOnly yes
          ForwardAgent no
          Compression no
          ServerAliveInterval 0
          ServerAliveCountMax 3
          HashKnownHosts no
          UserKnownHostsFile ~/.ssh/known_hosts
          ControlMaster no
          ControlPath ~/.ssh/master-%r@%n:%p
          ControlPersist no

        # Local development
        Host *.local
          Port ${toString cfg.port}

        # Known hosts
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: host: ''
          # ${name}
          Host ${lib.concatStringsSep " " host.hostNames}
            HostKeyAlias ${name}
            ${if host ? publicKey then "HostKey ${host.publicKey}" else ""}
        '') cfg.knownHosts)}

        # User-provided configuration
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
