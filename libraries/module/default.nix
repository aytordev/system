{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
    toUpper
    mkDefault
    mkForce
    ;
in
rec {
  /**
    Create a nixpkgs option.
  */
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  /**
    Create a nixpkgs option without a description.
  */
  mkOpt' = type: default: mkOpt type default null;

  /**
    Create a boolean nixpkgs option.
  */
  mkBoolOpt = mkOpt types.bool;

  /**
    Create a boolean nixpkgs option without a description.
  */
  mkBoolOpt' = mkOpt' types.bool;

  /**
    Standard enabled pattern.
  */
  enabled = {
    enable = true;
  };

  /**
    Standard disabled pattern.
  */
  disabled = {
    enable = false;
  };

  /**
    Capitalize a string.
  */
  capitalize =
    s:
    let
      len = lib.stringLength s;
    in
    if len == 0 then "" else (toUpper (lib.substring 0 1 s)) + (lib.substring 1 len s);

  /**
    Convert a boolean to a number.
  */
  boolToNum = bool: if bool then 1 else 0;

  /**
    Apply mkDefault to all attributes in a set.
  */
  default-attrs = lib.mapAttrs (_key: mkDefault);

  /**
    Apply mkForce to all attributes in a set.
  */
  force-attrs = lib.mapAttrs (_key: mkForce);

  /**
    Apply default-attrs to nested attribute sets.
  */
  nested-default-attrs = lib.mapAttrs (_key: default-attrs);

  /**
    Apply force-attrs to nested attribute sets.
  */
  nested-force-attrs = lib.mapAttrs (_key: force-attrs);
}
