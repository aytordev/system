# Overlay: disable chromaprint tests on Darwin.
#
# chromaprint 1.6.0 FFmpegAudioReaderTest.ReadRaw gets killed (signal 9)
# during the build on macOS after the nixpkgs 2026-05 update, causing
# ffmpeg-full and all its reverse dependencies (pydub, aider-chat) to fail.
_final: prev: {
  chromaprint = prev.chromaprint.overrideAttrs (_oldAttrs: {
    doCheck = false;
  });
}
