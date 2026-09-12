#!/usr/bin/env bash
# Regenerate docs/theme-support-matrix.md from the provider registry.
#
# The generator is exposed as `passthru.matrix` on the theme-catalog check, so
# this does not run the drift check itself. Usage:
#
#   bash checks/theme-catalog/regenerate.sh [system]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(git -C "$here" rev-parse --show-toplevel)"
system="${1:-$(nix eval --impure --raw --expr builtins.currentSystem)}"

matrix="$(nix build --impure --no-link --print-out-paths \
    --expr "(builtins.getFlake (toString $root)).checks.\"$system\".integration-theme-catalog.matrix")"

cp "$matrix" "$root/docs/theme-support-matrix.md"
chmod 0644 "$root/docs/theme-support-matrix.md"
echo "wrote $root/docs/theme-support-matrix.md"
