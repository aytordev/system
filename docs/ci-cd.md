# CI/CD Design

This document explains how continuous integration works for this repository,
why it is shaped the way it is, and how to troubleshoot it. It is the
human-facing counterpart to the agent protocol in
[`.github/AGENTS.md`](../.github/AGENTS.md).

## What CI Does

GitHub Actions runs five workflows:

1. **`check.yml`** — the main gate. Runs `nix flake check` on `x86_64-linux`
   and `aarch64-darwin`, covering unit checks, integration checks, production
   host/home builds, and package builds.
2. **`fmt.yml`** — runs the treefmt check (`statix`, `deadnix`, formatters) on
   Linux only.
3. **`build-dev-shells.yml`** — builds every dev shell on both platforms so the
   closures are cached.
4. **`update-flakes.yml`** — nightly dependency bump that opens a PR when
   `nixpkgs` moves.
5. **`label.yml`** — applies area labels to PRs from changed paths.

## The `secrets` Problem (why every command has a long flag)

The flake declares a private input that CI cannot reach:

```nix
secrets.url = "git+ssh://git@github.com/aytordev/secrets.git";
```

GitHub Actions runs on throwaway runners with no SSH key for that repo, so any
command that evaluates the flake would fail with
`Permission denied (publickey)`.

The repository ships a **test double** that mimics the identity contract:
`checks/fixtures/secrets` (a tiny flake exporting dummy `username`,
`useremail`, `userfullname`). CI substitutes it for the real input:

```bash
nix flake check --override-input secrets path:./checks/fixtures/secrets
```

Every workflow command that evaluates the flake **must** carry this override.
If you see a `Permission denied (publickey)` failure in CI, the first thing to
check is whether the override is present on the failing command.

`update-flakes.yml` avoids the problem differently: it lists every updatable
input explicitly and **omits** `secrets`, so `nix flake update` never contacts
the private repo.

## Cost Optimization

| Technique | Effect |
| --- | --- |
| `concurrency` + `cancel-in-progress` | Kills superseded runs; a rapid push only pays for the last one |
| `push` limited to `main` | A branch with an open PR runs `pull_request` only — not twice |
| `fail-fast: false` | Both platforms always report; no wasted re-run to see the second platform |
| Path filters on dev-shells | Only rebuild dev shells when relevant files change |

On the free tier this keeps the repo well within monthly minutes for typical
workloads.

## Caching

- **Pulls**: `check.yml` and `build-dev-shells.yml` pull from `nix-community`
  and the project cache `anyrun` (via `cachix-action`).
- **Pushes**: the workflows contain `authToken: ${{ secrets.CACHIX_AUTH_TOKEN }}`.
  Until that secret is set in the repo, results are not pushed back — builds
  are fast when inputs are already cached, slow on first build. Set the secret
  to enable warm caches for new inputs.

## Actions Versioning

Actions are pinned by tag (e.g. `actions/checkout@v7`,
`cachix/install-nix-action@v31`). Dependabot opens PRs to bump them.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `Permission denied (publickey)` | A command evaluates the flake without the fixture override | Add `--override-input secrets path:./checks/fixtures/secrets` |
| `ignoring untrusted flake configuration setting 'extra-substituters'` | Missing `--accept-flake-config` | Add it so the flake's substituters are trusted |
| Two identical runs per PR | Old `on: [push, pull_request]` on a branch | Ensure `push` is limited to `main` |
| Slow first build | Cache push inactive | Set `CACHIX_AUTH_TOKEN` in repo secrets |
| `nix flake update` fails fetching secrets | Updating all inputs | Restrict the update to the non-secret inputs |

## Local Reproduction

The fastest local check that mirrors CI:

```bash
nix flake check --override-input secrets path:./checks/fixtures/secrets --accept-flake-config
```
