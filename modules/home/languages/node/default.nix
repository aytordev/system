{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  catalog = import ../../../common/languages/catalog.nix {inherit pkgs;};
  lang = catalog.node;
  cfg = config.aytordev.languages.node;
in {
  options.aytordev.languages.node = {
    enable = mkEnableOption "Node.js language support";
    version = mkOption {
      type = types.enum lang.versions;
      default = lang.defaultVersion;
      description = ''
        Node.js version to install and to point the editor tooling at.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lang.runtime cfg.version;
    # The editor settings live in the catalog, next to the language that owns them.
    aytordev.programs.desktop.editors.vscode.extraSettings = lang.editor.vscode.settings or {};
    aytordev.programs.desktop.editors.zed.extraLanguages = lang.editor.zed.languages or {};
    aytordev.programs.desktop.editors.vscode.extraExtensions = lang.editor.vscode.extensions;
  };
}
