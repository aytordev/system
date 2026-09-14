# Hunk theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. Sora ships an official
# Hunk theme (`extras/hunk/sora.toml`); Kanagawa ships none, so the palette
# generates the `[custom_theme]` block. A malformed integration is passed
# through to `resolveApp` so the declaration fails loudly.
#
# Hunk embeds the theme in `~/.config/hunk/config.toml` (`theme = "custom"` plus
# a `[custom_theme]` table). Diff backgrounds are not palette roles, so the
# generated path blends green/red/cyan/violet over the background (the same
# approach as git-delta) instead of adding roles to the theme contract.
{
  lib,
  resolveApp,
}: rec {
  # Stable id/label for the generated block. Never collides with a vendored id.
  generatedId = "aytordev";

  # Vendored official `[custom_theme]` blocks, keyed by the integration id
  # declared in the provider. The top-level `theme` selection is emitted by
  # `configText`, not the vendored file, so Home-Manager-owned keys compose.
  officialThemes = {
    sora = ./themes/sora.toml;
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let the generated block win. Malformed integrations pass through so
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
      app = "hunk";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Mix `tint` into `base` (both `#rrggbb`) by `ratio` (0..1) and return
  # `#rrggbb`. Copied from the delta adapter so both keep the same tint math.
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

  # Palette (and ANSI table when available) -> generated `[custom_theme]` block.
  # Mirrors the exact keys the upstream port defines so official and generated
  # resources stay interchangeable.
  render = {
    palette,
    ansi ? null,
  }: let
    ansiColor = group: slot: fallback:
      if ansi == null
      then fallback
      else ansi.${group}.${slot}.hex;

    semantic = [
      {
        key = "background";
        value = palette.bg.hex;
      }
      {
        key = "panel";
        value = palette.bg_dim.hex;
      }
      {
        key = "panelAlt";
        value = palette.bg_float.hex;
      }
      {
        key = "border";
        value = palette.border.hex;
      }
      {
        key = "accent";
        value = palette.accent.hex;
      }
      {
        key = "accentMuted";
        value = palette.accent_dim.hex;
      }
      {
        key = "text";
        value = palette.fg.hex;
      }
      {
        key = "muted";
        value = palette.fg_dim.hex;
      }
      {
        key = "addedBg";
        value = blend palette.bg.hex palette.green.hex 0.10;
      }
      {
        key = "removedBg";
        value = blend palette.bg.hex palette.red.hex 0.10;
      }
      {
        key = "movedAddedBg";
        value = blend palette.bg.hex palette.cyan.hex 0.10;
      }
      {
        key = "movedRemovedBg";
        value = blend palette.bg.hex palette.violet.hex 0.10;
      }
      {
        key = "contextBg";
        value = palette.bg.hex;
      }
      {
        key = "addedContentBg";
        value = blend palette.bg.hex palette.green.hex 0.20;
      }
      {
        key = "removedContentBg";
        value = blend palette.bg.hex palette.red.hex 0.20;
      }
      {
        key = "contextContentBg";
        value = palette.bg_dim.hex;
      }
      {
        key = "addedSignColor";
        value = palette.green.hex;
      }
      {
        key = "removedSignColor";
        value = palette.red.hex;
      }
      {
        key = "lineNumberBg";
        value = palette.bg_dim.hex;
      }
      {
        key = "lineNumberFg";
        value = palette.fg_dim.hex;
      }
      {
        key = "selectedHunk";
        value = palette.bg_visual.hex;
      }
      {
        key = "badgeAdded";
        value = palette.green.hex;
      }
      {
        key = "badgeRemoved";
        value = palette.red.hex;
      }
      {
        key = "badgeNeutral";
        value = palette.accent_dim.hex;
      }
      {
        key = "fileNew";
        value = palette.green.hex;
      }
      {
        key = "fileDeleted";
        value = palette.red.hex;
      }
      {
        key = "fileRenamed";
        value = palette.accent.hex;
      }
      {
        key = "fileModified";
        value = palette.blue.hex;
      }
      {
        key = "fileUntracked";
        value = palette.cyan.hex;
      }
      {
        key = "noteBorder";
        value = palette.violet.hex;
      }
      {
        key = "noteBackground";
        value = palette.bg_float.hex;
      }
      {
        key = "noteTitleBackground";
        value = palette.bg_visual.hex;
      }
      {
        key = "noteTitleText";
        value = palette.fg_reverse.hex;
      }
    ];

    scopes = [
      {
        scope = "source";
        value = palette.fg.hex;
      }
      {
        scope = "comment";
        value = palette.overlay.hex;
      }
      {
        scope = "punctuation.definition.comment";
        value = palette.overlay.hex;
      }
      {
        scope = "keyword";
        value = palette.violet.hex;
      }
      {
        scope = "keyword.control";
        value = palette.violet.hex;
      }
      {
        scope = "storage";
        value = palette.violet.hex;
      }
      {
        scope = "storage.type";
        value = palette.violet.hex;
      }
      {
        scope = "storage.modifier";
        value = palette.violet.hex;
      }
      {
        scope = "keyword.operator";
        value = palette.accent_dim.hex;
      }
      {
        scope = "punctuation";
        value = palette.fg_dim.hex;
      }
      {
        scope = "string";
        value = ansiColor "normal" "green" palette.green.hex;
      }
      {
        scope = "constant.numeric";
        value = palette.yellow.hex;
      }
      {
        scope = "constant.language";
        value = palette.yellow.hex;
      }
      {
        scope = "entity.name.function";
        value = palette.accent.hex;
      }
      {
        scope = "support.function";
        value = palette.accent.hex;
      }
      {
        scope = "variable.function";
        value = palette.accent.hex;
      }
      {
        scope = "entity.name.type";
        value = palette.orange.hex;
      }
      {
        scope = "entity.name.class";
        value = palette.orange.hex;
      }
      {
        scope = "support.type";
        value = palette.orange.hex;
      }
      {
        scope = "support.class";
        value = palette.orange.hex;
      }
      {
        scope = "variable";
        value = palette.fg.hex;
      }
      {
        scope = "variable.other.constant";
        value = palette.fg.hex;
      }
      {
        scope = "variable.other.property";
        value = palette.accent_dim.hex;
      }
      {
        scope = "support.variable.property";
        value = palette.accent_dim.hex;
      }
      {
        scope = "variable.parameter";
        value = palette.orange.hex;
      }
    ];

    kv = pair: "${pair.key} = \"${pair.value}\"\n";
    scope = pair: "\"${pair.scope}\" = \"${pair.value}\"\n";
  in
    "[custom_theme]\n"
    + "base = \"github-dark-default\"\n"
    + "label = \"${generatedId}\"\n\n"
    + lib.concatMapStrings kv semantic
    + "\n[custom_theme.syntax_scopes]\n"
    + lib.concatMapStrings scope scopes;

  # Full `config.toml` for a resolution: the resolved `[custom_theme]` block plus
  # the Home-Manager-owned preferences. `none` (and an unknown explicit id) emits
  # no theme selection so Hunk keeps its own default.
  configText = {
    resolution,
    generated,
  }: let
    block =
      if resolution.kind == "none"
      then null
      else if resolution.kind == "generated" || resolution.id == generatedId
      then generated
      else if builtins.hasAttr resolution.id officialThemes
      then builtins.readFile officialThemes.${resolution.id}
      else null;
    themeLine = lib.optionalString (block != null) "theme = \"custom\"\n";
    # Hunk offers to persist view changes into this file; the store symlink is
    # read-only, so disable that prompt.
    prefs = "prompt_save_view_preferences = false\n";
  in
    themeLine
    + prefs
    + (
      if block == null
      then ""
      else "\n" + block
    );
}
