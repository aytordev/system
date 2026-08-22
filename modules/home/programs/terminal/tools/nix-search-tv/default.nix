{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.aytordev.programs.terminal.tools.nix-search-tv;
in {
  options.aytordev.programs.terminal.tools.nix-search-tv = {
    enable = lib.mkEnableOption "nix-search-tv";
    package = lib.mkPackageOption pkgs "nix-search-tv" {nullable = true;};
  };

  config = mkIf cfg.enable {
    programs.nix-search-tv = {
      enable = true;
      inherit (cfg) package;

      settings = {
        indexes =
          [
            "nixpkgs"
            "home-manager"
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            "nixos"
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            "darwin"
          ];
      };
    };
  };
}
