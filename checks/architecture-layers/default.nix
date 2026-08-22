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

      if rg --glob '*.nix' "$pattern" "$path"; then
          echo "Architecture boundary violated: $label" >&2
          exit 1
      fi
  }

  reject_matches \
      "reusable modules import concrete hosts or homes" \
      '(\.\./)+((systems|homes)/)|lib\.getFile "(systems|homes)/' \
      ${inputs.self}/modules

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '(\.\./)+modules/|lib\.getFile "modules/' \
      ${inputs.self}/systems

  reject_matches \
      "concrete hosts or homes import module implementations directly" \
      '(\.\./)+modules/|lib\.getFile "modules/' \
      ${inputs.self}/homes

  reject_matches \
      "system builders contain aytordev policy" \
      'aytordev\.(archetypes|environments|programs|services|suites|tools)' \
      ${inputs.self}/libraries/system

  touch "$out"
''
