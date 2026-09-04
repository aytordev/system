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
        $DRY_RUN_CMD mkdir -p ~/.ssh/controlmasters
        $DRY_RUN_CMD chmod 700 ~/.ssh/controlmasters
      '';
      packages = [
        (pkgs.writeShellApplication {
          name = "ssh-fix-perms";
          text = ''
            [ -d "$HOME/.ssh" ] || exit 0
            find "$HOME/.ssh" -type f -not -name "*.pub" -exec chmod 600 {} +
            find "$HOME/.ssh" -type d -exec chmod 700 {} +
            find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} + 2>/dev/null
          '';
        })
      ];
    };
  };
}
