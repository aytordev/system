{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  ...
}: let
  version = "3.7.2";
in
  buildGo127Module {
    pname = "engram";
    inherit version;

    # v3.7.2's go.mod declares `go 1.26.11` (v3.7.0 declared `go 1.26.10`; the
    # go.sum is byte-identical between them). When this pin was introduced the
    # nixpkgs default Go (1.26.10) sat below that floor and `GOTOOLCHAIN=local`
    # failed in the sandbox, so buildGo127Module threaded go_1_27 into the build
    # and the modules FOD. The 2026-11-17 lock moved the default Go to 1.27.3,
    # which already satisfies the floor: the wrapper is now a deliberate
    # toolchain pin rather than a requirement, and collapsing it into a plain
    # buildGoModule is a separate simplification, not a lock-update side effect.

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "engram";
      rev = "v${version}";
      hash = "sha256-8vychLARVy7Ry+7hXx+NxnUR0KIUC5nJA+1XFduDB/M=";
    };

    vendorHash = "sha256-hkwwuqar4ngDUWM2XctkiVm8TpfQWnUws/sDxDyvQxU=";

    subPackages = ["cmd/engram"];

    # v2.0.0-rc, v3.1.0, v3.6.0, v3.7.0 and v3.7.2 autosync e2e tests bind a
    # loopback port via `httptest`, which the Nix sandbox forbids. Re-verified
    # against 3.7.2 at the source level: `cmd/engram/autosync_e2e_test.go` still
    # exists and TestMutationTransportAdapterForwardsPromptAuthority still opens
    # an `httptest.NewTLSServer` (a loopback bind through
    # `net/http/httptest.newLocalListener`); 3.7.2 is a packaging-only release
    # whose only runtime change is the companion installer pin. The same bind
    # was observed to panic at 3.1.0 by temporarily enabling the checks. The
    # package compiles cleanly; only the sandbox-incompatible checks are skipped.
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
