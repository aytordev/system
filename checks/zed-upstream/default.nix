{pkgs, ...}: let
  zedRoot = ../../modules/home/programs/desktop/editors/zed;
  updater = import (zedRoot + "/updater.nix") {inherit pkgs;};
  snapshot = builtins.fromJSON (builtins.readFile (zedRoot + "/snapshot.json"));
  # Only the active archived generation: no locks, pending work or owned config.
  snapshotSource = pkgs.lib.fileset.toSource {
    root = zedRoot;
    fileset = pkgs.lib.fileset.unions [
      (zedRoot + "/snapshot.json")
      (zedRoot + "/snapshots/${snapshot.generation}")
    ];
  };
in
  pkgs.runCommand "zed-upstream-offline-check"
  {
    passthru = {inherit updater;};
    nativeBuildInputs = [updater.python];
    PYTHONDONTWRITEBYTECODE = "1";
  }
  ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export ZED_UPDATER_SOURCE=${../../modules/home/programs/desktop/editors/zed/update.py}
    export ZED_UPDATER_BIN=${pkgs.lib.getExe updater}
    export ZED_SNAPSHOT_ROOT=${snapshotSource}
    python3 -B ${./test_updater.py}
    touch "$out"
  ''
