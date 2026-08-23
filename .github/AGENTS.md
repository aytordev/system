# GitHub Workflows

This directory defines the GitHub Actions CI/CD and repository automation.
Nix is used for every build step; there are no action version files beyond the
standard `github-actions` ecosystem.

## Workflows

- `check.yml`: `nix flake check` on both `x86_64-linux` (ubuntu-latest) and
  `aarch64-darwin` (macos-latest), plus `flake-checker` for input hygiene. The
  private `secrets` input is overridden with the non-sensitive fixture:
  `nix flake check --override-input secrets path:./checks/fixtures/secrets`.
- `fmt.yml` — builds `.#checks.x86_64-linux.treefmt` (formatting/typos/lint
  gate). Does not run on macOS.
- `build-dev-shells.yml` — builds every dev shell on both platforms and caches
  the closures in Cachix (`anyrun`).
- `update-flakes.yml` — scheduled daily; runs `nix flake update` for the root
  and `flake/dev` lockfiles and opens a PR when `nixpkgs` changed.
- `label.yml` — labeler triage based on `.github/labeler.yml`.

## Secrets Handling

The public repository has no real credentials. `checks/fixtures/secrets` is the
non-sensitive identity test double (see its README). CI never needs the private
`secrets` flake.

If a workflow must consume secrets/vars, prefer repository-wide vars and
`actions/create-github-app-token` (as `update-flakes.yml` does) over hardcoded
tokens.

## Local Verification

CI and local checks must agree. Before relying on a workflow, reproduce its
command locally:

```bash
nix flake check --override-input secrets path:./checks/fixtures/secrets
nix build .#checks.x86_64-linux.treefmt
```

## Conventions

- Only Nix to evaluate/build; keep shell snippets minimal and bash.
- Matrices use the supported systems (`x86_64-linux`, `aarch64-darwin`) with
  `fail-fast: false` so both platforms report independently.
- Pin action versions by tag; dependabot updates `github-actions`.
- workflow `on`: triggers are push + pull_request + manual.