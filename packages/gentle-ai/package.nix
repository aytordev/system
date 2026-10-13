{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "4.1.1";

  # Official v4.1.1 release archive digests from the publisher's tagged
  # installer (gentle-ai-installer.mjs, INSTALLER_VERSION 4.1.1, gentle-shell
  # tag v4.1.0), converted to SRI locally. fetchurl verifies the SHA-256; it
  # does not verify the release's minisign signature.
  hashes = {
    x86_64-darwin = "sha256-8umuv7owVuiKjXxxk+TowEKC3BJtXqoiFryAferez/0=";
    aarch64-darwin = "sha256-gJPc7TcTDLJlNNgWYwE/gdkDk0LjPwC4yFqlMZqn7qk=";
    x86_64-linux = "sha256-V4aevNuluplCSTq0E7vBXRRuJFHE3KPqr88WP8vWRrQ=";
    aarch64-linux = "sha256-X4+jhXPuoPIRCQLwmWqgsAiqxY3A+aarvfMB3LyT9Os=";
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
