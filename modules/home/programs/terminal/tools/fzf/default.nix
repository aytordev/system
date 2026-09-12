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
  cfg = config.aytordev.programs.terminal.tools.fzf;
  themeCfg = config.aytordev.theme;
  # Per-app theme override shape. `manual` pins an official map id; `none`
  # emits no colors; `auto` (the default) follows the hybrid resolver.
  themeOverrideType = types.submodule {
    options = {
      mode = mkOption {
        type = types.enum [
          "auto"
          "manual"
          "none"
        ];
        default = "auto";
        description = "auto follows the family resource or the generated map; manual pins an official map id; none leaves FZF's own colors.";
      };
      id = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Official map id to pin when mode = \"manual\".";
      };
    };
  };
  defaultOptions = [
    "--layout=reverse"
    "--exact"
    "--bind=alt-p:toggle-preview,alt-a:select-all"
    "--multi"
    "--no-mouse"
    "--info=inline"
    "--ansi"
    "--with-nth=1.."
    "--pointer=' '"
    "--header-first"
    "--border=rounded"
  ];
  defaultCommand = "${pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
  si = lib.aytordev.shellIntegration config;
  shellIntegration = import ./shell-integration.nix {inherit cfg pkgs si;};
  # Hybrid theme resolution: exact official color map when the active family
  # ships an FZF integration covering the active variant, otherwise the map
  # generated from the shared palette.
  fzfTheme = import ./config.nix {
    inherit lib;
    inherit (lib.aytordev) resolveApp;
  };
  themeResolution = fzfTheme.resolve {
    inherit (themeCfg) variant;
    override = cfg.theme;
    integration = themeCfg.integrations.${themeCfg.name}.fzf or null;
  };
in {
  options.aytordev.programs.terminal.tools.fzf = {
    enable = mkEnableOption "fuzzy finder";
    package = lib.mkPackageOption pkgs "fzf" {};
    defaultCommand = mkOption {
      type = types.str;
      default = defaultCommand;
      description = "Default command to use for finding files";
    };
    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional options to pass to fzf";
    };
    theme = mkOption {
      type = types.nullOr (types.either types.str themeOverrideType);
      default = null;
      description = ''
        FZF color override. Null follows `aytordev.theme` through the hybrid
        resolver (explicit override > official exact > generated fallback). A
        bare official map id, or `{ mode = "manual"; id = ...; }`, pins a map;
        `{ mode = "none"; }` leaves FZF's own colors.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.fd
      pkgs.zsh-fzf-tab
    ];
    home.activation.createFzfDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/fzf"
      $DRY_RUN_CMD chmod 700 "${config.xdg.dataHome}/fzf"
    '';
    programs =
      {
        fzf =
          fzfTheme.settings {
            base = {
              enable = true;
              inherit (cfg) package;
              inherit (cfg) defaultCommand;
              defaultOptions = defaultOptions ++ cfg.extraOptions;
              historyWidget.command = "";
            };
            resolution = themeResolution;
            inherit (themeCfg) palette;
          }
          // si.flags;
      }
      // shellIntegration;
  };
}
