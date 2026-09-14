{
  lib,
  pkgs,
  inputs,
  ...
}: let
  # The ai-tools renderers call `lib.importSubdirs`, which only exists on the
  # extended aytordev lib.
  extendedLib = lib.extend inputs.self.lib.overlay;
  aiTools = import ../../modules/common/ai-tools {lib = extendedLib;};

  renderFixture = aiTools._internal.renderCommand;

  # Attrset command: a description that breaks unquoted YAML, a legacy argument
  # marker, and the unsupported OpenCode fields.
  colonCommand = {
    description = "Review: focused checks";
    agent = "sdd-orchestrator";
    allowedTools = "Read, Grep";
    argumentHint = "[topic]";
    prompt = "Explore the topic: {argument}";
  };

  # Quotes and Unicode must survive YAML encoding.
  quotedCommand = {
    description = ''Review "quoted": ünïcode ✓'';
    prompt = "Body";
  };

  # Canonical marker must pass through untouched.
  markerCommand = {prompt = "Topic: $ARGUMENTS";};

  # Braces other than the legacy marker are not shell/marker syntax.
  bracesCommand = {prompt = "Literal {not_a_marker} stays.";};

  # Legacy string command whose body contains a Markdown `---` separator.
  stringCommand = ''
    ---
    description: Review: focused checks
    ---
    First section

    ---

    Trailing section
  '';

  colonRendered = renderFixture "colon" colonCommand;
  quotedRendered = renderFixture "quoted" quotedCommand;
  markerRendered = renderFixture "marker" markerCommand;
  bracesRendered = renderFixture "braces" bracesCommand;
  stringRendered = renderFixture "string-fixture" stringCommand;

  orchestrator = aiTools.opencode.agents.sdd-orchestrator;

  countDelimiters = text: lib.count (line: line == "---") (lib.splitString "\n" text);

  realCommands = lib.attrValues aiTools.opencode.commands;

  checks = {
    markerRenders = lib.hasInfix "Explore the topic: $ARGUMENTS" colonRendered;
    canonicalMarkerPasses = lib.hasInfix "Topic: $ARGUMENTS" markerRendered;
    legacyMarkerGone = !(lib.hasInfix "{argument}" colonRendered);
    noRealCommandKeepsLegacyMarker = !(lib.any (c: lib.hasInfix "{argument}" c) realCommands);
    colonDescriptionQuoted = lib.hasInfix ''description: "Review: focused checks"'' colonRendered;
    quotedDescriptionEscaped =
      lib.hasInfix ("description: " + builtins.toJSON quotedCommand.description) quotedRendered;
    bodySeparatorPreserved =
      lib.hasInfix "First section" stringRendered && lib.hasInfix "Trailing section" stringRendered;
    bodySeparatorCount = countDelimiters stringRendered == 3;
    stringDescriptionQuoted = lib.hasInfix ''description: "Review: focused checks"'' stringRendered;
    literalBracesPreserved = lib.hasInfix "Literal {not_a_marker} stays." bracesRendered;
    unsupportedFieldsReported =
      aiTools.opencode.commandUnsupportedFields.sdd-apply == ["allowedTools" "argumentHint"];
    agentModePrimary = orchestrator.mode == "primary";
    agentPermissionMapped =
      orchestrator.permission
      == {
        edit = "ask";
        bash = "ask";
      };
    agentHasNoDeprecatedTools = !(builtins.hasAttr "tools" orchestrator);
    agentModelMapped = orchestrator.model == "anthropic/claude-sonnet-4-6";
  };

  failed = lib.attrNames (lib.filterAttrs (_: ok: !ok) checks);

  colonFile = pkgs.writeText "ai-tools-colon.md" colonRendered;
  quotedFile = pkgs.writeText "ai-tools-quoted.md" quotedRendered;
  quotedExpected = pkgs.writeText "ai-tools-quoted.expected" quotedCommand.description;
  stringFile = pkgs.writeText "ai-tools-string.md" stringRendered;
in
  if failed != []
  then throw "ai-tools-renderers regression failures:\n${lib.concatStringsSep "\n" failed}"
  else
    pkgs.runCommand "ai-tools-renderers-check" {
      nativeBuildInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.yq-go
      ];
    } ''
      set -euo pipefail

      frontmatter() {
        awk 'NR == 1 && $0 == "---" { inb = 1; next }
             inb && $0 == "---" { exit }
             inb { print }' "$1"
      }

      # Frontmatter is valid YAML and round-trips a description containing a colon.
      frontmatter ${colonFile} | yq --exit-status '.description == "Review: focused checks"' > /dev/null
      frontmatter ${colonFile} | yq --exit-status '.agent == "sdd-orchestrator"' > /dev/null

      # Quotes and Unicode round-trip through YAML.
      test "$(frontmatter ${quotedFile} | yq --exit-status --unwrapScalar '.description')" = "$(cat ${quotedExpected})"

      # A body containing `---` is preserved intact: three separators, both parts.
      test "$(grep -c '^---$' ${stringFile})" -eq 3
      grep -q 'First section' ${stringFile}
      grep -q 'Trailing section' ${stringFile}
      frontmatter ${stringFile} | yq --exit-status '.description == "Review: focused checks"' > /dev/null

      touch "$out"
    ''
