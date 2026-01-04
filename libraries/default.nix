{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  self = inputs.self or ../.;

  # Import library modules
  file = import ./file { inherit inputs self; };
  module = import ./module { inherit lib; };
  system = import ./system { inherit inputs; };
  relativeToRoot = (import ./relative-to-root { inherit lib; }).relativeToRoot;
  overlay = import ./overlay { inherit inputs; };
in
{
  # Export as flake-parts module
  flake.lib = {
    # File utilities
    inherit (file)
      readFile
      pathExists
      safeImport
      scanDir
      getFile
      getNixFiles
      getDirectories
      mergeAttrs
      importFiles
      importDir
      importModulesRecursive
      parseSystemConfigurations
      parseHomeConfigurations
      filterNixOSSystems
      filterDarwinSystems
      ;

    # Path utilities
    inherit relativeToRoot;

    # Re-export with namespaces for direct access
    file = file;
    module = module;
    system = system;
    overlay = overlay;

    # System builders (also directly accessible)
    inherit (system) mkDarwin mkSystem mkHome common;

    # Module utilities (also directly accessible)
    inherit (module)
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
  };
}
