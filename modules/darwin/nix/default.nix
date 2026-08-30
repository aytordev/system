moduleArgs @ {
  config,
  lib,
  ...
}: let
  cfg = config.aytordev.nix;
in {
  imports = [
    (lib.getFile "modules/common/nix/default.nix")
    ./inputs.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(moduleArgs ? secretsRoot);
        message = "Reusable Darwin modules must not receive the private secrets root";
      }
    ];

    aytordev.nix.extraTrustedUsers =
      lib.optional (
        config.system.primaryUser != null
      )
      config.system.primaryUser;

    # Nix-Darwin config options
    # Check corresponding shared imported module
    nix = {
      # Options that aren't supported through nix-darwin
      extraOptions = ''
        # bail early on missing cache hits
        connect-timeout = 10
        keep-going = true
      '';

      gc = {
        interval = [
          {
            Hour = 3;
            Minute = 15;
            Weekday = 1;
          }
        ];
      };

      # Optimize nix store after cleaning
      optimise.interval = lib.lists.forEach config.nix.gc.interval (e: {
        inherit (e) Minute Weekday;
        Hour = e.Hour + 1;
      });

      # NOTE: not sure if i saw any benefits changing this
      # daemonProcessType = "Adaptive";

      settings = {
        build-users-group = "nixbld";

        extra-substituters = [
          "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        extra-sandbox-paths = [
          "/System/Library/Frameworks"
          "/System/Library/PrivateFrameworks"
          "/usr/lib"

          "/private/tmp"
          "/private/var/tmp"
          "/usr/bin/env"
        ];

        # Frequent issues with networking failures on darwin
        # limit number to see if it helps
        http-connections = lib.mkForce 25;

        # FIXME: upstream bug needs to be resolved before fully enabling
        # https://github.com/NixOS/nix/issues/12698
        sandbox = lib.mkForce "relaxed";
      };
    };
  };
}
