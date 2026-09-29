{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  impeccable-engine,
  ...
}: let
  upstream = (import ../../catalog.nix).impeccable.source;
  upstreamRev = upstream.rev;
in
  stdenvNoCC.mkDerivation {
    pname = "impeccable-skills";
    inherit (upstream) version;

    src = fetchFromGitHub {
      inherit (upstream) owner repo rev hash;
    };

    dontBuild = true;
    # In particular, do not rewrite the upstream launcher's /bin/sh shebang.
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/impeccable"
      cp -R ${upstream.payloadPath}/. "$out/share/impeccable/"
      cp LICENSE NOTICE.md "$out/share/impeccable/"
      mkdir -p "$out/share/impeccable/scripts/bin/${impeccable-engine.releasePlatform}"
      ln -s ${impeccable-engine}/bin/impeccable \
        "$out/share/impeccable/scripts/bin/${impeccable-engine.releasePlatform}/impeccable"
      runHook postInstall
    '';

    passthru = {inherit upstreamRev;};

    meta = {
      description = "Unmodified upstream Impeccable Pi skill with its pinned sibling engine";
      homepage = "https://github.com/pbakaus/impeccable";
      license = lib.licenses.asl20;
      platforms = impeccable-engine.meta.platforms;
    };
  }
