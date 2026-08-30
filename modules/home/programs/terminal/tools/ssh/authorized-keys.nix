{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.ssh;
in {
  config = lib.mkIf cfg.enable {
    home = {
      file = lib.optionalAttrs (cfg.authorizedKeys != []) {
        ".ssh/authorized_keys".text = lib.concatStringsSep "\n" cfg.authorizedKeys;
      };
      activation.createSshControlmastersDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ~/.ssh/controlmasters
        chmod 700 ~/.ssh/controlmasters
      '';
      packages = [
        (pkgs.writeShellScriptBin "ssh-fix-perms" ''
          find "$HOME/.ssh" -type f -not -name "*.pub" -exec chmod 600 {} +
          find "$HOME/.ssh" -type d -exec chmod 700 {} +
          find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} + 2>/dev/null
        '')
      ];
      shellAliases = {
        ssh-fix-perms = "${config.home.profileDirectory}/bin/ssh-fix-perms";
      };
    };
  };
}
