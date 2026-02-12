{lib, ...}: let
  aiCommands = import ./commands.nix {inherit lib;};
  aiAgents = import ./agents.nix {inherit lib;};
in {
  claudeCode = {
    commands = aiCommands.toClaudeMarkdown;
    agents = aiAgents.toClaudeMarkdown;
  };

  geminiCli = {
    commands = aiCommands.toGeminiCommands;
    agents = aiAgents.toGeminiAgents;
  };

  opencode = {
    commands = aiCommands.toOpenCodeMarkdown;
    agents = aiAgents.toClaudeMarkdown;
    agentConfigs = aiAgents.toOpenCodeAgents;
  };

  mergeCommands = existingCommands: newCommands: existingCommands // newCommands;
}
