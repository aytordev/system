{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "4.6.0";

  # Official v4.6.0 release archive digests, cross-checked three ways: the
  # release's own checksums.txt, a prefetch of each published archive, and the
  # publisher's tagged installer (gentle-ai-installer.mjs, INSTALLER_VERSION
  # 4.6.0, gentle-shell tag v4.9.0), converted to SRI locally. fetchurl verifies
  # the SHA-256; it does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-V8u46R/oAmi2Tu66nR87hkXTo22yYsvzIgFDpZS/IUs=";
    aarch64-darwin = "sha256-fpOe91k7hOUuqMVjBkwO0P2yKPwbY3j6DAlnZpXHKqw=";
    x86_64-linux = "sha256-xkXoVR9uP3mDGxQqawh3ldwyF+Auna+1twHcQ3OzPn0=";
    aarch64-linux = "sha256-q1ovVf9BKBvEG66i7HMNywXo9V86nuogHAAWk75JDTI=";
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
