{
  lib,
  hostname ? null,
  ...
}: let
  inherit (lib) types;
  inherit (lib.aytordev) mkOpt;
in {
  options.aytordev.host = {
    name = mkOpt (types.nullOr types.str) hostname "The host name.";
  };
}
