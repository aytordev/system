# GitHub Workflows

GitHub Actions CI/CD for this flake. Every build step is driven by Nix; there
are no non-Nix build steps.

## Design Principles

- **One source of truth**: CI runs the same commands you run locally
  (`nix fmt`, `nix flake check`). If a check passes locally it must pass in CI
  and vice versa.
- **Never touch private `secrets`**: the public repo has no credentials and
  must not need the private `secrets` flake. All CI evaluation uses the
  non-sensitive fixture (`checks/fixtures/secrets`) via `--override-input
  secrets path:./checks/fixtures/secrets`.
- **Fail independently**: platform matrices use `fail-fast: false` so a failure
  on one system does not cancel the other.
- **Cheap by default**: runs are deduplicated with `concurrency` and push
  triggers are limited to `main` so branch+PR work does not pay twice.

## Workflow Reference

| Workflow | Trigger | Runs | Purpose |
| --- | --- | --- | --- |
| `check.yml` | PR, push to `main`, manual | ubuntu + macos | `nix flake check` (unit/integration/production checks + package builds) plus `flake-checker` input hygiene |
| `fmt.yml` | PR, push to `main`, manual | ubuntu | `nix build .#checks.x86_64-linux.treefmt` — formatting, lint (statix), dead code (deadnix), typos |
| `build-dev-shells.yml` | PR/push (path-filtered), weekly | ubuntu + macos | build and cache every dev shell in Cachix (`anyrun`) |
| `update-flakes.yml` | nightly + manual | ubuntu | bump inputs, open a PR when `nixpkgs` changed |
| `label.yml` | PR | ubuntu | apply area labels from `.github/labeler.yml` |

### Secrets → Fixture Flow

```
flake.nix: secrets.url = "git+ssh://.../secrets.git"   (private, no CI access)
        │
        ▼  every CI command adds:
   --override-input secrets path:./checks/fixtures/secrets
        │
        ▼
checks/fixtures/secrets/flake.nix  →  username/useremail/userfullname (dummy)
        │
        ▼
flake/configs/default.nix  →  identity = self.lib.identity.fromSecrets inputs.secrets
```

`update-flakes.yml` updates every input **except** `secrets` (explicitly listed
in the `nix flake update` command), so the lock bump never needs the private
repo.

## Local Verification

CI must agree with local results. Reproduce any workflow command locally before
relying on it:

```bash
nix flake check --override-input secrets path:./checks/fixtures/secrets --accept-flake-config
nix build .#checks.x86_64-linux.treefmt --override-input secrets path:./checks/fixtures/secrets
```

> On Darwin, treefmt builds but `actionlint`/`clang-tidy` pre-commit hooks are
> Linux-only (see `flake/dev/checks`).

## Cost & Runtime Model

- **4 core runs per PR** on open/sync: `check` × 2 platforms + `fmt` × 1
  (+ dev-shells only when `dev-shells/**` or flake files change).
- `concurrency: { group: <wf>-${{ github.ref }}, cancel-in-progress: true }`
  cancels superseded runs on the same branch/PR, so rapid pushes only pay for
  the latest.
- `push` runs only on `main`; PRs run on `pull_request` (synchronize). A branch
  with an open PR never pays both.
- Cachix pulls `nix-community` + `anyrun`. Pushing to the cache is enabled in
  the workflow (`authToken`) but inactive until the repo secret
  `CACHIX_AUTH_TOKEN` exists.

## Editing a Workflow

1. Keep the fixture override on any command that evaluates the flake.
2. Add `concurrency` + limit `push` to `main` for new workflow-consuming runs.
3. Pin actions by tag; dependabot bumps `github-actions`.
4. Validate YAML locally:

   ```bash
   nix develop .#nix --command actionlint .github/workflows/*.yml
   ```

5. Update this file when the workflow set or behavior changes.

## Secrets & Vars

- Repo **vars** (non-sensitive): `CI_APP_ID`.
- Repo **secrets** (private): `CI_APP_PRIVATE_KEY` (update-flakes bot),
  `CACHIX_AUTH_TOKEN` (optional; enables cache push — set to activate).
- Prefer `actions/create-github-app-token` (as `update-flakes.yml`) over
  hardcoded tokens.
