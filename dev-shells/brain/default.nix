# Minimal per-project shell for the brain repository (B06): Bun only.
# Uses the direct pkgs.mkShellNoCC instead of the shared mkShell wrapper so
# that no common packages and no pre-commit installationScript shellHook are
# injected (flake/dev/dev-shells/default.nix).
{pkgs, ...}:
pkgs.mkShellNoCC {
  packages = [pkgs.bun];
}
