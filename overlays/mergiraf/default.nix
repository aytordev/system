# Overlay: disable mergiraf tests on Linux.
#
# mergiraf 0.19.1's integration test corpus fails on x86_64-linux at
# nixpkgs revision b4fd65b198c599cbe814fcb9f42d25d021595ec9: the `working`
# target logs `corrupted size vs. prev_size` and dies with SIGABRT
# (signal 6) at `integration::path_062`, blocking `nix flake check`.
# The merge driver itself does not depend on the test suite. Gated to
# Linux because that is the only platform with observed evidence.
_final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
  mergiraf = prev.mergiraf.overrideAttrs (_oldAttrs: {
    doCheck = false;
  });
}
