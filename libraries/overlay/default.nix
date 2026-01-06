{ inputs }:
_final: _prev:
let
  aytordevLib = import ../default.nix {
    inherit inputs;
    lib = inputs.nixpkgs.lib;
    self = inputs.self;
  };
in
{
  # Expose aytordev module functions directly (like aytordev.mkOpt)
  aytordev = aytordevLib.flake.lib.module;

  # Expose all aytordev lib namespaces
  inherit (aytordevLib.flake.lib)
    file
    system
    ;

  inherit (aytordevLib.flake.lib.file)
    getFile
    getNixFiles
    getDirectories
    importFiles
    importDir
    importSubdirs
    importModulesRecursive
    mergeAttrs
    parseSystemConfigurations
    parseHomeConfigurations
    ;

  inherit (aytordevLib.flake.lib.module)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    capitalize
    boolToNum
    default-attrs
    force-attrs
    nested-default-attrs
    nested-force-attrs
    ;

  # Path utilities
  inherit (aytordevLib.flake.lib)
    relativeToRoot
    ;

  # Add home-manager lib functions
  inherit (inputs.home-manager.lib) hm;
}
