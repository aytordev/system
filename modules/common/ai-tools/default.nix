{
  lib,
  roleOverrides ? {},
  ...
}: let
  roles = import ./roles.nix {inherit lib;};
  registry = import ./registry.nix {inherit lib;};
  aiCommands = import ./commands.nix {inherit lib;};
  aiAgents = import ./agents.nix {inherit lib roleOverrides;};
in {
  # Role/model policy (pure data + resolution). OpenCode consumes it through
  # `opencode.agents`; Pi will consume it at session level (T05).
  inherit roles;

  opencode = lib.seq registry.commands {
    commands = aiCommands.toOpenCodeMarkdown;
    agents = aiAgents.toOpenCodeAgents;
    # Per-command fields OpenCode cannot express; lets consumers/checks confirm
    # they are reported rather than silently dropped.
    commandUnsupportedFields = aiCommands.unsupportedOpenCodeFields;
  };

  # Pure renderer helpers reused by checks/ai-tools-renderers. Not a client API.
  _internal = {
    inherit (aiCommands) normalizeCommand renderCommand;
  };
}
