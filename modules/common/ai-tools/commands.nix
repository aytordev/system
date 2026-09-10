{lib, ...}: let
  commands = lib.importSubdirs ./commands {};

  # Parse YAML frontmatter from old-format string commands
  parseFrontmatter = name: text: let
    parts = lib.splitString "---" text;
    hasFrontmatter = lib.length parts >= 3;
    frontmatter =
      if hasFrontmatter
      then lib.elemAt parts 1
      else "";
    lines = lib.filter (l: l != "") (builtins.map lib.trim (lib.splitString "\n" frontmatter));
    getField = prefix: let
      match = lib.findFirst (l: lib.hasPrefix prefix l) null lines;
    in
      if match != null
      then lib.trim (lib.removePrefix prefix match)
      else null;
    prompt =
      if hasFrontmatter
      then lib.trim (lib.elemAt parts 2)
      else lib.trim text;
  in {
    commandName = name;
    description = getField "description:";
    allowedTools = getField "allowed-tools:";
    argumentHint = getField "argument-hint:";
    inherit prompt;
  };

  # Normalize a command regardless of format (string or attrset)
  normalizeCommand = name: command: let
    parsed =
      if builtins.isString command
      then parseFrontmatter name command
      else command;
    agent = parsed.agent or "sdd-orchestrator";
  in {
    commandName = parsed.commandName or name;
    description = parsed.description or null;
    allowedTools = parsed.allowedTools or null;
    argumentHint = parsed.argumentHint or null;
    prompt = parsed.prompt or "";
    inherit agent;
  };

  normalizedCommands = lib.mapAttrs normalizeCommand commands;

  # Render functions for each tool format
  renderOpenCodeFrontmatter = command: ''
    ---
    ${lib.optionalString (command.description != null) "description: ${command.description}"}
    ${lib.optionalString (command.agent != null) "agent: ${command.agent}"}
    ---
  '';

  renderOpenCodeMarkdown = command: ''
    ${lib.trim (renderOpenCodeFrontmatter command)}

    ${lib.trim command.prompt}
  '';

  toOpenCodeMarkdown = lib.mapAttrs (_name: renderOpenCodeMarkdown) normalizedCommands;
in {
  inherit
    normalizedCommands
    toOpenCodeMarkdown
    ;
}
