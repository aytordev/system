{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  imports = [
    ../libraries
    ./overlays
    ./packages
    ./configs
    ./home
    inputs.flake-parts.flakeModules.partitions
  ];

  # Dev partition: separate flake with own lock
  partitions.dev = {
    module = ./dev;
    extraInputsFlake = ./dev;
  };

  partitionedAttrs = lib.genAttrs [
    "checks"
    "devShells"
    "formatter"
    "templates"
  ] (_: "dev");
}
