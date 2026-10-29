{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}: let
  version = "3.6.0";
in
  buildGo127Module {
    pname = "engram";
    inherit version;

    # v3.6.0's go.mod declares `go 1.26.10`, above the nixpkgs default Go
    # (1.26.8), which fails `GOTOOLCHAIN=local` in the sandbox.
    # buildGo127Module threads go_1_27 into the build and the modules FOD.

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "engram";
      rev = "v${version}";
      hash = "sha256-lVLGjn/eYUNy5S/Ct9lTWGiFso40EKrlIDmD+aUaDgg=";
    };

    vendorHash = "sha256-hkwwuqar4ngDUWM2XctkiVm8TpfQWnUws/sDxDyvQxU=";

    subPackages = ["cmd/engram"];

    # v2.0.0-rc, v3.1.0 and v3.6.0 autosync e2e tests bind a loopback port
    # via `httptest`, which the Nix sandbox forbids. Re-verified against 3.6.0
    # at the source level: `cmd/engram/autosync_e2e_test.go` still exists and
    # TestMutationTransportAdapterForwardsPromptAuthority still opens an
    # `httptest.NewTLSServer` (a loopback bind through
    # `net/http/httptest.newLocalListener`). The same bind was observed to
    # panic at 3.1.0 by temporarily enabling the checks. The package compiles
    # cleanly; only the sandbox-incompatible checks are skipped.
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
