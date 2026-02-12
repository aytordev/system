{lib, ...}: let
  agents = lib.importSubdirs ./agents {};

  # Claude Code: YAML frontmatter with name, description, tools, model
  renderClaudeFrontmatter = agent: ''
    ---
    name: ${agent.name}
    description: ${agent.description}
    tools: ${lib.concatStringsSep ", " agent.tools}
    model: ${agent.model.claude}
    ---
  '';

  renderClaudeAgent = agent: ''
    ${lib.trim (renderClaudeFrontmatter agent)}

    ${lib.trim agent.content}
  '';

  # OpenCode: structured config with model, tools (as booleans), permissions
  toOpenCodeAgent = agent: {
    model = agent.model.opencode;
    tools = {
      write = builtins.elem "Write" agent.tools;
      edit = builtins.elem "Edit" agent.tools;
      bash = builtins.elem "Bash" agent.tools;
    };
    inherit (agent) permission description;
    prompt = lib.trim agent.content;
  };

  # Gemini CLI: just description + prompt
  toGeminiAgent = agent: {
    prompt = lib.trim agent.content;
    inherit (agent) description;
  };

  toClaudeMarkdown = lib.mapAttrs (_: renderClaudeAgent) agents;
  toOpenCodeAgents = lib.mapAttrs (_: toOpenCodeAgent) agents;
  toGeminiAgents = lib.mapAttrs (_: toGeminiAgent) agents;
in {
  inherit agents toClaudeMarkdown toOpenCodeAgents toGeminiAgents;
}
