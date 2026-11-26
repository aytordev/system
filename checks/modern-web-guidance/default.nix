{
  lib,
  pkgs,
  ...
}: let
  package = pkgs.aytordev.modern-web-guidance;
in
  pkgs.runCommand "modern-web-guidance-offline-check" {
    nativeBuildInputs = [pkgs.python3];
  } ''
    tar -xzf ${package.src} -C "$TMPDIR"
    python3 ${./prepare-check.py} ${../../modules/common/ai-tools/upstream/modern-web-guidance/prepare.py} \
      "$TMPDIR/package" ${lib.escapeShellArg package.version}
    python3 ${./offline.py} ${lib.getExe package} ${package}/share/modern-web-guidance/skills
    touch "$out"
  ''
