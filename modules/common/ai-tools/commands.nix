{lib, ...}: let
  commands = lib.importSubdirs ./commands {};

  # Canonical argument marker for command definitions.
  #
  # OpenCode substitutes `$ARGUMENTS` with the full argument string (and `$1`,
  # `$2` per position); Pi supports `$ARGUMENTS`/`$@` as well. Definitions use
  # `$ARGUMENTS`; the legacy `{argument}` spelling is still normalized to it so
  # older string commands keep working. Other braces are left untouched.
  argumentMarker = "$ARGUMENTS";
  legacyArgumentMarker = "{argument}";

  normalizeArguments = text:
    lib.replaceStrings [legacyArgumentMarker] [argumentMarker] text;

  startsWithDelimiter = lines:
    lines != [] && lib.trim (builtins.head lines) == "---";

  # Split a leading `---` frontmatter block from the body. Only the first block
  # is consumed, so `---` separators inside the Markdown body survive intact.
  splitFrontmatter = text: let
    lines = lib.splitString "\n" text;
    step = front: rest:
      if rest == []
      then {
        inherit front;
        body = [];
        closed = false;
      }
      else if lib.trim (builtins.head rest) == "---"
      then {
        inherit front;
        body = lib.tail rest;
        closed = true;
      }
      else step (front ++ [(builtins.head rest)]) (lib.tail rest);
  in
    if startsWithDelimiter lines
    then step [] (lib.tail lines)
    else {
      front = [];
      body = lines;
      closed = false;
    };

  # Parse YAML frontmatter and body from the legacy string-command format. The
  # parser is non-lossy: without a closed leading block the whole document is
  # the body.
  parseCommandString = name: text: let
    split = splitFrontmatter text;
    frontLines = lib.filter (l: l != "") (builtins.map lib.trim split.front);
    getField = prefix: let
      match = lib.findFirst (l: lib.hasPrefix prefix l) null frontLines;
    in
      if match != null
      then lib.trim (lib.removePrefix prefix match)
      else null;
  in {
    commandName = name;
    description = getField "description:";
    allowedTools = getField "allowed-tools:";
    argumentHint = getField "argument-hint:";
    prompt =
      if split.closed
      then lib.concatStringsSep "\n" split.body
      else text;
  };

  # Normalize a command regardless of format (string or attrset). There is no
  # implicit agent default: a command selects its agent explicitly or leaves it
  # null, so a non-SDD command never silently routes to `sdd-orchestrator`.
  normalizeCommand = name: command: let
    parsed =
      if builtins.isString command
      then parseCommandString name command
      else command;
    agent = parsed.agent or null;
  in {
    commandName = parsed.commandName or name;
    description = parsed.description or null;
    allowedTools = parsed.allowedTools or null;
    argumentHint = parsed.argumentHint or null;
    prompt = normalizeArguments (parsed.prompt or "");
    inherit agent;
  };

  normalizedCommands = lib.mapAttrs normalizeCommand commands;

  # Fields OpenCode command frontmatter cannot express. They stay in the shared
  # definition for other clients; `unsupportedOpenCodeFields` reports them and
  # `toOpenCodeMarkdown` surfaces a warning instead of dropping them silently.
  unsupportedForOpenCode = command:
    lib.filter (field: command.${field} != null) ["allowedTools" "argumentHint"];

  unsupportedOpenCodeFields = lib.mapAttrs (_: unsupportedForOpenCode) normalizedCommands;
  unsupportedReport = lib.filterAttrs (_: fields: fields != []) unsupportedOpenCodeFields;

  # JSON string literals are valid YAML, so a description such as
  # `Review: focused checks` that would break unquoted YAML parses correctly.
  yamlString = builtins.toJSON;

  renderOpenCodeFrontmatter = command: let
    lines =
      lib.optional (command.description != null) "description: ${yamlString command.description}"
      ++ lib.optional (command.agent != null) "agent: ${yamlString command.agent}";
  in
    lib.concatStringsSep "\n" (["---"] ++ lines ++ ["---"]);

  # Preserve the body verbatim (including Markdown `---`) apart from outer trim.
  renderOpenCodeMarkdown = command:
    lib.concatStringsSep "\n\n" [
      (renderOpenCodeFrontmatter command)
      (lib.trim command.prompt)
    ];

  renderCommand = name: command: renderOpenCodeMarkdown (normalizeCommand name command);

  toOpenCodeMarkdown =
    lib.warnIf (unsupportedReport != {})
    ("OpenCode command rendering cannot express: "
      + lib.concatStringsSep "; " (
        lib.mapAttrsToList (name: fields: "${name}: ${lib.concatStringsSep ", " fields}") unsupportedReport
      ))
    (lib.mapAttrs (_: renderOpenCodeMarkdown) normalizedCommands);
in {
  inherit
    normalizedCommands
    parseCommandString
    normalizeCommand
    renderCommand
    unsupportedOpenCodeFields
    toOpenCodeMarkdown
    ;
}
