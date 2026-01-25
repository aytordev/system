{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  pname = "sketchybar-app-font";
  version = "master";

  src = fetchurl {
    url = "https://github.com/kvndrsslr/sketchybar-app-font/archive/master.tar.gz";
    sha256 = "000jpg808mp3q23wnbk9qlv75r694agcv19ladayi54ib9ikpsqx";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/lib/sketchybar-app-font

    cp sketchybar-app-font.ttf $out/share/fonts/truetype/
    cp icon_map.lua $out/lib/sketchybar-app-font/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Sketchybar App Font";
    homepage = "https://github.com/kvndrsslr/sketchybar-app-font";
    license = licenses.mit; # Check real license
  };
}
