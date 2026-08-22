{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommand "architecture-layers-check"
{
  nativeBuildInputs = [pkgs.ripgrep];
}
''
  reject_matches() {
      local label="$1"
      local pattern="$2"
      local path="$3"
      local output
      local status

      set +e
      output="$(rg --glob '*.nix' "$pattern" "$path" 2>&1)"
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

  reject_matches \
      "reusable modules import concrete hosts or homes" \
      '(\.\./)+(systems|homes)(/|")|lib\.getFile "(systems|homes)(/|")|inputs\.self.*"/(systems|homes)(/|")|inputs\.self\}/(systems|homes)(/|")' \
      ${inputs.self}/modules

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '(\.\./)+modules(/|")|lib\.getFile "modules(/|")|inputs\.self.*"/modules(/|")|inputs\.self\}/modules(/|")' \
      ${inputs.self}/systems

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '(\.\./)+modules(/|")|lib\.getFile "modules(/|")|inputs\.self.*"/modules(/|")|inputs\.self\}/modules(/|")' \
      ${inputs.self}/homes

  reject_matches \
      "system builders contain aytordev policy" \
      '(^|[;{])[[:space:]]*(config\.)?aytordev(\.|[[:space:]]*=)' \
      ${inputs.self}/libraries/system

  touch "$out"
''
