{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  ...
}: let
  version = "1.2.16";
in
  stdenvNoCC.mkDerivation {
    pname = "pen-dev";
    inherit version;

    # Pen is the rebranded Pencil canvas app (renamed upstream on 2026-09-17).
    # Releases moved to a new repository, so pin the immutable versioned release
    # asset instead of the site's /download/<name>.dmg alias, which is a moving
    # target that follows whatever build upstream publishes last.
    src = fetchurl {
      url = "https://github.com/highagency/pen-desktop-releases/releases/download/v${version}/Pen-${version}-mac-arm64.dmg";
      hash = "sha256-0NF37bSyrWFiKghQFjW4Vt3DYRSqxtDud/6wirQB6n8=";
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
