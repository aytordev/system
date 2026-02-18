{lib, ...}: let
  commands = lib.importSubdirs ./commands {};

  # Map commands to their preferred agent
  commandAgents = {
    # Git commands
    "add-and-format" = "code-reviewer";
    "commit-changes" = "code-reviewer";
    "review" = "code-reviewer";
    "analyze-git-history" = "code-reviewer";
    "resolve-conflicts" = "code-reviewer";
    "git-bisect" = "code-reviewer";
    "git-branch-cleanup" = "code-reviewer";

    # LLM / code analysis commands
    "explain-code" = "dotfiles-coder";
    "extract-interface" = "dotfiles-coder";
    "find-usages" = "dotfiles-coder";
    "summarize-module" = "dotfiles-coder";
    "refactor-suggest" = "code-reviewer";
    "generate-docs" = "docs-writer";
    "generate-tests" = "code-reviewer";

    # Quality commands
    "check-todos" = "code-reviewer";
    "code-review" = "code-reviewer";
    "deep-check" = "code-reviewer";
    "dependency-audit" = "code-reviewer";
    "module-lint" = "code-reviewer";
    "parse-sarif" = "code-reviewer";
    "style-audit" = "code-reviewer";

    # Nix commands
    "flake-update" = "flake-coder";
    "module-scaffold" = "nix-module-coder";
    "option-migrate" = "nix-module-coder";
    "nix-refactor" = "nix-coder";
    "template-new" = "template-writer";

    # Project commands
    "changelog" = "docs-writer";

    # Design commands
    "interface-design-init" = "dotfiles-coder";
    "interface-design-audit" = "code-reviewer";
    "interface-design-status" = "code-reviewer";
    "interface-design-critique" = "dotfiles-coder";
    "interface-design-extract" = "code-reviewer";
  };

  # Parse YAML frontmatter from old-format string commands
  parseFrontmatter = name: text: let
    parts = lib.splitString "---" text;
    hasFrontmatter = lib.length parts >= 3;
    frontmatter =
      if hasFrontmatter
      then lib.elemAt parts 1
      else "";
    lines = lib.filter (l: l != "") (
      builtins.map lib.trim (lib.splitString "\n" frontmatter)
    );
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
    agent = parsed.agent or (commandAgents.${name} or "dotfiles-coder");
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
  renderClaudeFrontmatter = command: ''
    ---
    ${lib.optionalString (command.allowedTools != null) "allowed-tools: ${command.allowedTools}"}
    ${lib.optionalString (command.argumentHint != null) "argument-hint: ${command.argumentHint}"}
    ${lib.optionalString (command.description != null) "description: ${command.description}"}
    ---
  '';

  renderClaudeMarkdown = command: ''
    ${lib.trim (renderClaudeFrontmatter command)}

    ${lib.trim command.prompt}
  '';

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

  toClaudeMarkdown = lib.mapAttrs (_name: renderClaudeMarkdown) normalizedCommands;

  toOpenCodeMarkdown = lib.mapAttrs (_name: renderOpenCodeMarkdown) normalizedCommands;

  toGeminiCommands =
    lib.mapAttrs (
      _name: command: {
        inherit (command) prompt;
        description = command.description or "AI command";
      }
    )
    normalizedCommands;
in {
  inherit
    normalizedCommands
    toClaudeMarkdown
    toOpenCodeMarkdown
    toGeminiCommands
    ;
}
