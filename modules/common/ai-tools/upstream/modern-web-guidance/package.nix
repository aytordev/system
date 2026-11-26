{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
  python3,
}: let
  inherit ((import ../../catalog.nix).modern-web-guidance) release;
in
  stdenvNoCC.mkDerivation {
    pname = "modern-web-guidance";
    inherit (release) version;
    src = fetchurl {inherit (release) url hash;};

    nativeBuildInputs = [makeWrapper python3];
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      python3 ${./prepare.py} "$out" ${lib.escapeShellArg release.version}
      makeWrapper ${lib.getExe nodejs} "$out/bin/modern-web-guidance" \
        --add-flags "$out/libexec/modern-web-guidance/modern-web.mjs" \
        --set DISABLE_TELEMETRY 1 \
        --set ENABLE_FILE_LOGGING false
      runHook postInstall
    '';

    meta = {
      description = "Pinned GoogleChrome web guidance and offline search CLI for Pi";
      homepage = release.repository;
      license = [lib.licenses.asl20 lib.licenses.cc-by-40];
      mainProgram = "modern-web-guidance";
      platforms = lib.platforms.darwin ++ lib.platforms.linux;
    };
  }
