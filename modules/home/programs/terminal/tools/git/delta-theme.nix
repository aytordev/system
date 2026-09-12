# git-delta theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. Sora ships an official
# delta gitconfig (`extras/delta/sora.gitconfig`); its style options are
# transcribed below. Any other family — or Sora's synthetic light variant, which
# no integration covers — gets styles generated from the shared palette.
#
# Delta's plus/minus backgrounds are not palette roles; the generated path mixes
# the palette's green/red over the background so the tinted look survives without
# adding roles to the theme contract. `syntax-theme` is supplied by the caller
# from the active bat theme, since delta reuses bat's syntax highlighting.
{
  lib,
  resolveApp,
}: rec {
  # Stable id for the palette-generated style set. Never collides with a
  # vendored official id.
  generatedId = "aytordev";

  # Vendored official delta style sets, keyed by the provider integration id.
  #   Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439,
  #     `extras/delta/sora.gitconfig`, transcribed.
  officialThemes = {
    sora = {
      minus-style = "syntax #1c1014";
      minus-emph-style = "syntax bold #2a1420";
      plus-style = "syntax #0e1c16";
      plus-emph-style = "syntax bold #142c1c";
      hunk-header-style = "#9aa4b8 italic";
      hunk-header-decoration-style = "#364050 box";
      file-style = "#80c8e0 bold";
      file-decoration-style = "#80c8e0 ul";
      line-numbers-minus-style = "#c46c78";
      line-numbers-plus-style = "#68b080";
      line-numbers-zero-style = "#364050";
      line-numbers-left-style = "#364050";
      line-numbers-right-style = "#364050";
      commit-decoration-style = "#80c8e0 box";
      commit-style = "#d4b878 bold";
      blame-palette = "#0e1018 #14161e #171a24 #1e2430";
    };
  };

  # Mix `tint` into `base` (both `#rrggbb`) by `ratio` (0..1) and return
  # `#rrggbb`.
  blend = base: tint: ratio: let
    digits = {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
      "A" = 10;
      "B" = 11;
      "C" = 12;
      "D" = 13;
      "E" = 14;
      "F" = 15;
    };
    byte = s: lib.foldl' (acc: c: acc * 16 + digits.${c}) 0 (lib.stringToCharacters s);
    channel = offset: hex: byte (builtins.substring offset 2 hex);
    mix = a: b: builtins.floor (a * (1.0 - ratio) + b * ratio + 0.5);
    hexDigits = "0123456789abcdef";
    toByte = n: builtins.substring (n / 16) 1 hexDigits + builtins.substring (lib.mod n 16) 1 hexDigits;
  in
    "#"
    + lib.concatStrings [
      (toByte (mix (channel 1 base) (channel 1 tint)))
      (toByte (mix (channel 3 base) (channel 3 tint)))
      (toByte (mix (channel 5 base) (channel 5 tint)))
    ];

  # Palette -> delta style options (generated fallback).
  render = {palette}: {
    minus-style = "syntax ${blend palette.bg.hex palette.red.hex 0.12}";
    minus-emph-style = "syntax bold ${blend palette.bg.hex palette.red.hex 0.22}";
    plus-style = "syntax ${blend palette.bg.hex palette.green.hex 0.12}";
    plus-emph-style = "syntax bold ${blend palette.bg.hex palette.green.hex 0.22}";
    hunk-header-style = "${palette.fg_dim.hex} italic";
    hunk-header-decoration-style = "${palette.border.hex} box";
    file-style = "${palette.accent.hex} bold";
    file-decoration-style = "${palette.accent.hex} ul";
    line-numbers-minus-style = palette.red.hex;
    line-numbers-plus-style = palette.green.hex;
    line-numbers-zero-style = palette.border.hex;
    line-numbers-left-style = palette.border.hex;
    line-numbers-right-style = palette.border.hex;
    commit-decoration-style = "${palette.accent.hex} box";
    commit-style = "${palette.yellow.hex} bold";
    blame-palette = "${palette.bg.hex} ${palette.bg_float.hex} ${palette.bg_gutter.hex} ${palette.bg_visual.hex}";
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise generation wins. Malformed integrations pass through so
  # `resolveApp` can report them.
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

  resolve = {
    variant,
    override ? null,
    integration ? null,
  }:
    resolveApp {
      app = "delta";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Delta style options for a resolution (`none` emits nothing; an unknown
  # explicit id also emits nothing rather than inventing a theme).
  optionsFor = {
    resolution,
    palette,
  }:
    if resolution.kind == "none"
    then {}
    else if resolution.id == generatedId
    then render {inherit palette;}
    else officialThemes.${resolution.id} or {};
}
