{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}: let
  version = "0.11.8";

  sources = {
    "x86_64-linux" = fetchurl {
      url = "https://github.com/coder/agentapi/releases/download/v${version}/agentapi-linux-amd64";
      hash = "sha256-IiqgZougBIM8c6nkwVQpsyRI2bx4wX57jGHpsHGhuBs=";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/coder/agentapi/releases/download/v${version}/agentapi-linux-arm64";
      hash = "sha256-0ycqFS7MdbeR4Kk7rjdgu3ARYQidL0zo1eGlPY9gW/s=";
    };
    "x86_64-darwin" = fetchurl {
      url = "https://github.com/coder/agentapi/releases/download/v${version}/agentapi-darwin-amd64";
      hash = "sha256-3ydRcNc9DtOTMYgQ1PdIA8yUVbnVQPBRw6yt8+Z9DcY=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://github.com/coder/agentapi/releases/download/v${version}/agentapi-darwin-arm64";
      hash = "sha256-VGnDxxROANCl9mKnaqW0BESen2PRmQ2XeFXgqxnO5z4=";
    };
  };
in
  stdenvNoCC.mkDerivation {
    pname = "agentapi";
    inherit version;

    src = sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src $out/bin/agentapi
      chmod +x $out/bin/agentapi
      runHook postInstall
    '';

    meta = with lib; {
      description = "HTTP API wrapper for AI coding agents (Claude Code, Aider, Gemini, etc.)";
      homepage = "https://github.com/coder/agentapi";
      license = licenses.asl20;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "agentapi";
    };
  }
