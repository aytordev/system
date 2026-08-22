{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommand "architecture-layers-check"
{
  nativeBuildInputs = [
    pkgs.findutils
    pkgs.nix
    pkgs.ripgrep
  ];
}
''
  export HOME="$(realpath .)"
  unset NIX_STORE
  export NIX_STORE_DIR=${builtins.storeDir}
  export NIX_REMOTE="$HOME/storedata"

  parse_tree() {
      local path="$1"
      local output="$2"
      local file

      : > "$output"
      while IFS= read -r -d $'\0' file; do
          if ! nix-instantiate --parse "$file" >> "$output"; then
              echo "Architecture check failed to parse: $file" >&2
              exit 1
          fi
      done < <(find "$path" -type f -name '*.nix' -print0)
  }

  reject_matches() {
      local label="$1"
      local pattern="$2"
      local path="$3"
      local output
      local status

      set +e
      output="$(rg "$pattern" "$path" 2>&1)"
      status=$?
      set -e

      if [ "$status" -eq 0 ]; then
          printf '%s\n' "$output"
          echo "Architecture boundary violated: $label" >&2
          exit 1
      fi

      if [ "$status" -ne 1 ]; then
          printf '%s\n' "$output" >&2
          echo "Architecture check failed while scanning: $label" >&2
          exit "$status"
      fi
  }

  parse_tree ${inputs.self}/modules "$TMPDIR/modules.ast"
  parse_tree ${inputs.self}/systems "$TMPDIR/systems.ast"
  parse_tree ${inputs.self}/homes "$TMPDIR/homes.ast"
  parse_tree ${inputs.self}/libraries/system "$TMPDIR/builders.ast"

  reject_matches \
      "reusable modules import concrete hosts or homes" \
      '/(systems|homes)(/|")|getFile[[:space:]]+"(systems|homes)(/|")' \
      "$TMPDIR/modules.ast"

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '/modules(/|")|getFile[[:space:]]+"modules(/|")' \
      "$TMPDIR/systems.ast"

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '/modules(/|")|getFile[[:space:]]+"modules(/|")' \
      "$TMPDIR/homes.ast"

  reject_matches \
      "system builders contain aytordev policy" \
      'aytordev[[:space:]]*=' \
      "$TMPDIR/builders.ast"

  reject_matches \
      "Home suites force downstream policy" \
      'mkForce' \
      ${inputs.self}/modules/home/suites

  reject_matches \
      "Darwin suites force downstream policy" \
      'mkForce' \
      ${inputs.self}/modules/darwin/suites

  reject_matches \
      "Darwin archetypes force downstream policy" \
      'mkForce' \
      ${inputs.self}/modules/darwin/archetypes

  reject_matches \
      "Darwin modules own user LaunchAgents" \
      'launchd\.user\.agents' \
      ${inputs.self}/modules/darwin

  touch "$out"
''
