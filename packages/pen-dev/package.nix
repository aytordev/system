{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  ...
}: let
  version = "1.2.14";
in
  stdenvNoCC.mkDerivation {
    pname = "pen-dev";
    inherit version;

    # Pen is the rebranded Pencil canvas app (renamed upstream on 2026-09-17).
    # Releases moved to a new repository, so pin the immutable versioned release
    # asset instead of the site's /download/<name>.dmg alias, which is a moving
    # target that still serves the retired Pencil 1.2.0 build.
    src = fetchurl {
      url = "https://github.com/highagency/pen-desktop-releases/releases/download/v${version}/Pen-${version}-mac-arm64.dmg";
      hash = "sha256-5e5Z6SjAfOZrgXxtVqIkq+jsqO76qM8WO08NfEq7Liw=";
    };

    nativeBuildInputs = [undmg];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -r "Pen.app" "$out/Applications/"
      runHook postInstall
    '';

    meta = {
      description = "Design on canvas. Land in code.";
      homepage = "https://pen.dev";
      platforms = ["aarch64-darwin"];
      license = lib.licenses.unfree;
    };
  }
