{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "5.0.0";

  # SHA-256 of each official v5.0.0 archive, checked against checksums.txt,
  # GitHub's asset digest, and gentle-shell v5.0.0's tagged
  # scripts/gentle-ai-installer.mjs. fetchurl enforces the archive hash but
  # does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-tdqDM3xsIqVDDtXtYIsUPOEDMvllSKGxEaXgqDdQejY=";
    aarch64-darwin = "sha256-i+cXHWeaS3da9LZOM+wsMZTh/YPNjZ+WDvodZSZ29uw=";
    x86_64-linux = "sha256-9tyM/BbzCtEd/plgjKUGVxvh4lRQ6dSo2FFUVTcXaK8=";
    aarch64-linux = "sha256-lAZwISRNYMwq0PYxOEMEjrTpXWExTByVDLNRWxr3500=";
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
