# Pure VS Code theme adapter: hybrid resolution (official marketplace extension
# vs. a locally generated palette extension) plus the generated theme payload.
#
# `default.nix` builds the extension derivation with `pkgs`; this file stays
# free of `pkgs` so tests can exercise the resolution, labels and rendered theme
# JSON without a package set.
{
  lib,
  resolveApp,
}: let
  # Capitalize the first character ("dragon" -> "Dragon"). Local copy so the
  # adapter does not depend on the extended lib overlay.
  capitalize = value:
    if value == ""
    then ""
    else lib.toUpper (builtins.substring 0 1 value) + builtins.substring 1 (-1) value;

  # ANSI terminal slots in VS Code order.
  ansiSlots = [
    "black"
    "red"
    "green"
    "yellow"
    "blue"
    "magenta"
    "cyan"
    "white"
  ];

  # Fallback ANSI roles for families whose upstream publishes no ANSI table.
  ansiFallback = {
    black = "bg_dim";
    red = "red";
    green = "green";
    yellow = "yellow";
    blue = "blue";
    magenta = "violet";
    cyan = "cyan";
    white = "fg";
  };

  # Hand `resolveApp` the integration only when it covers the requested
  # variant; an incomplete family (Sora dark-only) therefore falls through to
  # the generated theme. A malformed integration still reaches `resolveApp` and
  # throws, keeping broken declarations loud.
  selectOfficial = {
    integration,
    variant,
  }:
    if integration == null
    then null
    else if !(builtins.isAttrs integration)
    then integration
    else if !(integration ? variants)
    then integration
    else if (integration.variants or {}) ? ${variant}
    then integration
    else null;
in rec {
  inherit capitalize selectOfficial;

  # Stable, collision-free identities for the generated resource.
  generatedExtensionName = family: "aytordev-${family}-vscode-theme";
  generatedThemeId = {
    family,
    variant,
  }: "aytordev-${family}-${variant}";
  generatedThemeLabel = {
    displayName,
    variant,
  }: "Aytordev ${displayName} ${capitalize variant}";

  # Resolve one variant through the shared policy: explicit override > official
  # exact (app + family + variant) > generated fallback > none.
  resolve = {
    variant,
    override ? null,
    integration ? null,
    generated ? null,
  }:
    resolveApp {
      app = "vscode";
      inherit variant override generated;
      official = selectOfficial {inherit integration variant;};
    };

  # Render a VS Code color theme derived from a variant palette and, when
  # available, its upstream ANSI table.
  render = {
    label,
    palette,
    ansi ? null,
    isLight ? false,
  }: let
    color = name: palette.${name}.hex;
    ansiColor = group: name:
      if ansi != null
      then ansi.${group}.${name}.hex
      else color ansiFallback.${name};
    ansiColorName = group: name: "terminal.ansi${lib.optionalString (group == "bright") "Bright"}${capitalize name}";
    ansiEntries =
      lib.concatMap (group: map (name: {${ansiColorName group name} = ansiColor group name;}) ansiSlots)
      [
        "normal"
        "bright"
      ];
  in {
    name = label;
    type =
      if isLight
      then "light"
      else "dark";
    colors =
      {
        # Base / chrome
        foreground = color "fg";
        focusBorder = color "accent_dim";
        "widget.shadow" = color "bg_dim";
        "selection.background" = color "selection";
        descriptionForeground = color "fg_dim";
        errorForeground = color "red";
        "textLink.foreground" = color "accent";
        "textLink.activeForeground" = color "accent";
        "button.background" = color "accent";
        "button.foreground" = color "bg";
        "dropdown.background" = color "bg_float";
        "dropdown.foreground" = color "fg";
        "input.background" = color "bg_float";
        "input.foreground" = color "fg";
        "input.border" = color "border";
        "badge.background" = color "accent";
        "badge.foreground" = color "bg";
        "progressBar.background" = color "accent";
        "list.activeSelectionBackground" = color "selection";
        "list.activeSelectionForeground" = color "fg";
        "list.hoverBackground" = color "bg_float";
        "list.focusBackground" = color "selection";
        "list.highlightForeground" = color "accent";
        "activityBar.background" = color "bg_dim";
        "activityBar.foreground" = color "accent";
        "activityBar.inactiveForeground" = color "fg_dim";
        "activityBar.border" = color "border";
        "activityBarBadge.background" = color "accent";
        "activityBarBadge.foreground" = color "bg";
        "sideBar.background" = color "bg_dim";
        "sideBar.foreground" = color "fg";
        "sideBar.border" = color "border";
        "sideBarTitle.foreground" = color "fg_dim";
        "sideBarSectionHeader.background" = color "bg_dim";
        "sideBarSectionHeader.foreground" = color "fg";
        "editorGroupHeader.tabsBackground" = color "bg_dim";
        "editorGroup.border" = color "border";
        "tab.activeBackground" = color "bg";
        "tab.activeForeground" = color "accent";
        "tab.inactiveBackground" = color "bg_dim";
        "tab.inactiveForeground" = color "fg_dim";
        "tab.border" = color "bg_dim";
        # Editor
        "editor.background" = color "bg";
        "editor.foreground" = color "fg";
        "editorLineNumber.foreground" = color "fg_dim";
        "editorLineNumber.activeForeground" = color "accent";
        "editorCursor.foreground" = color "accent";
        "editor.selectionBackground" = color "selection";
        "editor.selectionHighlightBackground" = color "bg_visual";
        "editor.inactiveSelectionBackground" = color "bg_visual";
        "editor.lineHighlightBackground" = color "bg_float";
        "editorWhitespace.foreground" = color "border";
        "editorIndentGuide.background1" = color "border";
        "editorIndentGuide.activeBackground1" = color "accent_dim";
        "editorBracketMatch.background" = color "selection";
        "editorBracketMatch.border" = color "accent";
        "editorGutter.background" = color "bg_gutter";
        "editorWidget.background" = color "bg_float";
        "editorWidget.border" = color "border";
        "editorSuggestWidget.background" = color "bg_float";
        "editorSuggestWidget.border" = color "border";
        "editorSuggestWidget.selectedBackground" = color "selection";
        "editorHoverWidget.background" = color "bg_float";
        "editorHoverWidget.border" = color "border";
        "editorError.foreground" = color "red";
        "editorWarning.foreground" = color "yellow";
        "editorInfo.foreground" = color "blue";
        "editorHint.foreground" = color "fg_dim";
        "editorOverviewRuler.border" = color "bg_dim";
        "peekView.border" = color "accent";
        "peekViewEditor.background" = color "bg_dim";
        "peekViewResult.background" = color "bg_float";
        # Panel / status / title
        "panel.background" = color "bg_dim";
        "panel.border" = color "border";
        "panelTitle.activeForeground" = color "fg";
        "panelTitle.inactiveForeground" = color "fg_dim";
        "statusBar.background" = color "bg_dim";
        "statusBar.foreground" = color "fg";
        "statusBar.border" = color "border";
        "statusBar.noFolderBackground" = color "bg_dim";
        "statusBar.debuggingBackground" = color "red";
        "statusBar.debuggingForeground" = color "bg";
        "titleBar.activeBackground" = color "bg_dim";
        "titleBar.activeForeground" = color "fg";
        "titleBar.inactiveBackground" = color "bg_dim";
        "titleBar.inactiveForeground" = color "fg_dim";
        "titleBar.border" = color "border";
        "menu.background" = color "bg_float";
        "menu.foreground" = color "fg";
        "menu.selectionBackground" = color "selection";
        "quickInput.background" = color "bg_float";
        "quickInput.foreground" = color "fg";
        # Terminal
        "terminal.background" = color "bg";
        "terminal.foreground" = color "fg";
        "terminalCursor.foreground" = color "accent";
        "terminal.selectionBackground" = color "selection";
        # Git
        "gitDecoration.addedResourceForeground" = color "green";
        "gitDecoration.modifiedResourceForeground" = color "yellow";
        "gitDecoration.deletedResourceForeground" = color "red";
        "gitDecoration.untrackedResourceForeground" = color "cyan";
        "gitDecoration.ignoredResourceForeground" = color "fg_dim";
      }
      // lib.foldl' (acc: entry: acc // entry) {} ansiEntries;
    # Force VS Code to prefer LSP semantic tokens over TextMate where the
    # language server provides them; the categories mirror Zed's syntax so the
    # two editors agree.
    semanticHighlighting = true;
    semanticTokenColors = {
      comment = {
        foreground = color "overlay";
        fontStyle = "italic";
      };
      keyword = {
        foreground = color "violet";
        fontStyle = "italic";
      };
      modifier = color "violet";
      macro = color "violet";
      string = ansiColor "normal" "green";
      number = color "yellow";
      regexp = color "cyan";
      operator = color "accent_dim";
      namespace = color "orange";
      type = color "orange";
      typeParameter = color "orange";
      class = color "orange";
      struct = color "orange";
      interface = color "orange";
      enum = color "orange";
      enumMember = color "orange";
      parameter = color "orange";
      decorator = color "orange";
      variable = color "fg";
      "variable.readonly" = color "fg";
      property = color "accent_dim";
      "property.readonly" = color "accent_dim";
      function = color "accent";
      method = color "accent";
      event = color "accent";
    };

    # TextMate fallback for languages without semantic tokens. The categories
    # and colors are the Zed Sora `syntax` block translated to VS Code scopes.
    tokenColors = [
      {
        settings.foreground = color "fg";
      }
      {
        name = "Comment";
        scope = [
          "comment"
          "punctuation.definition.comment"
        ];
        settings = {
          foreground = color "overlay";
          fontStyle = "italic";
        };
      }
      {
        name = "Keyword";
        scope = [
          "keyword"
          "keyword.control"
          "storage"
          "storage.type"
          "storage.modifier"
        ];
        settings = {
          foreground = color "violet";
          fontStyle = "italic";
        };
      }
      {
        name = "Preprocessor";
        scope = [
          "meta.preprocessor"
          "keyword.control.import"
          "keyword.control.directive"
        ];
        settings.foreground = color "violet";
      }
      {
        name = "Function";
        scope = [
          "entity.name.function"
          "entity.name.function.method"
          "support.function"
          "meta.function-call"
          "meta.method-call"
        ];
        settings.foreground = color "accent";
      }
      {
        name = "Function builtin";
        scope = [
          "support.function.builtin"
          "support.function.magic"
        ];
        settings = {
          foreground = color "accent";
          fontStyle = "italic";
        };
      }
      {
        name = "Constructor";
        scope = [
          "entity.name.function.constructor"
          "meta.constructor"
        ];
        settings = {
          foreground = color "orange";
          fontStyle = "bold";
        };
      }
      {
        name = "Type";
        scope = [
          "entity.name.type"
          "entity.name.class"
          "entity.name.struct"
          "entity.name.enum"
          "entity.name.union"
          "entity.name.trait"
          "entity.name.interface"
          "entity.name.namespace"
          "support.type"
          "support.class"
        ];
        settings.foreground = color "orange";
      }
      {
        name = "Type builtin";
        scope = [
          "support.type.builtin"
          "support.class.builtin"
        ];
        settings = {
          foreground = color "orange";
          fontStyle = "italic";
        };
      }
      {
        name = "Enum / variant";
        scope = [
          "entity.name.enum"
          "entity.name.variant"
          "constant.other.enum"
        ];
        settings.foreground = color "orange";
      }
      {
        name = "Number";
        scope = [
          "constant.numeric"
          "constant.character"
          "constant.other"
        ];
        settings.foreground = color "yellow";
      }
      {
        name = "Boolean";
        scope = [
          "constant.language"
          "constant.language.boolean"
        ];
        settings = {
          foreground = color "pink";
          fontStyle = "italic";
        };
      }
      {
        name = "Constant";
        scope = ["constant"];
        settings.foreground = color "yellow";
      }
      {
        name = "String";
        scope = [
          "string"
          "string.quoted"
          "string.template"
          "constant.other.symbol"
        ];
        settings.foreground = ansiColor "normal" "green";
      }
      {
        name = "String escape / special";
        scope = [
          "string.regexp"
          "string.escape"
          "constant.character.escape"
          "string.special"
        ];
        settings.foreground = color "cyan";
      }
      {
        name = "String symbol";
        scope = ["string.special.symbol"];
        settings.foreground = color "yellow";
      }
      {
        name = "Markup raw / literal";
        scope = [
          "markup.raw"
          "markup.inline.raw"
          "text.literal"
        ];
        settings.foreground = ansiColor "normal" "green";
      }
      {
        name = "Operator";
        scope = ["keyword.operator"];
        settings.foreground = color "accent_dim";
      }
      {
        name = "Punctuation";
        scope = [
          "punctuation"
          "punctuation.separator"
          "punctuation.terminator"
          "punctuation.definition"
          "punctuation.section"
          "meta.brace"
        ];
        settings.foreground = color "fg_dim";
      }
      {
        name = "Tag";
        scope = [
          "entity.name.tag"
          "meta.tag"
        ];
        settings.foreground = color "cyan";
      }
      {
        name = "Tag attribute";
        scope = ["entity.other.attribute-name"];
        settings = {
          foreground = color "orange";
          fontStyle = "italic";
        };
      }
      {
        name = "Property";
        scope = [
          "variable.other.member"
          "variable.other.property"
          "support.type.property-name"
          "meta.object-literal.key"
          "entity.name.tag.yaml"
        ];
        settings.foreground = color "accent_dim";
      }
      {
        name = "Variable parameter";
        scope = ["variable.parameter"];
        settings.foreground = color "orange";
      }
      {
        name = "Variable language";
        scope = [
          "variable.language"
          "variable.language.this"
          "variable.language.self"
          "variable.language.super"
        ];
        settings = {
          foreground = color "pink";
          fontStyle = "italic";
        };
      }
      {
        name = "Variable";
        scope = [
          "variable"
          "variable.other"
          "meta.definition.variable"
        ];
        settings.foreground = color "fg";
      }
      {
        name = "Link";
        scope = [
          "markup.underline.link"
          "string.other.link"
          "constant.other.reference.link"
        ];
        settings.foreground = color "accent";
      }
      {
        name = "Heading";
        scope = [
          "markup.heading"
          "entity.name.section"
        ];
        settings = {
          foreground = color "accent";
          fontStyle = "bold";
        };
      }
      {
        name = "Emphasis";
        scope = ["markup.italic"];
        settings = {
          foreground = color "fg_reverse";
          fontStyle = "italic";
        };
      }
      {
        name = "Strong";
        scope = ["markup.bold"];
        settings = {
          foreground = color "fg_reverse";
          fontStyle = "bold";
        };
      }
      {
        name = "Invalid";
        scope = [
          "invalid"
          "invalid.illegal"
        ];
        settings.foreground = color "red";
      }
    ];
  };

  # One generated theme contribution: the manifest entry plus the JSON payload.
  mkTheme = {
    family,
    displayName,
    variant,
    palette,
    ansi ? null,
    isLight ? false,
  }: let
    label = generatedThemeLabel {inherit displayName variant;};
  in {
    inherit label;
    uiTheme =
      if isLight
      then "vs"
      else "vs-dark";
    path = "./themes/${generatedThemeId {inherit family variant;}}-color-theme.json";
    json = render {
      inherit
        label
        palette
        ansi
        isLight
        ;
    };
  };

  # The generated extension package.json. Theme paths are relative to the
  # extension root, matching `buildVscodeExtension`'s install layout.
  manifest = {
    family,
    displayName,
    themes,
  }: {
    name = generatedExtensionName family;
    displayName = "Aytordev ${displayName}";
    description = "Aytordev ${displayName} color themes generated from the shared aytordev palette.";
    publisher = "aytordev";
    version = "1.0.0";
    engines.vscode = "*";
    categories = ["Themes"];
    contributes.themes =
      map (theme: {
        inherit (theme) label uiTheme path;
      })
      themes;
  };

  # Whether any resolution selected the generated resource.
  needsGenerated = resolutions: builtins.any (resolution: resolution.kind == "generated") resolutions;

  # Compose a profile's extension list. The generated extension is installed
  # only for a generated selection, mirroring the resolver's precedence.
  profileExtensions = {
    base ? [],
    resolutions,
    generatedExtension,
  }:
    base ++ lib.optional (needsGenerated resolutions) generatedExtension;
}
