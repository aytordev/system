{lib, ...}: let
  agents = lib.importSubdirs ./agents {};

  # Strip YAML frontmatter (---\n...\n---) from skill content
  stripFrontmatter = content: let
    parts = lib.splitString "---" content;
  in
    if lib.length parts >= 3 && lib.trim (builtins.head parts) == ""
    then lib.trim (lib.concatStringsSep "---" (lib.drop 2 parts))
    else lib.trim content;

  # Resolve agent content: strip frontmatter from SKILL.md files
  resolveContent = agent: agent // {content = stripFrontmatter agent.content;};
  resolvedAgents = lib.mapAttrs (_: resolveContent) agents;

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

  toClaudeMarkdown = lib.mapAttrs (_: renderClaudeAgent) resolvedAgents;
  toOpenCodeAgents = lib.mapAttrs (_: toOpenCodeAgent) resolvedAgents;
  toGeminiAgents = lib.mapAttrs (_: toGeminiAgent) resolvedAgents;
in {
  inherit agents toClaudeMarkdown toOpenCodeAgents toGeminiAgents;
}
