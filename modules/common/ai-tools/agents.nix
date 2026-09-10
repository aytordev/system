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

  # OpenCode: YAML frontmatter with tools as boolean record
  renderOpenCodeFrontmatter = agent: let
    hasWrite = builtins.elem "Write" agent.tools;
    hasEdit = builtins.elem "Edit" agent.tools;
    hasBash = builtins.elem "Bash" agent.tools;
  in ''
    ---
    name: ${agent.name}
    description: ${agent.description}
    tools:
      write: ${lib.boolToString hasWrite}
      edit: ${lib.boolToString hasEdit}
      bash: ${lib.boolToString hasBash}
    model: ${agent.model.opencode}
    ---
  '';

  renderOpenCodeMarkdownAgent = agent: ''
    ${lib.trim (renderOpenCodeFrontmatter agent)}

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

  toOpenCodeMarkdown = lib.mapAttrs (_: renderOpenCodeMarkdownAgent) resolvedAgents;
  toOpenCodeAgents = lib.mapAttrs (_: toOpenCodeAgent) resolvedAgents;
in {
  inherit
    agents
    toOpenCodeMarkdown
    toOpenCodeAgents
    ;
}
