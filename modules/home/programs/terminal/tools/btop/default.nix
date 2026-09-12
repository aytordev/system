{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.aytordev.programs.terminal.tools.btop;
  themeCfg = config.aytordev.theme;

  # Hybrid theme resolution: exact official `.theme` when the active family
  # ships one for the active variant, otherwise the palette-generated theme.
  btopTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };

  themeIntegration = themeCfg.integrations.${themeCfg.name}.btop or null;
  themeResolution = btopTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeIntegration;
  };

  generatedTheme = btopTheme.render {
    inherit (themeCfg) palette ansi;
  };

  # Manual override validation: the vendored official ids and the generated id
  # are the only materializable themes, so a bare override (or submodule id)
  # must name one of them.
  themeNames = builtins.attrNames btopTheme.officialThemes ++ [btopTheme.generatedId];
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated theme, manual pins id, none leaves btop's default.";
      };
      id = mkOption {
        type = types.nullOr (types.enum themeNames);
        default = null;
        description = "Theme id to pin when mode = \"manual\".";
      };
    };
  };

  # Every non-theme btop option. Kept as a named base so the composer only adds
  # `color_theme` and cannot drop any of them.
  baseSettings = {
    theme_background = true;
    truecolor = true;
    force_tty = false;
    presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
    vim_keys = false;
    rounded_corners = true;
    graph_symbol = "braille";
    graph_symbol_cpu = "default";
    graph_symbol_mem = "default";
    graph_symbol_net = "default";
    graph_symbol_proc = "default";
    shown_boxes = "proc net mem cpu";
    update_ms = 2000;
    proc_sorting = "cpu direct";
    proc_reversed = false;
    proc_tree = false;
    proc_colors = true;
    proc_gradient = true;
    proc_per_core = true;
    proc_mem_bytes = true;
    proc_cpu_graphs = true;
    proc_info_smaps = false;
    proc_left = false;
    proc_filter_kernel = false;
    cpu_graph_upper = "total";
    cpu_graph_lower = "total";
    cpu_invert_lower = true;
    cpu_single_graph = false;
    cpu_bottom = false;
    show_uptime = true;
    check_temp = true;
    cpu_sensor = "Auto";
    show_coretemp = true;
    cpu_core_map = "";
    temp_scale = "celsius";
    base_10_sizes = false;
    show_cpu_freq = true;
    clock_format = "%X";
    background_update = true;
    custom_cpu_name = "";
    disks_filter = "";
    mem_graphs = true;
    mem_below_net = false;
    zfs_arc_cached = true;
    show_swap = true;
    swap_disk = true;
    show_disks = true;
    only_physical = true;
    use_fstab = true;
    zfs_hide_datasets = false;
    disk_free_priv = false;
    show_io_stat = true;
    io_mode = false;
    io_graph_combined = false;
    io_graph_speeds = "";
    net_download = 100;
    net_upload = 100;
    net_auto = true;
    net_sync = false;
    net_iface = "";
    show_battery = true;
    selected_battery = "Auto";
    log_level = "WARNING";
  };

  # Layer the resolved `color_theme` on top of the base options; `none` leaves
  # the base untouched and btop keeps its own default theme.
  themeSettings = btopTheme.settings {
    base = baseSettings;
    resolution = themeResolution;
  };

  # `programs.btop.themes` values are paths (official) or lines (generated).
  themes = btopTheme.themeSources {
    resolution = themeResolution;
    generatedText = generatedTheme;
  };
in {
  options.aytordev.programs.terminal.tools.btop = {
    enable = mkEnableOption "btop - A resource monitor that shows usage and stats for processor, memory, disks, network and processes";
    package = lib.mkPackageOption pkgs "btop" {};

    theme = mkOption {
      type = types.nullOr (types.either (types.enum themeNames) themeOverrideType);
      default = null;
      description = ''
        btop theme override. Null follows `aytordev.theme` through the hybrid
        resolver. A bare vendored theme id, or `{ mode = "manual"; id = ...; }`,
        pins a theme; `{ mode = "none"; }` leaves btop's own default.
        Available themes: ${builtins.concatStringsSep ", " themeNames}
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      inherit (cfg) package;
      settings = themeSettings;
      inherit themes;
    };
  };
}
