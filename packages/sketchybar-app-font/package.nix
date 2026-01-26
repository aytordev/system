{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}: let
  version = "2.0.51";
  baseUrl = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v${version}";

  font = fetchurl {
    url = "${baseUrl}/sketchybar-app-font.ttf";
    sha256 = "sha256-Fp4jiSACIZskyn6T7ru21TtA4q78PLLqtWLjkOqyAq8=";
  };

  iconMap = fetchurl {
    url = "${baseUrl}/icon_map.lua";
    sha256 = "sha256-xIfmDBqN8cCA2pkMgdPJdrFO1IAcEZ0TmBQVIIAdji4=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "sketchybar-app-font";
    inherit version;

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype
      mkdir -p $out/lib/sketchybar-app-font

      cp ${font} $out/share/fonts/truetype/sketchybar-app-font.ttf
      cp ${iconMap} $out/lib/sketchybar-app-font/icon_map.lua
      runHook postInstall
    '';

    meta = with lib; {
      description = "A ligature-based icon font with mappings for common applications (Sketchybar)";
      homepage = "https://github.com/kvndrsslr/sketchybar-app-font";
      license = licenses.cc0;
      platforms = platforms.all;
      maintainers = [];
    };
  }
