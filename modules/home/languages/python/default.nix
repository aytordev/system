{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  catalog = import ../../../common/languages/catalog.nix {inherit pkgs;};
  lang = catalog.python;
  cfg = config.aytordev.languages.python;
in {
  options.aytordev.languages.python = {
    enable = mkEnableOption "Python language support";
    version = mkOption {
      type = types.enum lang.versions;
      default = lang.defaultVersion;
      description = ''
        Python version to install and to point the editor tooling at.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lang.runtime cfg.version;
    aytordev.programs.desktop.editors.vscode.extraExtensions = lang.editor.vscode.extensions;
  };
}
