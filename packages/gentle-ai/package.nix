{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "3.6.0";

  # Official release checksums.txt digests, encoded as SRI. fetchurl verifies
  # SHA-256; it does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-zZElFtKdDqAv7rnGCvJz76iA1FyUUW1QG9tWlDS8vX0=";
    aarch64-darwin = "sha256-pBZaq8s0JStQHcaj9zfoR40+M0OSIpg/yP8De619ZdU=";
    x86_64-linux = "sha256-t0Lyiqss7RGujRZLy9eWj2a1BWr8B4d+Irya2RDenQ8=";
    aarch64-linux = "sha256-CbQ2s4GeuCQPyLyNz1UR1WpZPyT5vbYlnVlkGghWuAQ=";
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
