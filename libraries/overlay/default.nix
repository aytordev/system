{ inputs, ... }:
let
  aytordevLib = import ../default.nix {
    inherit inputs;
    lib = inputs.nixpkgs.lib;
    self = inputs.self;
  };
in
_final: _prev: {
  # Expose as lib.aytordev namespace
  aytordev = aytordevLib.flake.lib;

  # Direct access to commonly used functions
  inherit (aytordevLib.flake.lib)
    relativeToRoot
    ;

  inherit (aytordevLib.flake.lib.file)
    parseSystemConfigurations
    parseHomeConfigurations
    importModulesRecursive
    ;

  inherit (aytordevLib.flake.lib.module)
    enabled
    disabled
    mkOpt
    mkBoolOpt
    ;
}
