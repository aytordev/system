{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  catalog = import ../../../common/languages/catalog.nix {inherit pkgs;};
  lang = catalog.go;
  cfg = config.aytordev.languages.go;
in {
  options.aytordev.languages.go = {
    enable = mkEnableOption "Go language support";
  };

  config = mkIf cfg.enable {
    # Unversioned language: `runtime` ignores its argument, and null is the
    # documented value a pack passes in that case.
    home.packages = lang.runtime null;
    aytordev.programs.desktop.editors.vscode.extraExtensions = lang.editor.vscode.extensions;
  };
}
