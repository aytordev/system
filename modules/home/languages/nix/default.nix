{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  catalog = import ../../../common/languages/catalog.nix {inherit pkgs;};
  lang = catalog.nix;
  cfg = config.aytordev.languages.nix;
in {
  options.aytordev.languages.nix = {
    enable = mkEnableOption "Nix development toolchain";
  };

  config = mkIf cfg.enable {
    # Unversioned language: `runtime` ignores its argument, and null is the
    # documented value a pack passes in that case.
    home.packages = lang.runtime null;
  };
}
