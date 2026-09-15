{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  version = "2.0.0-rc.11";
in
  buildGoModule {
    pname = "engram";
    inherit version;

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "engram";
      rev = "v${version}";
      hash = "sha256-Zy+RRs9IJ3ETLsiBrxFICdrMpmCnJH2gLR7QjMDNbHA=";
    };

    vendorHash = "sha256-tLWuHdnJgBSlzcyvXLzxtvzHSgoZqVXhmUjg2phBgYw=";

    subPackages = ["cmd/engram"];

    # v2.0.0-rc adds autosync e2e tests that bind a loopback port via
    # `httptest`, which the Nix sandbox forbids. The package compiles cleanly;
    # only the sandbox-incompatible checks are skipped.
    doCheck = false;

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
