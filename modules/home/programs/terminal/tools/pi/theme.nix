# Pi theme adapter
# Maps the shared semantic palette onto the Pi theme schema (vars/colors/export)
# so the TUI follows aytordev.theme instead of a vendored Kanagawa JSON.
{palette}: let
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
    green = palette.green.hex;
    warning = palette.orange.hex;
    red = palette.red.hex;
    brightBlack = palette.fg_dim.hex;
    brightGreen = palette.green.hex;
    brightYellow = palette.yellow.hex;
    brightPurple = palette.violet.hex;
    brightMagenta = palette.pink.hex;
    brightBlue = palette.accent.hex;
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
