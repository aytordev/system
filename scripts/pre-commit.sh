#!/usr/bin/env bash
# Pre-commit hook to run statix check and treefmt
set -e

# Function to run a command if it exists, otherwise warn or try nix run
run_check() {
    CMD=$1
    NIX_PKG=$2
    ARGS=$3
    DESC=$4

    echo "Running $DESC..."
    if command -v "$CMD" >/dev/null; then
        $CMD $ARGS
    elif command -v nix >/dev/null; then
        echo "$CMD not found in PATH. Trying nix run..."
        nix run "$NIX_PKG" -- $ARGS
    else
        echo "WARNING: $CMD and nix not found. Skipping $DESC."
    fi
}

echo "=============================="
echo "Pre-commit Checks"
echo "=============================="

# Statix Check
# We run statix check on the current directory
if ! run_check "statix" "nixpkgs#statix" "check ." "Statix Lint"; then
    echo "❌ Statix check failed. Please fix the errors above."
    exit 1
fi

# Treefmt Check (Optional style check)
# if ! run_check "treefmt" ".#treefmt" "--fail-on-change" "Treefmt Check"; then
#     echo "❌ Treefmt failed. Run 'nix fmt' or 'just fmt' to fix."
#     exit 1
# fi

echo "✅ All pre-commit checks passed!"
