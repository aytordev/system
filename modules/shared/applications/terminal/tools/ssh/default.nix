{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.applications.terminal.tools.ssh;
in {
  options.applications.terminal.tools.ssh = {
    port = mkOption {
      type = types.port;
      default = 2222;
      description = "SSH port to use for local connections";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional SSH client configuration";
    };
    knownHosts = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          hostNames = mkOption {
            type = types.listOf types.str;
            description = "List of host names for this known host entry";
          };
          publicKey = mkOption {
            type = types.str;
            description = "Public key for the host";
          };
          extraConfig = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Additional configuration for the known host";
          };
        };
      }));
      default = {};
      description = "Known hosts configuration";
    };
  };
  config = {
    programs.ssh = {
      extraConfig = ''
        Host *
          AddKeysToAgent yes
          IdentitiesOnly yes
        Host *.local
          Port ${toString cfg.port}
        ${cfg.extraConfig}
      '';
      knownHosts = lib.mapAttrs (name: host:
        {
          inherit (host) hostNames publicKey;
        }
        // host.extraConfig)
      cfg.knownHosts;
    };
  };
}
