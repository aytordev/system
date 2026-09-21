# Contributing to aytordev/system

The repository is a personal, single-author Nix-based system configuration.
These guidelines apply to both human and AI-assisted contributions.

## Ground Rules

- Configuration is modular; changes belong in the narrowest directory that
  supports them (`modules/home` > `modules/darwin` > `modules/common`).
- All new options must be namespaced under `aytordev.*`.
- All module outputs must satisfy Module Contract V1
  ([`docs/decisions/0008-module-contract-v1.md`](docs/decisions/0008-module-contract-v1.md)).
- Never commit real secrets. The private `secrets` flake is not part of this
  repository.
- Change how-to documentation in the relevant `AGENTS.md`; record *decisions*
  as ADRs in `docs/decisions/`.

## Workflow

### 1. Pick a branch

Work on a short-lived branch named for the change (e.g. `fix/ollama-timeout`).
Push is only needed if you open a pull request.

### 2. Make the change

- Keep each change small and atomic: one logical unit per commit.
- Format with `nix fmt` before finishing.
- Add or update a check in `checks/` when the change is not already covered
  (see [`checks/AGENTS.md`](checks/AGENTS.md)).

### 3. Verify locally

```bash
nix fmt                              # alejandra + linters (treefmt)
nix flake check                      # full check on the current platform
nix flake check --no-build           # quick evaluation-only pass
```

The public flake has no secrets, but most host-shaped checks need the `secrets`
input. Run CI-style verification against the fixture when you do not have the
private flake available:

```bash
nix flake check --override-input secrets path:./checks/fixtures/secrets
```

See `checks/fixtures/secrets/README.md`.

### 4. Commit

The repository uses [Conventional Commits](https://www.conventionalcommits.org/)
without emoji:

```
type(scope): short imperative summary
```

Common types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`,
`ci`. Keep the subject under 72 characters and summarize what and why in the
body as needed.

### 5. Pull request

If a PR is needed, follow the existing PR template and keep it reviewable as
one coherent change.

## Architecture Decisions

Significant design decisions are recorded as Architecture Decision Records in
`docs/decisions/` (see e.g. `0008-module-contract-v1.md`). Summarize the
decision and its consequences; keep them short and readable.

## Conventions

- **Style**: camelCase variables, kebab-case files, no `with lib;`, prefer
  `lib.mkIf`, use `pkgs.stdenv.hostPlatform.isDarwin`/`isLinux`.
- **Naming**: options under `aytordev.{category}.{subcategory}`.
- **Style guide reference**: see the `nix` and `dotfiles-coder` skills in
  `modules/common/ai-tools/skills/`, plus the per-directory `AGENTS.md`.
- **AI ownership**: follow the [native adoption guide](modules/common/ai-tools/README.md).
  The repository publishes four local skills; upstream owns Pi's workflow.

## Notes

- Architecture decisions and prior context: `docs/decisions/`.
- The intent of a change should land in the commit body and the relevant
  `AGENTS.md`, not in throwaway request pattern prose.
