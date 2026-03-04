# Sketchybar Lua generation
# Handles all Nix-to-Lua bridging: constants, item loading, config files.
{
  lib,
  pkgs,
  cfg,
  themeCfg,
}: let
  inherit (lib) getExe;
  inherit (themeCfg) palette;

  # ── Helpers ────────────────────────────────────────────────────────────

  # Convert Nix attrs to Lua table syntax
  toLuaTable = attrs: let
    toLuaValue = v:
      if builtins.isString v
      then "\"${v}\""
      else if builtins.isBool v
      then
        (
          if v
          then "true"
          else "false"
        )
      else if builtins.isAttrs v
      then toLuaTable v
      else if builtins.isList v
      then toLuaList v
      else builtins.toString v;
    fields = lib.mapAttrsToList (k: v: "${k} = ${toLuaValue v}") attrs;
  in "{\n${builtins.concatStringsSep ",\n" fields}\n}";

  # Convert Nix list to Lua array syntax
  toLuaList = list: let
    toLuaValue = v:
      if builtins.isString v
      then "\"${v}\""
      else builtins.toString v;
  in "{${builtins.concatStringsSep ", " (map toLuaValue list)}}";

  # ── Color Mapping ──────────────────────────────────────────────────────

  # Maps a semantic palette to the flat structure expected by Lua config.
  # Reusable for both the active palette and all variant palettes.
  mkSketchybarColors = p: {
    default = p.fg.sketchybar;
    black = p.bg_dim.sketchybar;
    white = p.fg.sketchybar;
    red = p.red.sketchybar;
    red_bright = p.red_bright.sketchybar;
    green = p.green.sketchybar;
    blue = p.accent.sketchybar;
    blue_bright = p.blue_bright.sketchybar;
    yellow = p.yellow.sketchybar;
    orange = p.orange.sketchybar;
    magenta = p.violet.sketchybar;
    grey = p.fg_dim.sketchybar;
    transparent = p.transparent.sketchybar;

    bar = {
      bg = builtins.replaceStrings ["0xff"] ["0xf0"] p.bg.sketchybar;
      border = p.border.sketchybar;
    };

    popup = {
      bg = p.bg.sketchybar;
      border = p.border.sketchybar;
    };

    bg1 = p.bg.sketchybar;
    bg2 = p.border.sketchybar;

    accent = p.accent.sketchybar;
    accent_bright = p.accent_dim.sketchybar;

    pink = p.pink.sketchybar;
    cyan = p.cyan.sketchybar;

    spotify_green = p.green.sketchybar;
  };

  # Active palette colors
  sketchybarColors = mkSketchybarColors palette;

  # All variant palettes for runtime theme switching
  allThemeVariants = lib.mapAttrs (_: mkSketchybarColors) themeCfg.allVariantPalettes;

  # ── Items Registry ─────────────────────────────────────────────────────

  # Fixed ordering determines bar layout.
  # Left side: menus → workspaces → front_app → resources (cpu, ram, network)
  # Right side (first added = rightmost): calendar → vpn → brew → volume →
  #   battery → theme_picker → pomodoro → clipboard → media

  # ── Layout Generation ────────────────────────────────────────────────

  # Separator: invisible item creating a gap between bracket groups
  mkSeparator = name: pos: ''sbar.add("item", "${name}", {position = "${pos}", icon = {drawing = false}, label = {drawing = false}})'';

  # Bracket using range syntax: wraps all items visually between first and last
  mkRangeBracket = name: first: last:
    ''sbar.add("bracket", "${name}", {"${first}", "${last}"}, {background = {drawing = false}})'';

  # Bracket with explicit item list
  mkListBracket = name: items: let
    itemsStr = builtins.concatStringsSep ", " (map (i: "\"${i}\"") items);
  in ''sbar.add("bracket", "${name}", {${itemsStr}}, {background = {drawing = false}})'';

  # ── Section flags ──
  hasMenus = cfg.items.menus.enable;
  hasSpaces = cfg.items.workspaces.enable || cfg.items.frontApp.enable;
  hasResources =
    cfg.items.widgets.cpu.enable
    || cfg.items.widgets.ram.enable
    || cfg.items.widgets.network.enable;

  # ── Resource bracket items ──
  resourceItems =
    lib.optionals cfg.items.widgets.cpu.enable ["widgets.cpu"]
    ++ lib.optionals cfg.items.widgets.ram.enable ["widgets.ram"]
    ++ lib.optionals cfg.items.widgets.network.enable [
      "widgets.network.padding"
      "widgets.network.up"
      "widgets.network.down"
    ];

  # ── Right bracket endpoints (range syntax) ──
  # Media is outside, to the left of the bracket.
  rightItemNames =
    lib.optionals cfg.items.themePicker.enable ["theme_picker"]
    ++ lib.optionals cfg.items.calendar.enable ["calendar.time"]
    ++ lib.optionals cfg.items.vpn.enable ["vpn"]
    ++ lib.optionals cfg.items.widgets.brew.enable ["widgets.brew"]
    ++ lib.optionals cfg.items.widgets.volume.enable ["widgets.volume2"]
    ++ lib.optionals cfg.items.widgets.battery.enable ["widgets.battery"]
    ++ lib.optionals cfg.items.pomodoro.enable ["pomodoro"]
    ++ lib.optionals cfg.items.clipboard.enable ["clipboard"];

  # ── Reorder command for deferred workspace loading ──
  leftItemOrder =
    lib.optionals hasMenus ["menu_trigger"]
    ++ lib.optionals hasMenus ["cosmic_sep"]
    ++ lib.optionals cfg.items.workspaces.enable ["aerospace.mode" "/space\\\\..*/"]
    ++ lib.optionals cfg.items.frontApp.enable ["front_app"]
    ++ lib.optionals (hasSpaces && hasResources) ["separator.resources"]
    ++ lib.optionals cfg.items.widgets.cpu.enable ["widgets.cpu"]
    ++ lib.optionals cfg.items.widgets.ram.enable ["widgets.ram"]
    ++ lib.optionals cfg.items.widgets.network.enable [
      "widgets.network.padding"
      "widgets.network.up"
      "widgets.network.down"
    ];

  reorderStr = builtins.concatStringsSep " " leftItemOrder;

  # ── Spaces bracket endpoints ──
  spacesFirst =
    if cfg.items.workspaces.enable
    then "aerospace.mode"
    else "front_app";
  spacesLast =
    if cfg.items.frontApp.enable
    then "front_app"
    else "aerospace.mode";

  # ── Build generated init.lua ──────────────────────────────────────────

  generatedItemsInit = let
    # Left side: menus → separator → workspaces → front_app → separator → resources
    leftLines =
      lib.optionals cfg.items.menus.enable [
        ''require("items.menus")''
      ]
      # Note: cosmic_sep separator is created inside menus.lua
      ++ lib.optionals cfg.items.workspaces.enable [
        ''require("items.workspaces")''
      ]
      ++ lib.optionals cfg.items.frontApp.enable [
        ''require("items.front_app")''
      ]
      ++ lib.optionals (hasSpaces && hasResources) [
        (mkSeparator "separator.resources" "left")
      ]
      ++ lib.optionals cfg.items.widgets.cpu.enable [
        ''require("items.widgets.cpu")''
      ]
      ++ lib.optionals cfg.items.widgets.ram.enable [
        ''require("items.widgets.ram")''
      ]
      ++ lib.optionals cfg.items.widgets.network.enable [
        ''require("items.widgets.network")''
      ];

    # Right side: first added = rightmost on screen
    # Theme picker goes first (far right, outside bracket)
    rightLines =
      lib.optionals cfg.items.themePicker.enable [
        ''require("items.theme_picker")''
      ]
      ++ lib.optionals cfg.items.calendar.enable [
        ''require("items.calendar")''
      ]
      ++ lib.optionals cfg.items.vpn.enable [
        ''require("items.vpn")''
      ]
      ++ lib.optionals cfg.items.widgets.brew.enable [
        ''require("items.widgets.brew")''
      ]
      ++ lib.optionals cfg.items.widgets.volume.enable [
        ''require("items.widgets.volume")''
      ]
      ++ lib.optionals cfg.items.widgets.battery.enable [
        ''require("items.widgets.battery")''
      ]
      ++ lib.optionals cfg.items.pomodoro.enable [
        ''require("items.pomodoro")''
      ]
      ++ lib.optionals cfg.items.clipboard.enable [
        ''require("items.clipboard")''
      ]
      ++ lib.optionals cfg.items.media.enable [
        ''require("items.media")''
      ];

    allLines = leftLines ++ rightLines;

    # Static brackets (created immediately)
    bracketLines =
      lib.optionals (builtins.length resourceItems >= 2) [
        (mkListBracket "resources.bracket" resourceItems)
      ]
      ++ lib.optionals (builtins.length rightItemNames >= 2) [
        (mkRangeBracket "right.bracket" (builtins.head rightItemNames) (lib.last rightItemNames))
      ];

    # Deferred reorder + spaces bracket (only when workspaces use deferred loading)
    deferredLines =
      if cfg.items.workspaces.enable
      then [
        ''local _reorder = sbar.add("item", {drawing = false})''
        ''_reorder:subscribe("aerospace_is_ready", function()''
        ''  sbar.exec("sketchybar --reorder ${reorderStr}")''
      ]
      ++ lib.optionals hasSpaces [
        ''  sbar.add("bracket", "spaces.bracket", {"${spacesFirst}", "${spacesLast}"}, {background = {drawing = false}})''
      ]
      ++ [
        ''end)''
      ]
      else [];

    bodyLines =
      allLines
      ++ (
        if (bracketLines != [] || deferredLines != [])
        then ["" ''local colors = require("colors")''] ++ bracketLines ++ deferredLines
        else []
      );
  in ''
    -- Auto-generated by Nix. Do not edit manually.
    ${builtins.concatStringsSep "\n" bodyLines}
  '';

  # ── Per-item Configuration ─────────────────────────────────────────────

  # Only generate config for enabled items that have sub-options
  itemsConfig = let
    optionalItem = enable: config:
      if enable
      then config
      else {};
  in
    lib.filterAttrs (_: v: v != {}) {
      media = optionalItem cfg.items.media.enable {
        inherit (cfg.items.media) whitelist;
      };
      workspaces = optionalItem cfg.items.workspaces.enable {
        bounce_animation = cfg.items.workspaces.bounceAnimation;
        deferred_loading = cfg.items.workspaces.deferredLoading;
      };
      pomodoro = optionalItem cfg.items.pomodoro.enable {
        default_duration = cfg.items.pomodoro.defaultDuration;
      };
      clipboard = optionalItem cfg.items.clipboard.enable {
        poll_interval = cfg.items.clipboard.pollInterval;
        max_entries = cfg.items.clipboard.maxEntries;
      };
    };

  # ── Packages ───────────────────────────────────────────────────────────

  # Base packages always needed
  inherit (pkgs) coreutils curl gh gh-notify gnugrep gnused;
  basePackages = [
    coreutils
    curl
    gh
    gh-notify
    gnugrep
    gnused
  ];

  # Conditional packages based on enabled items
  conditionalPackages =
    lib.optionals cfg.items.workspaces.enable [pkgs.aerospace]
    ++ lib.optionals cfg.items.widgets.volume.enable [pkgs.blueutil pkgs.switchaudio-osx]
    ++ lib.optionals cfg.items.menus.enable [pkgs.jankyborders];

  allPackages = basePackages ++ conditionalPackages ++ cfg.extraPackages;

  # ── Shell Integration ──────────────────────────────────────────────────

  shellAliases = {
    restart-sketchybar = ''launchctl kickstart -k gui/"$(id -u)"/org.nix-community.home.sketchybar'';
  };

  brewIntegration = ''
    brew() {
      command brew "$@" && ${getExe cfg.package} --trigger brew_update
    }

    mas() {
      command mas "$@" && ${getExe cfg.package} --trigger brew_update
    }
  '';

  # ── Generated Constants ────────────────────────────────────────────────

  nixConstantsLua = let
    itemsSection =
      if itemsConfig != {}
      then ",\nitems = ${toLuaTable itemsConfig}"
      else "";
  in ''
    -- Auto-generated by Nix. Do not edit manually.
    return {
      colors = ${toLuaTable sketchybarColors},
      themes = ${toLuaTable allThemeVariants},
      active_variant = "${themeCfg.variant}",
      fonts = {
        text = "${cfg.fonts.text}",
        icon = "${cfg.fonts.icon}",
        size = ${toString cfg.fonts.size}
      },
      settings = {
        icons_style = "${cfg.iconsStyle}"
      },
      bar = {
        height = ${toString cfg.bar.height},
        blur_radius = ${toString cfg.bar.blurRadius},
        shadow = ${
      if cfg.bar.shadow
      then "true"
      else "false"
    },
        sticky = ${
      if cfg.bar.sticky
      then "true"
      else "false"
    },
        topmost = "${cfg.bar.topmost}",
        padding_left = ${toString cfg.bar.paddingLeft},
        padding_right = ${toString cfg.bar.paddingRight},
        corner_radius = ${toString cfg.bar.cornerRadius},
        border_width = ${toString cfg.bar.borderWidth},
        color = ${cfg.bar.color},
        y_offset = ${toString cfg.bar.yOffset}
      }${itemsSection}
    }
  '';

  # ── Main Config ────────────────────────────────────────────────────────

  mainConfig = ''
    -- Add config directory to package.path for local modules
    local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
    package.path = package.path .. ";" .. config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua"

    -- Compile C event providers before loading items
    os.execute("(cd " .. config_dir .. "/helpers && make)")

    sbar = require("sketchybar")
    sbar.begin_config()
    require("bar")
    require("default")
    require("items")
    sbar.hotload(true)
    sbar.end_config()
    sbar.event_loop()
  '';

  # ── Config Files ───────────────────────────────────────────────────────

  configFiles = {
    # Copy Lua config files, excluding generated/dead files
    "sketchybar" = {
      source = lib.cleanSourceWith {
        src = ./config;
        filter = name: _type: let
          baseName = baseNameOf name;
        in
          baseName != "sketchybarrc"
          && baseName != "install_dependencies.sh"
          # Exclude all init.lua files — they are now generated by Nix
          && baseName != "init.lua";
      };
      recursive = true;
    };

    # Generated constants — bridges all configurable values to Lua
    "sketchybar/nix_constants.lua".text = nixConstantsLua;

    # Generated items loader — only includes enabled items
    "sketchybar/items/init.lua".text = generatedItemsInit;

    # App icon map from package
    "sketchybar/helpers/icon_map.lua".source = "${pkgs.aytordev.sketchybar-app-font}/lib/sketchybar-app-font/icon_map.lua";
  };
in {
  inherit allPackages shellAliases brewIntegration mainConfig configFiles;
}
