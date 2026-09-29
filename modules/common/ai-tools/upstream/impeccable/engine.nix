{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}: let
  upstream = (import ../../catalog.nix).impeccable;
  inherit (upstream.engine) version assets;
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation {
    pname = "impeccable-engine";
    inherit version;

    src = fetchurl {
      url = "https://github.com/${upstream.source.owner}/${upstream.source.repo}/releases/download/${upstream.engine.release.tagPrefix}${version}/impeccable-${asset.platform}";
      sha256 = asset.hash;
    };

    dontUnpack = true;
    # Preserve official release bytes: no stripping, patching, or signing.
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/impeccable"
      runHook postInstall
    '';

    passthru.releasePlatform = asset.platform;

    meta = {
      description = "Pinned official Impeccable design engine";
      homepage = "https://github.com/pbakaus/impeccable";
      license = lib.licenses.asl20;
      mainProgram = "impeccable";
      platforms = builtins.attrNames assets;
    };
  }
