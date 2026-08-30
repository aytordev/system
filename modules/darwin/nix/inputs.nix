{
  config,
  lib,
  self,
  inputs,
  ...
}: let
  cfg = config.aytordev.nix;
in {
  config = lib.mkIf cfg.enable {
    # Preserve flake inputs and the nix-darwin configuration under /etc.
    environment.etc =
      {
        # set channels (backwards compatibility)
        "nix/flake-channels/system".source = self;
        "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
        "nix/flake-channels/home-manager".source = inputs.home-manager;

        # preserve current flake in /etc
        "nix-darwin".source = self;
      }
      # Create /etc/nix/inputs symlinks for all flake inputs
      // lib.mapAttrs' (
        name: input:
          lib.nameValuePair "nix/inputs/${name}" {
            source = input.outPath or input;
          }
      ) (builtins.removeAttrs inputs ["secrets"]);
  };
}
