{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.aytordev.programs.terminal.tools.ssh;
  defaultKnownHosts = import ./known-hosts.nix;
  knownHostsText = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      _name: host: "${lib.concatStringsSep "," host.hostNames} ${host.publicKey}"
    )
    cfg.knownHosts
  );
in {
  options.aytordev.programs.terminal.tools.ssh = {
    enable = mkEnableOption "SSH configuration";
    package = lib.mkPackageOption pkgs "openssh" {
      nullable = true;
      default = null;
      extraDescription = "By default, the client provided by your system is used.";
    };
    port = mkOption {
      type = types.port;
      default = 22;
      description = "Default SSH port for local development hosts (*.local)";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of authorized public keys added to ~/.ssh/authorized_keys";
    };
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            hostNames = mkOption {
              type = types.listOf types.str;
              description = "Host patterns for this connection profile";
            };
            user = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Username to use when connecting to this host";
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
        }
      );
      default = {};
      description = "Per-host SSH connection settings";
    };
    knownHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            hostNames = mkOption {
              type = types.listOf types.str;
              description = "Host names covered by this key";
            };
            publicKey = mkOption {
              type = types.str;
              description = "Public host key used for verification";
            };
          };
        }
      );
      default = {};
      description = "Trusted SSH host keys";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional SSH configuration";
    };
    extraSettings = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "Additional SSH settings blocks using upstream OpenSSH directive names";
    };
  };
  config = lib.mkIf cfg.enable {
    aytordev.programs.terminal.tools.ssh.knownHosts =
      lib.mapAttrs (
        _name: lib.mkDefault
      )
      defaultKnownHosts;

    programs.ssh = {
      enable = true;
      inherit (cfg) package;
      enableDefaultConfig = false;
      extraOptionOverrides = {
        Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";
        KexAlgorithms = "curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        Protocol = "2";
        AddressFamily = "inet";
        TCPKeepAlive = "yes";
      };
      inherit (cfg) extraConfig;
      settings = lib.mkMerge [
        {
          "*" = {
            ForwardAgent = false;
            Compression = false;
            ServerAliveInterval = 15;
            ServerAliveCountMax = 3;
            HashKnownHosts = false;
            ControlMaster = "auto";
            ControlPath = "~/.ssh/controlmasters/%r@%h:%p";
            ControlPersist = "10m";
            UserKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/known_hosts.d/aytordev";
          };
          "*.local" = {
            User = config.home.username;
            Port = cfg.port;
            StrictHostKeyChecking = "accept-new";
          };
        }
        (lib.mapAttrs' (_name: host: {
            name = lib.concatStringsSep " " host.hostNames;
            value =
              lib.filterAttrs (_: v: v != null) {
                User = host.user or null;
                Port = host.port or null;
                IdentityFile = host.identityFile or null;
                IdentitiesOnly = host.identitiesOnly or null;
              }
              // {
                HostKeyAlias = lib.head host.hostNames;
              }
              // (host.extraOptions or {});
          })
          cfg.hosts)
        cfg.extraSettings
      ];
    };
    home = {
      file = lib.mkMerge [
        (lib.optionalAttrs (cfg.authorizedKeys != []) {
          ".ssh/authorized_keys".text = lib.concatStringsSep "\n" cfg.authorizedKeys;
        })
        (lib.optionalAttrs (cfg.knownHosts != {}) {
          ".ssh/known_hosts.d/aytordev".text = "${knownHostsText}\n";
        })
      ];
      activation.createSshControlmastersDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ~/.ssh/controlmasters
        chmod 700 ~/.ssh/controlmasters
      '';
      packages = [
        (pkgs.writeShellScriptBin "ssh-fix-perms" ''
          find "$HOME/.ssh" -type f -not -name "*.pub" -exec chmod 600 {} +
          find "$HOME/.ssh" -type d -exec chmod 700 {} +
          find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} + 2>/dev/null
        '')
      ];
      shellAliases = {
        ssh-fix-perms = "${config.home.profileDirectory}/bin/ssh-fix-perms";
      };
    };
  };
}
