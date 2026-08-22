{
  config,
  self,
  lib,
  ...
}: let
  tests = import ../../tests {inherit self lib;};
in {
  flake.tests =
    tests
    // {
      systems = lib.genAttrs config.systems (_system: tests);
    };
}
