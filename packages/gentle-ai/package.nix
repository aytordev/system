{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "4.2.0";

  # Official v4.2.0 release archive digests, cross-checked three ways: a local
  # download of the archives, the release's own checksums.txt, and the
  # publisher's tagged installer (gentle-ai-installer.mjs, INSTALLER_VERSION
  # 4.2.0, gentle-shell tag v4.3.0), converted to SRI locally. fetchurl
  # verifies the SHA-256; it does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-j2qR4PmcrDrqE4cF19Ii6jQvU6R2AtSMsBSIlSocEvg=";
    aarch64-darwin = "sha256-1emmUh3l8Io5NjXwg/ZNx6/BuOl4hPeqta5esfF8fzc=";
    x86_64-linux = "sha256-VSwWQv0Q9dls/puxzDtmsw60fTB0zHygVZtZjrCG3vw=";
    aarch64-linux = "sha256-K+vpG4gIzkjYbE03ANCY43y2sGWPGWxmbZ3u63x8Gno=";
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
