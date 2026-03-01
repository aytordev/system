{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  version = "1.7.0";
in
  buildGoModule {
    pname = "engram";
    inherit version;

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "engram";
      rev = "v${version}";
      hash = "sha256-XbbFjB7cX7tDPjOzUOkwt7uR+RFT6hzY74EMPF6zSK0=";
    };

    vendorHash = "sha256-hR1PS0oQcUMbsRcfd6rk2uqlXGT8wcll0H8qU09aYg0=";

    subPackages = ["cmd/engram"];

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    env.CGO_ENABLED = 0;

    meta = with lib; {
      description = "Persistent memory MCP server for AI coding agents";
      homepage = "https://github.com/Gentleman-Programming/engram";
      license = licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "engram";
    };
  }
