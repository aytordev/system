{
  lib,
  nix,
  pkgs,
}: let
  # Snapshot every *.nix file in the repository for parsing.
  repository = with lib.fileset;
    toSource {
      root = ../..;
      fileset = fileFilter (file: file.hasExt "nix") ../..;
    };
  parseLog = "$TMPDIR/nix-parse.log";
in
  pkgs.runCommand "nix-parse-${nix.name}"
  {
    nativeBuildInputs = [
      nix
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.gawk
    ];
  }
  ''
    export NIX_STORE_DIR=$TMPDIR/store
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --init

    cd "${repository}"
    # This only surfaces the first parse error, not all of them. That is
    # intentional: this check is about cross-implementation parsing confidence,
    # and the remaining jobs report syntax issues in more detail.
    if ! find . -type f -iname '*.nix' -print0 | xargs -0 -P "$(nproc)" nix-instantiate --parse 2> "${parseLog}" > /dev/null; then
      cat "${parseLog}" >&2
      echo "Parse failed in nix-instantiate (${nix.name})." >&2
      exit 1
    fi
    if grep "warning" "${parseLog}" | grep -v "unknown experimental feature" > /dev/null; then
      cat "${parseLog}" >&2
      echo "Failing due to warnings in stderr (${nix.name})." >&2
      exit 1
    fi

    touch "$out"
  ''
