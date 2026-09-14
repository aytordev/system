# OpenCode MCP (Model Context Protocol) server projection.
#
# `programs.mcp.servers` is already filtered to the OpenCode selection by the
# MCP capability (`aytordev.programs.terminal.tools.mcp.selection.opencode`), so
# this adapter cannot introduce unselected or stale servers. The previous
# disabled `github`/`socket` entries were removed: they were never selected and
# must not expand the active set.
{
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;

  # Mirror Home Manager's OpenCode MCP shape (see
  # `modules/programs/opencode.nix` `toOpencodeShape`) so that
  # `programs.opencode.settings.mcp` holds the effective set, not only the
  # generated `opencode.json`.
  toOpencodeShape = server: let
    isRemote = (server.url or null) != null;
    renderedEnv = lib.hm.mcp.renderEnv (p: "{file:${p}}") (server.env or {});
  in
    lib.optionalAttrs ((server.enabled or null) != null) {inherit (server) enabled;}
    // {
      type =
        if isRemote
        then "remote"
        else "local";
    }
    // (
      if isRemote
      then
        {inherit (server) url;}
        // lib.optionalAttrs ((server.headers or {}) != {}) {inherit (server) headers;}
      else
        {command = [server.command] ++ (server.args or []);}
        // lib.optionalAttrs (renderedEnv != {}) {environment = renderedEnv;}
    );
in {
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      # Use the supported Home Manager integration for the generated
      # `opencode.json`; `settings.mcp` below carries the same selected set so
      # the option surface is explicit and assertable.
      enableMcpIntegration = true;
      settings.mcp = lib.mapAttrs (_: toOpencodeShape) config.programs.mcp.servers;
    };
  };
}
