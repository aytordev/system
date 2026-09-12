# Per-family tmux theme materialization plus the adapter's hybrid resolution.
#
# Official resources exist for catppuccin (the official `catppuccin/tmux`
# plugin) and sora (the official vendored `sora.tmux.conf`). Kanagawa has no
# upstream tmux resource, so it resolves to a theme generated from the shared
# palette. `resolve` follows the shared hybrid policy:
# explicit override > official exact > generated fallback > none.
{
  lib,
  resolveApp,
}: rec {
  # Stable id the resolver reports for the palette-generated fallback. tmux has
  # no named-theme registry, so the value only signals "generated"; the actual
  # settings are rendered inline by `renderConfig`.
  generatedId = "aytordev";

  # Official Sora tmux theme, vendored verbatim from
  # `extras/tmux/sora.tmux.conf`. The provider registry pins the upstream rev
  # and this file's NAR hash; the adapter sources it at runtime so the upstream
  # file stays byte-for-byte.
  soraConf = ./sora.tmux.conf;

  # Families backed by an official tmux plugin: nixpkgs plugin attr -> the
  # upstream option that selects the variant. catppuccin/tmux reads the
  # American-spelling `@catppuccin_flavor`; its values are the lower-case
  # flavour ids the integration declares.
  pluginOptions = {
    catppuccin = "@catppuccin_flavor";
  };

  # Hand `resolveApp` the integration only when it covers the active variant;
  # otherwise the generated fallback wins. Malformed integrations pass through
  # so `resolveApp` can report them.
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
      app = "tmux";
      inherit variant override;
      generated = generatedId;
      official = selectOfficial {inherit integration variant;};
    };

  # Palette -> tmux global style lines. Covers the status line, window status,
  # pane borders, messages, copy mode and clock so the generated fallback reads
  # as a coherent theme rather than an accent-only fragment.
  renderConfig = {palette}: let
    lines = [
      "set -g status-style \"bg=${palette.bg_dim.hex},fg=${palette.fg.hex}\""
      "set -g status-left \"#[fg=${palette.accent.hex},bold] #{session_name} \""
      "set -g window-status-style \"fg=${palette.fg_dim.hex},bg=${palette.bg_dim.hex}\""
      "set -g window-status-current-style \"fg=${palette.bg.hex},bg=${palette.accent.hex}\""
      "set -g window-status-activity-style \"fg=${palette.yellow.hex},bg=${palette.bg_dim.hex}\""
      "set -g pane-border-style \"fg=${palette.border.hex}\""
      "set -g pane-active-border-style \"fg=${palette.accent.hex}\""
      "set -g message-style \"bg=${palette.bg_float.hex},fg=${palette.fg.hex}\""
      "set -g message-command-style \"bg=${palette.bg_float.hex},fg=${palette.fg.hex}\""
      "set -g mode-style \"bg=${palette.selection.hex},fg=${palette.fg.hex}\""
      "set -g clock-mode-colour \"${palette.accent.hex}\""
    ];
  in
    "# aytordev tmux theme (generated from the active palette)\n"
    + lib.concatStringsSep "\n" lines
    + "\n";

  # Mechanism backing a family: an official plugin, a vendored source file, or
  # the palette-generated fallback (any family without an upstream resource,
  # currently kanagawa).
  familyKind = family:
    if pluginOptions ? ${family}
    then "plugin"
    else if family == "sora"
    then "sourced"
    else "generated";

  # Materialize a resolution for the active family. Returns the symbolic plugin
  # attr (`pluginName`) the module maps to `pkgs.tmuxPlugins`, plus `extraConfig`
  # lines. A plugin family carries its selection on the plugin's own config; a
  # sourced/generated family carries it in the app-level extraConfig.
  materialize = {
    family,
    resolution,
    palette,
  }: let
    kind = familyKind family;
    selected = resolution.kind == "official" || resolution.kind == "explicit";
  in
    if resolution.kind == "none"
    then {
      pluginName = null;
      extraConfig = "";
    }
    else if kind == "plugin" && selected
    then {
      pluginName = family;
      extraConfig = "set -g ${pluginOptions.${family}} '${resolution.id}'";
    }
    else if kind == "sourced" && selected
    then {
      pluginName = null;
      extraConfig = "source-file ${soraConf}";
    }
    else {
      pluginName = null;
      extraConfig = renderConfig {inherit palette;};
    };

  # Theme-independent settings: terminal handling, keymaps, floating
  # scratchpad, performance and session options, and the status position. Kept
  # pure so tests can assert the theme work never drops them; `default.nix`
  # appends this after the theme's own settings so these preferences win.
  staticConfig =
    /*
    Bash
    */
    ''
      # --- Terminal & Key Handling ---
      set -ga terminal-overrides ",*:Tc"
      set -s extended-keys off

      # Vi mode copy (platform-aware)
      if-shell 'uname | grep -q Darwin' \
        'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"' \
        'bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip"'

      # --- Keymaps ---
      # Splits (v=horizontal, d=vertical)
      unbind '"'
      unbind %
      bind v split-window -h -c "#{pane_current_path}"
      bind d split-window -v -c "#{pane_current_path}"

      # Kill all sessions except current
      bind K confirm-before -p "Kill all other sessions? (y/n)" "kill-session -a"

      # Pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # --- Floating Scratchpad ---
      bind-key -n M-g if-shell -F '#{==:#{session_name},scratch}' {
        detach-client
      } {
        display-popup -d "#{pane_current_path}" -E "tmux new-session -A -s scratch"
      }

      # --- Performance ---
      set -sg escape-time 0
      set -g  history-limit 50000
      set -g  aggressive-resize on

      # --- Session Options ---
      set -g detach-on-destroy off
      set -g renumber-windows  on
      set -g allow-passthrough on
      set -g focus-events      on

      # --- Status Bar ---
      set -g status-position top
    '';

  # Compose the theme's app-level extraConfig with the theme-independent layout,
  # dropping empty parts. Keeps a sourced `source-file` line separate from the
  # layout comment and makes `none` emit only the layout.
  composeExtraConfig = {themeExtraConfig}:
    lib.concatStringsSep "\n" (
      lib.filter (part: part != "") [
        themeExtraConfig
        staticConfig
      ]
    );
}
