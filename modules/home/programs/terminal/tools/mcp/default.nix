{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.aytordev.programs.terminal.tools.mcp;

  # Fields mirror what Pi's MCP adapter (pi-mcp-adapter) accepts in a server
  # entry. Unknown keys are dropped by the adapter, so the registry stays
  # limited to fields with a real consumer.
  serverType = types.submodule {
    options = {
      command = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Executable of a stdio MCP server.";
      };
      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Arguments passed to `command`.";
      };
      env = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for a stdio MCP server.";
      };
      url = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Endpoint of a remote MCP server.";
      };
      type = mkOption {
        type = types.nullOr (types.enum ["stdio" "http" "sse"]);
        default = null;
        description = "Explicit transport. Left unset by default; clients infer stdio from `command`.";
      };
      directTools = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Pi-specific: expose the server's tools directly instead of through the MCP meta-tools.";
      };
    };
  };

  # Omit unset and empty fields so the generated file stays a minimal,
  # diff-friendly registry.
  toServerEntry = server:
    lib.filterAttrs (_: value: value != null) {
      inherit (server) command;
      args =
        if server.args == []
        then null
        else server.args;
      env =
        if server.env == {}
        then null
        else server.env;
      inherit (server) url;
      inherit (server) type;
      inherit (server) directTools;
    };

  serverAssertions =
    lib.mapAttrsToList (name: server: {
      assertion = (server.command != null) != (server.url != null);
      message = "aytordev.programs.terminal.tools.mcp.servers.${name} must set exactly one of `command` (stdio server) or `url` (remote server).";
    })
    cfg.servers;
in {
  options.aytordev.programs.terminal.tools.mcp = {
    servers = mkOption {
      type = types.attrsOf serverType;
      default = {};
      description = ''
        MCP servers published to the standard user-global registry
        (`~/.config/mcp/mcp.json`).

        This module is a pure-data registry, so it has no `enable` switch: the
        file is written exactly when `servers` is non-empty. Capabilities that
        ship an MCP server (for example
        `aytordev.programs.terminal.tools.pen`) contribute their entry here.
      '';
    };
  };

  config = mkIf (cfg.servers != {}) {
    assertions =
      serverAssertions
      ++ [
        {
          # The adapter resolves the shared registry as `os.homedir()/.config/mcp/mcp.json`
          # and ignores XDG_CONFIG_HOME, so a relocated config home would silently
          # publish servers that no client reads.
          assertion = config.xdg.configHome == "${config.home.homeDirectory}/.config";
          message = "aytordev.programs.terminal.tools.mcp.servers requires xdg.configHome to stay at ~/.config, because the MCP adapter that imports this registry resolves it from the home directory and ignores XDG_CONFIG_HOME.";
        }
      ];

    # Ownership: Nix owns the shared registry only. Pi's `~/.pi/agent/mcp.json`
    # belongs to the official Gentle AI installer and keeps higher precedence, so
    # an entry declared here can never shadow an installer-managed server.
    xdg.configFile."mcp/mcp.json".text =
      builtins.toJSON {
        mcpServers = lib.mapAttrs (_: toServerEntry) cfg.servers;
      }
      + "\n";
  };
}
