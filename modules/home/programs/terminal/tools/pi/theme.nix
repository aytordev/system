# Pi theme adapter
# Maps the shared semantic palette onto the Pi theme schema (vars/colors/export)
# so the TUI follows aytordev.theme instead of a vendored Kanagawa JSON.
#
# The schema's ANSI-named slots (brightBlack/brightGreen/brightYellow/
# brightPurple/brightMagenta/brightBlue plus green/red) are filled from the
# active variant's retained ANSI table so generated themes stay faithful to
# upstream terminal colors. Callers that render without an ANSI table (e.g.
# palette-only unit tests) fall back to the semantic palette.
{
  palette,
  ansi ? null,
}: let
  ansiColor = group: slot: fallback:
    if ansi == null
    then fallback
    else ansi.${group}.${slot}.hex;

  vars = {
    bg = palette.bg.hex;
    bgPanel = palette.bg.hex;
    bgElement = palette.bg_float.hex;
    bgSubtle = palette.bg_dim.hex;
    surfaceLine = palette.bg.hex;
    border = palette.border.hex;
    borderSubtle = palette.border.hex;
    text = palette.fg.hex;
    muted = palette.fg_dim.hex;
    dim = palette.fg_dim.hex;
    disabled = palette.fg_dim.hex;
    accent = palette.accent.hex;
    blue = palette.accent.hex;
    secondary = palette.violet.hex;
    heading = palette.fg_reverse.hex;
    syntaxComment = palette.fg_dim.hex;
    syntaxKeyword = palette.pink.hex;
    syntaxFunction = palette.yellow_bright.hex;
    syntaxString = palette.yellow.hex;
    syntaxNumber = palette.blue_bright.hex;
    syntaxType = palette.blue_bright.hex;
    syntaxPunctuation = palette.fg_dim.hex;
    green = ansiColor "normal" "green" palette.green.hex;
    warning = palette.orange.hex;
    red = ansiColor "normal" "red" palette.red.hex;
    brightBlack = ansiColor "bright" "black" palette.fg_dim.hex;
    brightGreen = ansiColor "bright" "green" palette.green.hex;
    brightYellow = ansiColor "bright" "yellow" palette.yellow.hex;
    brightPurple = ansiColor "bright" "magenta" palette.violet.hex;
    brightMagenta = ansiColor "bright" "magenta" palette.pink.hex;
    brightBlue = ansiColor "bright" "blue" palette.accent.hex;
    selection = palette.selection.hex;
    toolSuccessBg = palette.bg.hex;
    toolPendingBg = palette.bg_float.hex;
    toolErrorBg = palette.border.hex;
    infoBg = palette.bg.hex;
  };

  # Role -> var references. Stable across families; only `vars` changes.
  colors = {
    accent = "blue";
    border = "border";
    borderAccent = "blue";
    borderMuted = "borderSubtle";
    success = "green";
    error = "red";
    warning = "warning";
    muted = "muted";
    dim = "dim";
    text = "text";
    thinkingText = "muted";
    selectedBg = "selection";
    userMessageBg = "bgElement";
    userMessageText = "text";
    customMessageBg = "bgSubtle";
    customMessageText = "text";
    customMessageLabel = "blue";
    toolPendingBg = "toolPendingBg";
    toolSuccessBg = "toolSuccessBg";
    toolErrorBg = "toolErrorBg";
    toolTitle = "blue";
    toolOutput = "text";
    mdHeading = "heading";
    mdLink = "blue";
    mdLinkUrl = "muted";
    mdCode = "green";
    mdCodeBlock = "text";
    mdCodeBlockBorder = "borderSubtle";
    mdQuote = "warning";
    mdQuoteBorder = "borderSubtle";
    mdHr = "muted";
    mdListBullet = "blue";
    toolDiffAdded = "green";
    toolDiffRemoved = "red";
    toolDiffContext = "muted";
    syntaxComment = "syntaxComment";
    syntaxKeyword = "syntaxKeyword";
    syntaxFunction = "syntaxFunction";
    syntaxVariable = "text";
    syntaxString = "syntaxString";
    syntaxNumber = "syntaxNumber";
    syntaxType = "syntaxType";
    syntaxOperator = "warning";
    syntaxPunctuation = "syntaxPunctuation";
    thinkingOff = "borderSubtle";
    thinkingMinimal = "dim";
    thinkingLow = "muted";
    thinkingMedium = "blue";
    thinkingHigh = "blue";
    thinkingXhigh = "secondary";
    bashMode = "blue";
  };
in {
  "$schema" = "https://raw.githubusercontent.com/earendil-works/pi-mono/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
  name = "aytordev";
  inherit vars colors;
  export = {
    pageBg = "bg";
    cardBg = "bgElement";
    infoBg = "infoBg";
  };
}
