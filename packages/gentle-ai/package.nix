{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "3.7.0";

  # Official release checksums.txt digests, encoded as SRI. fetchurl verifies
  # SHA-256; it does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-5V/z7gYlipDpGVwOOlk7hfbXnMQ56ebASyWWclEgphA=";
    aarch64-darwin = "sha256-ZutXQMRQbLLP0cxSB0OcYc/gdniFT0rHyDAnqVoOZmo=";
    x86_64-linux = "sha256-pzCmGkN1jwTMmkrGRJRcwOhlKh4z1pl6Cj0/AETS//U=";
    aarch64-linux = "sha256-o6PTqXTz2bZ9k1/p4waug8MF2k7Buu1KUxnBCwRM0Os=";
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
