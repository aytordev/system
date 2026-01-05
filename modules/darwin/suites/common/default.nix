{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
{
  imports = [ (lib.getFile "modules/common/suites/common/default.nix") ];
}
