{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.aytordev.programs.terminal.tools.yazi;
  themeCfg = config.aytordev.theme;
  si = lib.aytordev.shellIntegration config;

  # Hybrid theme resolution: exact official resource when the active family
  # ships one for the active variant, otherwise the palette-generated flavor.
  yaziTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  yaziIntegration = themeCfg.integrations.${themeCfg.name}.yazi or null;
  # Preserve the previous naming (`<family>-<variant>`) for the generated
  # flavor so the active selection is stable across the hybrid resolver.
  generatedFlavorId = "${themeCfg.name}-${themeCfg.variant}";
  generatedFlavor = pkgs.writeTextDir "flavor.toml" (
    yaziTheme.generatedFlavor {inherit (themeCfg) palette;}
  );
  themeResolution = yaziTheme.resolve {
    inherit (themeCfg) variant;
    generated = generatedFlavorId;
    override = cfg.theme;
    integration = yaziIntegration;
  };

  # Per-app theme override shape. `manual` pins a flavor id; `none` emits no
  # flavor selection; `auto` (the default) follows the hybrid resolver.
  themeOverrideType = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource/generated flavor, manual pins id, none emits no flavor selection.";
      };
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Flavor id to pin when mode = \"manual\".";
      };
    };
  };
in {
  options.aytordev.programs.terminal.tools.yazi = {
    enable = lib.mkEnableOption "yazi";
    package = lib.mkPackageOption pkgs "yazi" {nullable = true;};

    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.str themeOverrideType);
      default = null;
      description = ''
        Yazi theme override. Null follows `aytordev.theme` through the hybrid
        resolver. A bare flavor id, or `{ mode = "manual"; id = ...; }`, pins a
        flavor; `{ mode = "none"; }` emits no flavor selection.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = let
      optionalPluginPackage = plugin: package: lib.optional (builtins.hasAttr plugin config.programs.yazi.plugins) package;
    in
      optionalPluginPackage "ouch" pkgs.ouch
      ++ optionalPluginPackage "glow" pkgs.glow
      ++ optionalPluginPackage "duckdb" pkgs.duckdb
      ++ [
        pkgs._7zz-rar
        pkgs.atool
        pkgs.exiftool
        pkgs.mediainfo
      ]
      ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
        pkgs.unar
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.dragon-drop
      ];
    programs.yazi = {
      enable = true;
      inherit (cfg) package;
      shellWrapperName = "y";
      enableBashIntegration = si.shellEnabled "bash";
      enableFishIntegration = si.shellEnabled "fish";
      enableNushellIntegration = si.shellEnabled "nushell";
      enableZshIntegration = si.shellEnabled "zsh";
      inherit (import ./init.nix {inherit config lib;}) initLua;
      keymap = lib.mkMerge [
        (import ./keymap/completion.nix)
        (import ./keymap/help.nix)
        (import ./keymap/manager.nix {
          inherit config lib pkgs;
        })
        (import ./keymap/select.nix)
        (import ./keymap/tasks.nix)
      ];
      flavors = yaziTheme.flavorEntries {
        resolution = themeResolution;
        inherit generatedFlavor;
      };
      theme = yaziTheme.themeSelection {resolution = themeResolution;};
      plugins = {
        "arrow-parent" = ./plugins/arrow-parent.yazi;
        inherit
          (pkgs.yaziPlugins)
          chmod
          diff
          duckdb
          full-border
          git
          jump-to-char
          mount
          ouch
          piper
          restore
          smart-enter
          smart-filter
          sudo
          toggle-pane
          yatline
          yatline-githead
          ;
        glow = pkgs.yaziPlugins.glow.overrideAttrs {
          patches = [
            (pkgs.fetchpatch {
              url = "https://github.com/Reledia/glow.yazi/pull/28.patch";
              hash = "sha256-wNAqaCMucfw8BZvUi1vqARoraXWGIzZN6YoWcFAelTw=";
            })
          ];
        };
      };
      settings = lib.mkMerge [
        (import ./settings/input.nix)
        (import ./settings/open.nix)
        (import ./settings/opener.nix {
          inherit config lib pkgs;
        })
        (import ./settings/plugin.nix {inherit config lib;})
        {
          log = {
            enabled = false;
          };
          mgr = {
            ratio = [
              1
              3
              4
            ];
            linemode = "custom";
            show_hidden = true;
            show_symlink = true;
            sort_by = "alphabetical";
            sort_dir_first = true;
            sort_reverse = false;
            sort_sensitive = false;
          };
          pick = {
            open_title = "Open with:";
            open_origin = "hovered";
            open_offset = [
              0
              1
              50
              7
            ];
          };
          preview = {
            tab_size = 2;
            max_width = 600;
            max_height = 900;
            image_filter = "triangle";
            image_quality = 75;
            sixel_fraction = 15;
            ueberzug_scale = 1;
            ueberzug_offset = [
              0
              0
              0
              0
            ];
            wrap = "yes";
          };
          tasks = {
            micro_workers = 10;
            macro_workers = 25;
            bizarre_retry = 5;
            image_alloc = 536870912;
            image_bound = [
              0
              0
            ];
            suppress_preload = false;
          };
          which = {
            sort_by = "none";
            sort_sensitive = false;
            sort_reverse = false;
          };
        }
      ];
    };
  };
}
