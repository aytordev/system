{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "4.3.1";

  # Official v4.3.1 release archive digests, cross-checked three ways: a local
  # download of the archives, the release's own checksums.txt, and the
  # publisher's tagged installer (gentle-ai-installer.mjs, INSTALLER_VERSION
  # 4.3.1, gentle-shell tag v4.4.0), converted to SRI locally. fetchurl
  # verifies the SHA-256; it does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-bPV/7gV02u8qvtB/VKNV/sO5OsjwFzPcbE02dPF0YRI=";
    aarch64-darwin = "sha256-E+iChEf5CBRl7gw1phsk+0kpbVGjEMaZkifirtF4lWs=";
    x86_64-linux = "sha256-BOxoXFa0LCnf9tsQ/H3CxzAhfcnJZzblOtKs8yJtr7c=";
    aarch64-linux = "sha256-mefTE6L/heryOmQV6bOq5nv3TC+habIbkwcK2nYT9qA=";
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
