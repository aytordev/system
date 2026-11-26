{
  lib,
  pkgs,
  ...
}: let
  package = pkgs.aytordev.modern-web-guidance;
in
  pkgs.runCommand "modern-web-guidance-offline-check" {
    nativeBuildInputs = [pkgs.python3];
  } ''
    python3 ${./offline.py} ${lib.getExe package} ${package}/share/modern-web-guidance/skills
    touch "$out"
  ''
