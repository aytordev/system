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

  # Generate one Yazi flavor per registered family/variant from the semantic
  # palette, so Yazi follows aytordev.theme instead of a vendored set.
  mkFlavorToml = import ./flavor.nix;
  generatedFlavors =
    lib.concatMapAttrs (
      family: provider:
        lib.mapAttrs' (
          variant: palette:
            lib.nameValuePair "${family}-${variant}" (
              pkgs.writeTextDir "flavor.toml" (mkFlavorToml {
                inherit palette;
              })
            )
        )
        provider.variants
    )
    themeCfg.providers;
  activeFlavor = "${themeCfg.name}-${themeCfg.variant}";
in {
  options.aytordev.programs.terminal.tools.yazi = {
    enable = lib.mkEnableOption "yazi";
    package = lib.mkPackageOption pkgs "yazi" {nullable = true;};
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
      flavors = generatedFlavors;
      # Yazi selects by detected background polarity; pin both to the active
      # variant so the global selection wins.
      theme.flavor = {
        dark = activeFlavor;
        light = activeFlavor;
      };
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
