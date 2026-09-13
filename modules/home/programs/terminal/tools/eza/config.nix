# Eza theme adapter: hybrid resolution.
#
# `resolve` implements the policy **explicit override > official exact
# (app + family + variant) > generated fallback > none**. Eza (0.23.x) reads a
# single `theme.yml` from `$EZA_CONFIG_DIR` or, by default,
# `$XDG_CONFIG_HOME/eza/`, overlaying it on its built-in defaults; `EZA_COLORS`
# still wins over the file for any key it sets.
#
# Sora ships an `EZA_COLORS` shell fragment (`extras/eza/sora.sh`); its
# two-letter codes are expanded to the equivalent `theme.yml` fields and
# vendored as `themes/sora.yml`, leaving unset fields at eza's defaults.
# A family may cover only some variants (Sora is dark-only); an integration
# that does not cover the active variant is treated as absent so generation
# takes over. A malformed integration still reaches `resolveApp` and throws,
# keeping broken declarations loud.
{
  lib,
  resolveApp,
}: rec {
  # Stable id for the palette-generated theme. Never collides with a vendored
  # theme id.
  generatedId = "aytordev";

  # Vendored official theme files, keyed by the provider integration id.
  #   Aejkatappaja/sora @ 504df4913c55dd9ad658e331b172f86b0537b439,
  #     `extras/eza/sora.sh`, expanded to `theme.yml` fields.
  officialThemes = {
    sora = ./themes/sora.yml;
  };

  # Every id an explicit override may name: the vendored resources plus the
  # generated theme.
  themeIds = lib.attrNames officialThemes ++ [generatedId];

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise let generation win. Malformed integrations pass through so
  # `resolveApp` can report them.
  selectOfficial = {
    integration,
    variant,
  }:
    if integration == null
    then null
    else if !(lib.isAttrs integration)
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
      app = "eza";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Palette + ANSI -> eza `theme.yml` map. Semantic roles come from the shared
  # palette; the file-type categories, which eza derives from its built-in ANSI
  # table, come from the variant's ANSI slots.
  render = {
    palette,
    ansi,
  }: {
    filekinds = {
      normal.foreground = palette.fg.hex;
      directory.foreground = palette.accent.hex;
      symlink.foreground = palette.cyan.hex;
      pipe.foreground = ansi.normal.yellow.hex;
      block_device.foreground = ansi.normal.yellow.hex;
      char_device.foreground = ansi.normal.yellow.hex;
      socket.foreground = palette.red.hex;
      special.foreground = palette.violet.hex;
      executable.foreground = palette.green.hex;
      mount_point.foreground = palette.accent.hex;
    };
    perms = {
      user_read.foreground = palette.yellow.hex;
      user_write.foreground = palette.red.hex;
      user_execute_file.foreground = palette.green.hex;
      user_execute_other.foreground = palette.green.hex;
      group_read.foreground = palette.yellow.hex;
      group_write.foreground = palette.red.hex;
      group_execute.foreground = palette.green.hex;
      other_read.foreground = palette.yellow.hex;
      other_write.foreground = palette.red.hex;
      other_execute.foreground = palette.green.hex;
      special_user_file.foreground = palette.violet.hex;
      special_other.foreground = palette.fg_dim.hex;
      attribute.foreground = palette.cyan.hex;
    };
    size = {
      major.foreground = palette.blue.hex;
      minor.foreground = palette.cyan.hex;
      number_byte.foreground = palette.fg_dim.hex;
      number_kilo.foreground = palette.fg_dim.hex;
      number_mega.foreground = palette.blue.hex;
      number_giga.foreground = palette.violet.hex;
      number_huge.foreground = palette.violet.hex;
      unit_byte.foreground = palette.fg_dim.hex;
      unit_kilo.foreground = palette.cyan.hex;
      unit_mega.foreground = palette.violet.hex;
      unit_giga.foreground = palette.violet.hex;
      unit_huge.foreground = palette.cyan.hex;
    };
    users = {
      user_you.foreground = palette.fg.hex;
      user_root.foreground = palette.red.hex;
      user_other.foreground = palette.orange.hex;
      group_yours.foreground = palette.fg_dim.hex;
      group_other.foreground = palette.fg_dim.hex;
      group_root.foreground = palette.red.hex;
    };
    links = {
      normal.foreground = palette.blue.hex;
      multi_link_file.foreground = palette.cyan.hex;
    };
    git = {
      new.foreground = ansi.normal.green.hex;
      modified.foreground = ansi.normal.yellow.hex;
      deleted.foreground = ansi.normal.red.hex;
      renamed.foreground = ansi.normal.cyan.hex;
      typechange.foreground = ansi.normal.magenta.hex;
      ignored.foreground = palette.fg_dim.hex;
      conflicted.foreground = palette.orange.hex;
    };
    git_repo = {
      branch_main.foreground = palette.fg_dim.hex;
      branch_other.foreground = palette.accent.hex;
      git_clean.foreground = palette.green.hex;
      git_dirty.foreground = palette.red.hex;
    };
    file_type = {
      image.foreground = ansi.normal.magenta.hex;
      video.foreground = ansi.normal.magenta.hex;
      music.foreground = ansi.normal.blue.hex;
      lossless.foreground = ansi.normal.cyan.hex;
      crypto.foreground = ansi.normal.green.hex;
      document.foreground = ansi.normal.green.hex;
      compressed.foreground = ansi.normal.red.hex;
      temp.foreground = palette.fg_dim.hex;
      compiled.foreground = ansi.normal.yellow.hex;
      build.foreground = ansi.normal.yellow.hex;
      source.foreground = ansi.normal.yellow.hex;
    };
    punctuation.foreground = palette.fg_dim.hex;
    date.foreground = palette.yellow.hex;
    inode.foreground = palette.fg_dim.hex;
    blocks.foreground = palette.fg_dim.hex;
    header.foreground = palette.fg.hex;
    octal.foreground = palette.cyan.hex;
    flags.foreground = palette.accent.hex;
    symlink_path.foreground = palette.cyan.hex;
    control_char.foreground = palette.blue.hex;
    broken_symlink.foreground = palette.red.hex;
    broken_path_overlay.foreground = palette.fg_dim.hex;
  };

  # Theme for a resolution:
  #   none      -> no selection (eza keeps its default).
  #   generated -> the rendered palette/ANSI map (written by Home Manager's
  #                `programs.eza.theme`).
  #   official  -> the vendored `theme.yml` path (deployed as `eza/theme.yml`).
  #   unknown explicit id -> no selection, never an invented theme.
  themeSelection = {
    resolution,
    palette,
    ansi,
  }:
    if resolution.kind == "none"
    then {mode = "none";}
    else if resolution.id == generatedId
    then {
      mode = "generated";
      theme = render {inherit palette ansi;};
    }
    else if officialThemes ? ${resolution.id}
    then {
      mode = "official";
      path = officialThemes.${resolution.id};
    }
    else {mode = "none";};
}
