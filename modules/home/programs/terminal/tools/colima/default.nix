{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkPackageOption;
  cfg = config.aytordev.programs.terminal.tools.colima;
in {
  options.aytordev.programs.terminal.tools.colima = {
    enable = mkEnableOption "colima";

    package = mkPackageOption pkgs "colima" {};
  };

  config = mkIf cfg.enable {
    # Colima's runtime closure already contains Lima and QEMU, so neither is
    # added here (verified with `nix path-info -r`).
    home.packages = [cfg.package];

    # No autostart: the VM runs on demand via `colima start`. Upstream's
    # documented autostart is `brew services start colima`, which does not
    # apply to a nixpkgs install; deliberately no LaunchAgent or activation
    # script was added. If autostart is ever wanted, it is an explicit
    # Home Manager launchd agent, not this module's default.
  };
}
