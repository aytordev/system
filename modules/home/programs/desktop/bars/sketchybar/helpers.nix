# Builds the SketchyBar C helper binaries at evaluation/build time, so a
# session start never runs `make` and never needs the Command Line Tools.
{pkgs}: let
  cFlags = ["-std=c99" "-O3"];
in
  pkgs.stdenv.mkDerivation {
    pname = "sketchybar-helpers";
    version = "unstable";
    src = ./config/helpers;

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p bin
      $CC ${builtins.concatStringsSep " " cFlags} menus/menus.c -o bin/menus \
        -F/System/Library/PrivateFrameworks/ -framework Carbon -framework SkyLight
      $CC ${builtins.concatStringsSep " " cFlags} event_providers/cpu_load/cpu_load.c -o bin/cpu_load
      $CC ${builtins.concatStringsSep " " cFlags} event_providers/network_load/network_load.c -o bin/network_load
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm555 bin/menus $out/bin/menus
      install -Dm555 bin/cpu_load $out/bin/cpu_load
      install -Dm555 bin/network_load $out/bin/network_load
      runHook postInstall
    '';

    meta = {
      description = "C helper binaries (menus and event providers) for the SketchyBar config";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.darwin;
    };
  }
