{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}: let
  version = "2.10.1";
  # Provenance: source is pinned by the upstream git tag `v2.10.1`. Upstream
  # publishes no release assets on any release (the `releases/latest` asset
  # array is empty), so the tag and this Nix fetch hash are the only pin.
  # gentle-ai pins the same version as `GGAVersion = "2.10.1"` in its own
  # `internal/versions/versions.go`; that pin is not mechanically visible to
  # Nix, so keeping both at 2.10.1 here is a manual alignment.
  #
  # The upstream `bin/gga` defaults `VERSION="${GGA_VERSION:-dev}"`; the
  # postPatch below injects the real tag version so `gga --version` reports
  # `gga v2.10.1` (and the update probe is not silenced by `dev`).
in
  stdenv.mkDerivation {
    pname = "gga";
    inherit version;

    src = fetchFromGitHub {
      owner = "Gentleman-Programming";
      repo = "gentleman-guardian-angel";
      rev = "v${version}";
      hash = "sha256-hZSgjEI9Nkni6wCG6ou8GyB7BfQtAP4ZJZvS7qEiJq8=";
    };

    postPatch = ''
      substituteInPlace bin/gga \
        --replace-fail 'VERSION="''${GGA_VERSION:-dev}"' 'VERSION="${version}"'
    '';

    # Pure Bash: no build step. Upstream `bin/gga` resolves its libraries
    # relative to its own invocation path (`BASH_SOURCE[0]`), and the
    # home-manager profile links only `bin/`, never package `lib/`
    # directories. The real script therefore lives at
    # `$out/libexec/gga/gga` with the libraries at `$out/libexec/lib/gga/`,
    # satisfying upstream's `$(dirname "$SCRIPT_DIR")/lib/gga` candidate,
    # and `$out/bin/gga` is a tiny POSIX wrapper that execs the absolute
    # store path so the profile symlink reaches the same layout.
    installPhase = ''
      runHook preInstall
      install -Dm755 bin/gga $out/libexec/gga/gga
      install -Dm644 lib/providers.sh -t $out/libexec/lib/gga/
      install -Dm644 lib/cache.sh -t $out/libexec/lib/gga/
      install -Dm644 lib/pr_mode.sh -t $out/libexec/lib/gga/
      install -Dm644 LICENSE $out/share/gga/LICENSE
      mkdir -p $out/bin
      printf '#! /bin/sh\nexec %s "$@"\n' "$out/libexec/gga/gga" > $out/bin/gga
      chmod 755 $out/bin/gga
      runHook postInstall
    '';

    meta = {
      description = "Provider-agnostic AI code review CLI from Gentleman Programming";
      homepage = "https://github.com/Gentleman-Programming/gentleman-guardian-angel";
      license = lib.licenses.mit;
      mainProgram = "gga";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  }
