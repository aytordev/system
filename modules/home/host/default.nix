{
  lib,
  host ? null,
  ...
}: let
  inherit (lib) types;
  inherit (lib.aytordev) mkOpt;
in {
  options.aytordev.host = {
    name = mkOpt (types.nullOr types.str) host "The host name.";
  };
}
