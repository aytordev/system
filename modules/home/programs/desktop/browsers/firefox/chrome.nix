# Palette-generated Firefox chrome (`userChrome.css`).
#
# Firefox has no signed theme channel for the aytordev families: the upstream
# integrations publish Firefox Color *add-on* manifests, and release Firefox
# refuses to load unsigned theme XPIs. Instead the active palette is rendered
# into `userChrome.css`, which Home Manager writes to the profile's `chrome/`
# directory and gates with `toolkit.legacyUserProfileCustomizations.stylesheets`
# automatically whenever `userChrome` is non-empty.
#
# Only browser chrome is themed. `about:`/site surfaces (`userContent`) are
# deliberately left alone: a global override there can break arbitrary web
# content, and the pre-existing scrollbar rule already covers the one safe
# `about:` case.
{lib}: rec {
  # Hand-written rules that predate the generated theme. Kept as a named value
  # so the composition (and its tests) prove they survive verbatim.
  base = ''
    /* Hide tab bar when only one tab is open */
    #tabbrowser-tabs[tabscount="1"] {
      visibility: collapse !important;
    }

    /* Compact UI */
    :root {
      --tab-min-height: 32px !important;
      --toolbarbutton-border-radius: 3px !important;
    }
  '';

  # CSS rendered from the active variant. Palette roles drive surfaces and
  # text; the ANSI table supplies the state accents (secure/insecure/attention)
  # that a semantic role cannot express.
  render = {
    palette,
    ansi,
    isLight ? false,
  }: ''
    /* aytordev theme — generated from the active palette; do not edit. */
    :root {
      color-scheme: ${
      if isLight
      then "light"
      else "dark"
    };

      --aytordev-bg: ${palette.bg.hex};
      --aytordev-bg-dim: ${palette.bg_dim.hex};
      --aytordev-bg-float: ${palette.bg_float.hex};
      --aytordev-bg-visual: ${palette.bg_visual.hex};
      --aytordev-fg: ${palette.fg.hex};
      --aytordev-fg-dim: ${palette.fg_dim.hex};
      --aytordev-accent: ${palette.accent.hex};
      --aytordev-accent-dim: ${palette.accent_dim.hex};
      --aytordev-border: ${palette.border.hex};
      --aytordev-selection: ${palette.selection.hex};

      /* Lightweight-theme variables Firefox reads across chrome. */
      --lwt-accent-color: var(--aytordev-bg-dim) !important;
      --lwt-accent-color-inactive: var(--aytordev-bg) !important;
      --lwt-text-color: var(--aytordev-fg) !important;
      --lwt-selected-tab-background-color: var(--aytordev-bg) !important;
      --lwt-tab-text: var(--aytordev-fg) !important;
      --toolbar-bgcolor: var(--aytordev-bg) !important;
      --toolbar-color: var(--aytordev-fg) !important;
      --toolbar-field-background-color: var(--aytordev-bg-dim) !important;
      --toolbar-field-color: var(--aytordev-fg) !important;
      --toolbar-field-border-color: var(--aytordev-border) !important;
      --toolbar-field-focus-background-color: var(--aytordev-bg-float) !important;
      --toolbar-field-focus-color: var(--aytordev-fg) !important;
      --toolbar-field-focus-border-color: var(--aytordev-accent) !important;
      --tab-selected-bgcolor: var(--aytordev-bg-float) !important;
      --tab-selected-textcolor: var(--aytordev-fg) !important;
      --tab-line-color: var(--aytordev-accent) !important;
      --tab-selected-outline-color: var(--aytordev-accent-dim) !important;
      --urlbar-box-bgcolor: var(--aytordev-bg-visual) !important;
      --arrowpanel-background: var(--aytordev-bg-float) !important;
      --arrowpanel-color: var(--aytordev-fg) !important;
      --arrowpanel-border-color: var(--aytordev-border) !important;
      --sidebar-background-color: var(--aytordev-bg) !important;
      --sidebar-text-color: var(--aytordev-fg) !important;
      --focus-outline-color: var(--aytordev-accent) !important;
      --toolbarbutton-hover-background: var(--aytordev-bg-dim) !important;
      --toolbarbutton-active-background: var(--aytordev-selection) !important;
    }

    /* Toolbar and tab strip surfaces. */
    #navigator-toolbox,
    #TabsToolbar,
    #PersonalToolbar,
    #nav-bar {
      background-color: var(--aytordev-bg) !important;
      color: var(--aytordev-fg) !important;
    }
    #nav-bar {
      border-top: 1px solid var(--aytordev-border) !important;
      box-shadow: none !important;
    }

    /* Address bar and search box. */
    #urlbar,
    #searchbar {
      background-color: var(--aytordev-bg-dim) !important;
      color: var(--aytordev-fg) !important;
    }
    #urlbar[focused="true"] > #urlbar-background {
      border-color: var(--aytordev-accent) !important;
      box-shadow: 0 0 0 2px var(--aytordev-selection) !important;
    }

    /* Tabs. */
    .tabbrowser-tab[selected] .tab-content {
      background-color: var(--aytordev-bg-float) !important;
      color: var(--aytordev-fg) !important;
    }
    .tabbrowser-tab:not([selected]) .tab-content {
      color: var(--aytordev-fg-dim) !important;
    }
    .tabbrowser-tab[selected] .tab-line {
      background-color: var(--aytordev-accent) !important;
    }
    .tabbrowser-tab[attention] .tab-icon-image {
      color: ${ansi.normal.yellow.hex} !important;
    }

    /* Buttons. */
    toolbarbutton:hover {
      background-color: var(--aytordev-bg-dim) !important;
    }
    toolbarbutton:hover:active {
      background-color: var(--aytordev-selection) !important;
    }

    /* Panels, menus, and sidebars. */
    panelview,
    menupopup,
    .panel-arrowcontent {
      background-color: var(--aytordev-bg-float) !important;
      color: var(--aytordev-fg) !important;
    }
    #sidebar-box,
    #sidebar-header {
      background-color: var(--aytordev-bg) !important;
      color: var(--aytordev-fg) !important;
      border-color: var(--aytordev-border) !important;
    }

    /* Find bar and status panel. */
    .findbar-container,
    #statuspanel-label {
      background-color: var(--aytordev-bg-float) !important;
      color: var(--aytordev-fg) !important;
      border-color: var(--aytordev-border) !important;
    }

    /* State accents (ANSI table). */
    #identity-box.verifiedDomain {
      color: ${ansi.normal.green.hex} !important;
    }
    #identity-box.notSecure {
      color: ${ansi.normal.red.hex} !important;
    }
    #tracking-protection-icon-container[active] {
      color: ${ansi.normal.blue.hex} !important;
    }
  '';

  # Full `userChrome.css`: the pre-existing rules first, then the generated theme
  # so its `:root` variables win on any collision.
  userChrome = {
    palette,
    ansi,
    isLight ? false,
  }:
    lib.concatStringsSep "\n" [
      base
      (render {inherit palette ansi isLight;})
    ];
}
