{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "2.9.0";

  # Chosen form: the pinned upstream release archive (ADR 0015 C12 / T27).
  # Source build (buildGoModule) is the documented alternative in
  # docs/ai-tools/evidence/engine-feasibility.md; the prebuilt archive was
  # proved to build and run on aarch64-darwin in docs/ai-tools/evidence/engine-prototype-results.md.
  #
  # Caveat (unresolved): `fetchurl` verifies the SHA-256 only. The release's
  # `checksums.txt.minisig` is not validated because the minisign public key
  # has no maintainer-independent provenance yet. The SHA-256 below is pinned
  # from the upstream release (aarch64-darwin independently re-downloaded and
  # hashed; the other platforms are read from the signed manifest and are not
  # independently verified here). The pinned nixpkgs rejects bare hex in
  # `fetchurl`, so the digests are encoded as SRI (`nix hash convert`).
  hashes = {
    x86_64-darwin = "sha256-DhzgsRfm8VtW4F3v7LM6M4JcLiXrgwbfCUAdQeChdvs=";
    aarch64-darwin = "sha256-CljYHNfXYxXh0R7Pazirsn7o5+cJoEyaeG6JY2+1Wbs=";
    x86_64-linux = "sha256-fUFM2Muo3cCrn6S8MJkyY4xTMhey+ZmypS56T8C/bxQ=";
    aarch64-linux = "sha256-K9q0aEtdQV35yUI8ICKwF8fBwdkFb1aswIYz+g2CHPw=";
  };

  releaseArch = {
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
  };

  system = stdenv.hostPlatform.system;
in
  stdenv.mkDerivation {
    pname = "gentle-ai";
    inherit version;

    src = fetchurl {
      url = "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${version}/gentle-ai_${version}_${releaseArch.${system}}.tar.gz";
      hash = hashes.${system};
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 gentle-ai $out/bin/gentle-ai
      install -Dm644 LICENSE $out/share/gentle-ai/LICENSE
      runHook postInstall
    '';

    meta = {
      description = "Ecosystem, frameworks, and workflows for AI coding agents";
      homepage = "https://github.com/Gentleman-Programming/gentle-ai";
      license = lib.licenses.mit;
      mainProgram = "gentle-ai";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  }
