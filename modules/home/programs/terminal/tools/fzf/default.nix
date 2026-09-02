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
  };
  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.fd
      pkgs.zsh-fzf-tab
    ];
    home.activation.createFzfDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "${config.xdg.dataHome}/fzf"
    '';
    programs =
      {
        fzf =
          {
            enable = true;
            inherit (cfg) package;
            inherit (cfg) defaultCommand;
            defaultOptions = defaultOptions ++ cfg.extraOptions;
            historyWidget.command = "";
          }
          // si.flags;
      }
      // shellIntegration;
  };
}
