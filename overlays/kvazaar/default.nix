# Overlay: disable kvazaar tests on Darwin.
#
# kvazaar 2.3.2 tests fail on macOS after the nixpkgs 2026-05 update,
# blocking the ffmpeg-full build.
_final: prev: {
  kvazaar = prev.kvazaar.overrideAttrs (_oldAttrs: {
    doCheck = false;
  });
}
