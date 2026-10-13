{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  version = "3.1.0";
in
  buildGoModule {
    pname = "engram";
    inherit version;

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "engram";
      rev = "v${version}";
      hash = "sha256-Dyzi/OH0XwT3Z1QfDM/Tvd6bYcXvQux/jff86st5t30=";
    };

    vendorHash = "sha256-roVQ+K9Hsz0qi61f+zzb+JvgleOmBHSMcKfhwhI0snQ=";

    subPackages = ["cmd/engram"];

    # v2.0.0-rc and v3.1.0 autosync e2e tests bind a loopback port via
    # `httptest`, which the Nix sandbox forbids. Re-verified against 3.1.0 by
    # temporarily enabling the checks: `net/http/httptest.newLocalListener`
    # panics from `cmd/engram/autosync_e2e_test.go` in
    # TestMutationTransportAdapterForwardsPromptAuthority and `cmd/engram`
    # fails. The package compiles cleanly; only the sandbox-incompatible
    # checks are skipped.
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
