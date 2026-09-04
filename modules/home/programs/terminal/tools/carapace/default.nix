{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.carapace;
in {
  options.aytordev.programs.terminal.tools.carapace = {
    enable = mkEnableOption "carapace - multi-shell command argument completer";
    package = mkPackageOption pkgs "carapace" {};
  };
  config = mkIf cfg.enable {
    # Upstream programs.carapace owns every shell's init; integrations follow
    # the enabled shells. Blind merge of si.flags is safe: carapace integrates
    # with all four shells (bash/fish/zsh/nushell), so each flag is valid.
    programs.carapace =
      {
        enable = true;
        inherit (cfg) package;
      }
      // (lib.aytordev.shellIntegration config).flags;
  };
}
