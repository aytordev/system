{lib, ...}: let
  aiCommands = import ./commands.nix {inherit lib;};
  aiAgents = import ./agents.nix {inherit lib;};
in {
  opencode = {
    commands = aiCommands.toOpenCodeMarkdown;
    agents = aiAgents.toOpenCodeMarkdown;
    agentConfigs = aiAgents.toOpenCodeAgents;
  };
}
