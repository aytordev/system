# OpenCode formatters configuration module
# Defines code formatters for different programming languages
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;
in {
  config = lib.mkIf cfg.enable {
    programs.opencode.settings.formatter = {
      alejandra = {
        command = [
          (lib.getExe pkgs.alejandra)
          "$FILE"
        ];
        extensions = [".nix"];
      };

      # FIXME: csharpier broken due to Swift build failure in nixpkgs
      # csharpier = {
      #   command = [
      #     (lib.getExe pkgs.csharpier)
      #     "$FILE"
      #   ];
      #   extensions = [
      #     ".cs"
      #   ];
      # };

      rustfmt = {
        command = [
          (lib.getExe pkgs.rustfmt)
          "$FILE"
        ];
        extensions = [".rs"];
      };
    };
  };
}
