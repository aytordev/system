{
  inputs,
  lib,
  pkgs,
  ...
}: let
  username = "shell-user";
  homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home = inputs.self.lib.system.mkHome {
    inherit username;
    system = pkgs.stdenv.hostPlatform.system;
    hostname = "shell-host";
    modules = [
      {
        aytordev = {
          user = {
            enable = true;
            name = username;
            email = "shell@example.test";
            fullName = "Shell User";
            home = homeDirectory;
          };
        };
        home.stateVersion = "25.11";
      }
      {aytordev.suites.common.enable = true;}
      {aytordev.suites.development.enable = true;}
    ];
  };
  inherit (home) config;

  packageNames = map lib.getName config.home.packages;

  # Heavy closures the shell modules must not install just for a shell:
  # grc  (1.3 GiB Perl runtime for an inactive fish plugin)
  # pure (dead prompt once starship owns the prompt)
  bannedPackages = {
    grc = "grc drags in the full Perl runtime (~1.3 GiB) for an inactive fish plugin";
    pure = "pure (fish prompt) is dead weight while starship owns the prompt";
  };
  failures = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: reason:
        lib.optionalString (lib.elem name packageNames) "${name} must not be in shell packages: ${reason}"
    )
    bannedPackages
  );
in
  lib.throwIf (failures != "") failures "shell-closure" (
    pkgs.runCommand "shell-closure" {} ''
      touch "$out"
    ''
  )
