# Locally generated Pi theme. Gentle's semantic role structure is mapped onto
# the shared palette; no upstream theme file or family-specific color is copied.
# Gentle Shell also uses toolSuccessBg for informational cards and its prompt,
# so tool surfaces deliberately stay neutral, including error panels.
{
  palette,
  isLight,
}: {
  name = "aytordev";
  appearance =
    if isLight
    then "light"
    else "dark";
  vars = builtins.mapAttrs (_: color: color.hex) {
    inherit (palette) bg;
    bgPanel = palette.bg_float;
    bgElement = palette.bg_float;
    userMessageBg = palette.bg_visual;
    inherit (palette) border;
    borderSubtle = palette.bg_gutter;
    text = palette.fg;
    muted = palette.fg_dim;
    dim = palette.overlay;
    inherit (palette) accent;
    activeAccent = palette.blue_bright;
    purple = palette.violet;
    inherit (palette) green;
    gold = palette.yellow;
    peach = palette.orange;
    teal = palette.cyan;
    steel = palette.accent_dim;
    warning = palette.yellow;
    error = palette.red;
    inherit (palette) selection;
  };
  colors = {
    accent = "accent";
    border = "border";
    borderAccent = "activeAccent";
    borderMuted = "borderSubtle";
    success = "green";
    error = "error";
    warning = "warning";
    muted = "muted";
    dim = "dim";
    text = "text";
    thinkingText = "muted";
    selectedBg = "selection";
    scrollbarTrack = "borderSubtle";
    scrollbarThumb = "steel";
    searchMatchBg = "selection";
    searchMatchText = "text";
    userMessageBg = "userMessageBg";
    userMessageText = "text";
    customMessageBg = "bgPanel";
    customMessageText = "text";
    customMessageLabel = "accent";
    toolPendingBg = "bgPanel";
    toolSuccessBg = "bgPanel";
    toolErrorBg = "bgPanel";
    toolTitle = "accent";
    toolOutput = "text";
    mdHeading = "gold";
    mdLink = "accent";
    mdLinkUrl = "muted";
    mdCode = "teal";
    mdCodeBlock = "text";
    mdCodeBlockBorder = "border";
    mdQuote = "muted";
    mdQuoteBorder = "steel";
    mdHr = "borderSubtle";
    mdListBullet = "accent";
    toolDiffAdded = "green";
    toolDiffRemoved = "error";
    toolDiffContext = "muted";
    syntaxComment = "muted";
    syntaxKeyword = "purple";
    syntaxFunction = "accent";
    syntaxVariable = "text";
    syntaxString = "green";
    syntaxNumber = "peach";
    syntaxType = "gold";
    syntaxOperator = "teal";
    syntaxPunctuation = "muted";
    thinkingOff = "borderSubtle";
    thinkingMinimal = "dim";
    thinkingLow = "muted";
    thinkingMedium = "steel";
    thinkingHigh = "purple";
    thinkingXhigh = "accent";
    thinkingMax = "activeAccent";
    bashMode = "accent";
  };
  export = {
    pageBg = "bg";
    cardBg = "bgElement";
    infoBg = "bgPanel";
  };
}
