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
    # The editor settings live in the catalog, next to the language that owns them.
    aytordev.programs.desktop.editors.vscode.extraSettings = lang.editor.vscode.settings or {};
    aytordev.programs.desktop.editors.zed.extraLanguages = lang.editor.zed.languages or {};
    aytordev.programs.desktop.editors.vscode.extraExtensions = lang.editor.vscode.extensions;
  };
}
