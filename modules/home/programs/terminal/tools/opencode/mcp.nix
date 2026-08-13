# OpenCode MCP (Model Context Protocol) servers configuration module
# Defines MCP servers for extending OpenCode capabilities
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;
in {
  config = lib.mkIf cfg.enable {
    # FIXME: seems to cause opencode to just hang
    programs.opencode.settings.mcp = {
      github = {
        type = "local";
        command = [
          (lib.getExe pkgs.github-mcp-server)
          "--read-only"
          "stdio"
        ];
        enabled = false;
      };

      socket = {
        type = "remote";
        url = "https://mcp.socket.dev/";
        enabled = false;
      };
    };
  };
}
