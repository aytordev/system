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
| `fmt.yml` | PR, push to `main`, manual | ubuntu | `nix build .#checks.x86_64-linux.treefmt` — formatting, lint (statix), dead code (deadnix) |
| `build-dev-shells.yml` | PR/push (path-filtered), weekly | ubuntu + macos | build and cache every dev shell in Cachix (`anyrun`) |
| `update-flakes.yml` | nightly + manual | ubuntu | bump every input except `secrets`, open a PR when `nixpkgs` changed |
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

`update-flakes.yml` updates every input **except** `secrets`, so the lock bump
never needs the private repo. The list is derived from `flake.lock` (root
inputs whose lock entry is a node name, not a `follows` path) instead of being
hardcoded, so a new flake input is picked up without editing the workflow. The
dev lock is re-locked in the same run, with `root` in the list: the dev
partition's `nixpkgs` follows `root/nixpkgs`, so only re-locking `root` moves the
follower. Both commands target an explicit path (`flake.lock` and
`./flake/dev`); a bare relative path such as `flake/dev` is read as a flake
registry reference and fails.

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

- **3 core runs per PR** on open/sync: `check` × 2 platforms + `fmt` × 1
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
- `update-flakes.yml` requests only `Contents: read and write` and
  `Pull requests: read and write` from the App installation. Asking for a
  permission the installation does not grant fails the token step with HTTP 422
  (`The permissions requested are not granted to this installation`), which is
  what the nightly run hit for 100 consecutive runs. That step is
  `continue-on-error`, so a missing grant degrades to `GITHUB_TOKEN` with a
  `::warning::` instead of failing the run. The fallback PR does not trigger CI
  on its own, and opening it also needs "Allow GitHub Actions to create and
  approve pull requests" in the repository Actions settings.
