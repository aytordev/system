{
  inputs,
  lib,
  pkgs,
  ...
}: let
  tests = import ../../tests {
    inherit (inputs) self;
    inherit lib;
  };
  testsFile = pkgs.writeText "nix-unit-tests.nix" (lib.generators.toPretty {} tests);
in
  pkgs.runCommand "nix-unit-check"
  {
    nativeBuildInputs = [inputs.nix-unit.packages.${pkgs.stdenv.hostPlatform.system}.default];
  }
  ''
    export HOME="$(realpath .)"
    unset NIX_STORE
    export NIX_STORE_DIR=${builtins.storeDir}
    export NIX_REMOTE="$HOME/storedata"
    nix-unit --show-trace ${testsFile}
    touch "$out"
  ''
